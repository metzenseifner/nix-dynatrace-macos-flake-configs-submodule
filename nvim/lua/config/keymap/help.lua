local group = vim.api.nvim_create_augroup('HelpNav', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'help',
  callback = function(args)
    local opts = { buffer = args.buf, silent = true, noremap = true, desc = 'Help navigation' }
    vim.keymap.set('n', '<CR>', '<C-]>', opts) -- follow help tag
    --vim.keymap.set('n', 'H', '<C-T>', opts)    -- go back
  end,
})
