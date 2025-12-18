M = {}

local uv = vim.loop

M.exec = function()
  local stdin = uv.new_pipe(false)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  print("stdin", stdin)
  print("stdout", stdout)
  print("stderr", stderr)
  local handle, pid = uv.spawn("cat", {
    args = {},
    stdio = { stdin, stdout, stderr }
  }, function(code, signal) -- on exit
    print("exit code", code)
    print("exit signal", signal)
  end)
  print("process opened", handle, pid)

  local aggregated_stdout = {}

  -- Read specific stdout
  uv.read_start(stdout, function(err, data)
    assert(not err, err)
    if data then
      print("stdout chunk", stdout, data)
      -- loop data
      local vals = vim.split(data, "\n")
      for _, d in pairs(vals) do
        if d == "" then goto continue end
        table.insert(aggregated_stdout, d)
        ::continue::
      end
    else
      print("stdout end", stdout)
    end
  end)

  local aggregated_stderr = {}

  -- Read specific stderr
  uv.read_start(stderr, function(err, data)
    assert(not err, err)
    if data then
      print("stderr chunk", stderr, data)
      table.insert(aggregated_stderr, data)
    else
      print("stderr end", stderr)
    end
  end)

  -- Write to specific stdin
  uv.write(stdin, "Hello World\nGoodbye World")

  -- Send EOF to specific stdin (otherwise cat would keep listening)
  uv.shutdown(stdin, function()
    print("stdin shutdown", stdin)
    uv.close(handle, function()
      print("process closed", handle, pid)
    end)
  end)

  
end

return M
