-- To format UI borders in Neovim, you can customize the appearance of floating
-- windows and other UI elements by setting specific characters and highlight
-- groups.

local border = {
  { "╭", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╮", "FloatBorder" },
  { "│", "FloatBorder" },
  { "╯", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╰", "FloatBorder" },
  { "│", "FloatBorder" },
}

vim.cmd [[
  autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335
  autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335
]]

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Highlight trailing spaces in red
vim.api.nvim_set_hl(0, "TrailingSpace", { bg = "red" })
vim.cmd([[autocmd BufWinEnter,InsertLeave * match TrailingSpace /\s\+$/]])
