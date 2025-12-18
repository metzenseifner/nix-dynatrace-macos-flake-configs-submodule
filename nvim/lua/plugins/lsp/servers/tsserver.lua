-- Utility used by tsserver
--
-- Allows formatting by specifically the tsserver (how it would do it).
--
-- This actually has conflicted with eslint formatter applied to global
-- vim.lsp formatters: vim.lsp.buf.format()
local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = "Organize Imports"
  }
  vim.notify("Sending _typescript.organizeImports to typescript language server")
  vim.lsp.buf.execute_command(params)
end

--tsserver = function(server, opts)
--  opts.on_attach = function(client, bufnr)
--    vim.notify(
--      string.format(client.name .. ": Custom on_attach called for the language server %s\ncmd: %s\ncwd: %s",
--        client.name,
--        vim.inspect(client.config.cmd), vim.inspect(client.config.cmd_cwd)), 'info')

--    vim.api.nvim_create_autocmd("BufWritePre", {
--      buffer = bufnr,
--      callback = function()
--        vim.notify(client.name .. ": OrganizeImports called.")
--        --vim.cmd("OrganizeImports")
--        vim.lsp.buf.execute_command({ command = "_typescript.organizeImports", arguments = { vim.fn.expand("%:p") }, async =false })
--        vim.notify("vim.lsp.format(...) for tsserver called.")
--        vim.lsp.buf.format({ filter = function(client) return client.name == 'tsserver' end })
--      end,
--    })
--  end
--end,

local function tsserver_format_buffer(bufnr)
  local params = {
    command = "",
    arguments = {},
    title = ""
  }
  vim.lsp.buf.execute_command(params)
  -- perform a syncronous request
  -- 500ms timeout depending on the size of file a bigger timeout may be needed
  -- or also vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", params, 500)
end

return {
  ts_ls = {
    filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact",
      "javascript.jsx" },
    root_dir = require('lspconfig').util.root_pattern("package.json", "tsconfig.json", "jsonconfig.json", ".git"),
    --handlers = handlers,
    --flags = lsp_flags,
    -- organize_imports would be great but see https://vi.stackexchange.com/questions/41538/how-do-i-organize-imports-with-tsserver-using-neovim-lsp
    commands = {
      OrganizeImports = { -- Define a VIM User Command to call our backend lua code
        organize_imports,
        description = "Organize Imports"
      },
      FormatBuffer = {
        function() print("FormatBuffer command") end,
        description = "TSServer Format Buffer"
      }
    }
  },
}
