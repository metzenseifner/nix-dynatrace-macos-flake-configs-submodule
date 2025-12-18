return {
  s("log-debug", fmt([[
  vim.notify(string.format("{topic}: %s", vim.inspect({tbl}), vim.log.levels.DEBUG)
  ]], { topic = i(1, "topic"), tbl = i(2, "table") }, {})),
  s("vim.fn.jobstart", fmt([[
    local command = string.format("git diff --name-only %s", sinceCommit)
    local stdout = {}
    local stderr = {}
    vim.fn.jobstart(command, {
      stdout_buffered = true, -- buffer by LF
      on_stdout = function(_, data) table.insert(stdout, data)  end,
      on_stderr = function(_, data) table.insert(stderr, data) end,
      on_exit = function() vim.notify(stdout) end,
    })
  ]], {}, { delimiters = "[]" })),
  s("cwd", fmt([[
  --uv.cwd()
  vim.loop.cwd()
  ]], {}, {})),
  s("prompt-path", fmt([[
    local buf_parent_dir = vim.fn.expand('%:p:h')
    local input = vim.fn.input("Desired Path: ", buf_parent_dir)
  ]], {}, {})),
  s("prompt", fmt([[
    local prefilled_input_str = "<prefilled_str>"
    local input = vim.fn.input("<prompt_question>: ", prefilled_input_str)
  ]], { prompt_question = i(1, "prompt question"), prefilled_str = i(2, "prefilled string") }, { delimiters = "<>" })),

  -- Possibly too low level because it breaks neotest finding go tests
  --vim.loop.chdir(git_dir)
  s("cwd-set", fmt([[
    if dir then vim.api.nvim_set_current_dir(dir) end
  ]], {}, {})),

}
