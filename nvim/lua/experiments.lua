local mytbl = {
  context = {
    diagnostics = nil,
    only = { "addMissingImports" }
  }
}


vim.lsp.buf.code_action(mytbl)

-- see /Users/jonathan.komar/devel/neovim/runtime/lua/vim/lsp/buf.lua

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("JonathansCoolExperiment", { clear = true }),
  pattern = "*.jonathansext",
  callback = function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "output of: " })
    vim.fn.jobstart({ "executable", "arg1", "arg2" }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then
          vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
        end
      end,
      on_stderr = function(_, data)
        if data then
          vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
        end
      end,
    })
  end
})
