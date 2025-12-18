-- THIS IS BROKEN; DO NOT LOAD
return {
  eslint = { -- null-ls also supports eslint but the diagnostics stuff is not working for eslint (only eslint_d?) yet. It is not so stable. Eventually null-ls can seemlessly integrate with diagnostics and we can drop this.
    -- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/eslint.lua
    settings = {
      autoFixOnSave = false,
      format = true,
      codeActionOnSave = {
        enable = false,
        mode = 'all'
      }
    },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue", "svelte", "astro" },
    cmd = { "vscode-eslint-language-server", "--stdio" },
    --  handlers = {
    --    ["eslint/confirmESLintExecution"] = <function 1>,
    --    ["eslint/noLibrary"] = <function 2>,
    --    ["eslint/openDoc"] = <function 3>,
    --    ["eslint/probeFailed"] = <function 4>
    --  },
    on_attach = function(client, bufnr)
      vim.notify('Applying EslintFixAll from eslint language server.')
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.notify("eslint LSP Applying EslintFixAll: " .. client.name)
          vim.cmd("EslintFixAll")
        end
      })
    end,
  },
}
