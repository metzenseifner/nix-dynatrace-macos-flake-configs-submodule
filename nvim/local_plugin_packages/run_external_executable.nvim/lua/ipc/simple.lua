local M = {}
  --local process = io.popen('sprint_provider'); P(process:read('*a')); local rc = {process.close()}
M.exec = function(executable)
  -- see help file:read({...}) for io.read parser control
  local exec_name = executable or 'sprint_provider'
  
  if vim.fn.executable(exec_name) ~= 1 then
    vim.notify("External executable not found: " .. exec_name, vim.log.levels.WARN)
    return { stdout = "EXECUTABLE-UNAVAILABLE" }
  end
  
  local ok, process = pcall(io.popen, exec_name)
  if not ok or not process then
    vim.notify("Failed to execute: " .. exec_name, vim.log.levels.WARN)
    return { stdout = "EXECUTION-FAILED" }
  end
  
  local stdout = process:read('*l')
  local rc = { process:close() }
  return { stdout = stdout or "NO-OUTPUT" }
end

return M

