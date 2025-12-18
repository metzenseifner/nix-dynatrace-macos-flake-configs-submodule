--vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
--  vim.lsp.diagnostic.on_publish_diagnostics, {
--    -- Enable underline, use default values
--    underline = true,
--    -- Enable virtual text, override spacing to 4
--    virtual_text = {
--      spacing = 4,
--    },
--    -- Use a function to dynamically turn signs off
--    -- and on, using buffer local variables
--    signs = function(namespace, bufnr)
--      return vim.b[bufnr].show_signs == true
--    end,
--    -- Disable a feature
--    update_in_insert = false,
--  }
--)

--local on_references = vim.lsp.handlers["textDocument/references"] -- save reference to "references" handler by index notation
--vim.lsp.handlers["textDocument/references"] = vim.lsp.with(
--  on_references, {
--    -- Use location list instead of quickfix list
--    loclist = true,
--  }
--)
local border = {
  { "🭽", "FloatBorder" },
  { "▔", "FloatBorder" },
  { "🭾", "FloatBorder" },
  { "▕", "FloatBorder" },
  { "🭿", "FloatBorder" },
  { "▁", "FloatBorder" },
  { "🭼", "FloatBorder" },
  { "▏", "FloatBorder" },
}
local handlers = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border, max_width = 100 })
}
