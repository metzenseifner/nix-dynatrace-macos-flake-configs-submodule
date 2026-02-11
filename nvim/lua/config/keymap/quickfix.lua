-- Navigate between quickfix items
-- vim.keymap.set("n", "<C-n>", ":cnext<CR>zz", { desc = "Forward qfixlist" })
-- vim.keymap.set("n", "<C-b>;", ":cprev<CR>zz", { desc = "Backward qfixlist" })

-- Cycle through quickfix list items
vim.keymap.set('n', '<C-n>', '<Cmd>try | cnext | catch | cfirst | catch | endtry<CR>', { desc = "Next in quickfix list" })
vim.keymap.set('n', '<C-p>', '<Cmd>try | cprevious | catch | clast | catch | endtry<CR>',
  { desc = "Previous in quickfix list" })

-- Remove current item from quickfix list (do not use C-d or C-r to avoid collisions)
-- TODO must fix this and others to do nothing if quickfix list is not open
-- vim.keymap.set('n', '<C-D>', function()
--   local qf_list = vim.fn.getqflist()
--   local cur_pos = vim.fn.line('.')
--   table.remove(qf_list, cur_pos)
--   vim.fn.setqflist(qf_list, 'r')
--   vim.cmd('cc ' .. math.min(cur_pos, #qf_list))
-- end, { desc = "Remove current item from quickfix list", buffer = true })

-- Add current cursor position to quickfix list
vim.keymap.set('n', '<leader>qa', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  vim.fn.setqflist({{ filename = filename, lnum = cursor[1], col = cursor[2] + 1 }}, 'a')
  print('Added ' .. filename .. ':' .. cursor[1] .. ' to quickfix list')
end, { desc = "[Quickfix] Add current position" })
