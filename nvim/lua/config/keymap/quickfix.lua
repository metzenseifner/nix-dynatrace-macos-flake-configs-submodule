-- Navigate between quickfix items
-- vim.keymap.set("n", "<C-n>", ":cnext<CR>zz", { desc = "Forward qfixlist" })
-- vim.keymap.set("n", "<C-b>;", ":cprev<CR>zz", { desc = "Backward qfixlist" })

-- Cycle through quickfix list items
vim.keymap.set('n', '<C-n>', '<Cmd>try | cnext | catch | cfirst | catch | endtry<CR>', { desc = "Next in quickfix list" })
vim.keymap.set('n', '<C-p>', '<Cmd>try | cprevious | catch | clast | catch | endtry<CR>',
  { desc = "Previous in quickfix list" })
