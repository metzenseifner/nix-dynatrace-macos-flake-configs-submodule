-- Navigate between quickfix items
-- vim.keymap.set("n", "<C-n>", ":cnext<CR>zz", { desc = "Forward qfixlist" })
-- vim.keymap.set("n", "<C-b>;", ":cprev<CR>zz", { desc = "Backward qfixlist" })

-- Cycle through quickfix list items (only when quickfix window is open)
local function is_quickfix_open()
  for _, win in pairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      return true
    end
  end
  return false
end

local function safe_qf_next()
  if is_quickfix_open() then
    vim.cmd('try | cnext | catch | cfirst | catch | endtry')
  end
end

local function safe_qf_prev()
  if is_quickfix_open() then
    vim.cmd('try | cprevious | catch | clast | catch | endtry')
  end
end

vim.keymap.set('n', '<C-n>', safe_qf_next, { desc = "Next in quickfix list (if open)" })
vim.keymap.set('n', '<C-p>', safe_qf_prev, { desc = "Previous in quickfix list (if open)" })

-- Delete/reorder quickfix items (context-sensitive: only in quickfix window)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function(event)
    -- Delete single item with dd
    vim.keymap.set('n', 'dd', function()
      local qf_list = vim.fn.getqflist()
      local cur_pos = vim.fn.line('.')
      if #qf_list > 0 and cur_pos <= #qf_list then
        table.remove(qf_list, cur_pos)
        vim.fn.setqflist(qf_list, 'r')
        if #qf_list > 0 then
          -- Stay in quickfix window, just move cursor to next item
          local next_pos = math.min(cur_pos, #qf_list)
          vim.fn.cursor(next_pos, 1)
        else
          -- Close quickfix if empty
          vim.cmd('cclose')
        end
        vim.notify('Removed item from quickfix list')
      end
    end, { desc = "Delete quickfix item", buffer = event.buf })

    -- Delete multiple items in visual mode
    vim.keymap.set('v', 'd', function()
      local qf_list = vim.fn.getqflist()
      local start_line = vim.fn.line('v')
      local end_line = vim.fn.line('.')
      if start_line > end_line then
        start_line, end_line = end_line, start_line
      end
      
      if #qf_list > 0 then
        -- Remove items in reverse order to maintain indices
        for i = end_line, start_line, -1 do
          if i <= #qf_list then
            table.remove(qf_list, i)
          end
        end
        vim.fn.setqflist(qf_list, 'r')
        local count = end_line - start_line + 1
        if #qf_list > 0 then
          -- Stay in quickfix window, just move cursor to next item
          local next_pos = math.min(start_line, #qf_list)
          vim.fn.cursor(next_pos, 1)
        else
          -- Close quickfix if empty
          vim.cmd('cclose')
        end
        vim.notify('Removed ' .. count .. ' items from quickfix list')
      end
      vim.cmd('normal! ' .. vim.api.nvim_replace_termcodes('<Esc>', true, false, true))
    end, { desc = "Delete quickfix items (visual)", buffer = event.buf })

    -- Move item up with Ctrl-k (wraps around)
    vim.keymap.set('n', '<C-k>', function()
      local qf_list = vim.fn.getqflist()
      local cur_pos = vim.fn.line('.')
      if #qf_list > 1 and cur_pos >= 1 and cur_pos <= #qf_list then
        local new_pos
        if cur_pos == 1 then
          -- Wrap to bottom
          local item = table.remove(qf_list, 1)
          table.insert(qf_list, item)
          new_pos = #qf_list
        else
          -- Move up normally
          qf_list[cur_pos], qf_list[cur_pos - 1] = qf_list[cur_pos - 1], qf_list[cur_pos]
          new_pos = cur_pos - 1
        end
        vim.fn.setqflist(qf_list, 'r')
        vim.fn.cursor(new_pos, 1)
      end
    end, { desc = "Move quickfix item up", buffer = event.buf })

    -- Move item down with Ctrl-j (wraps around)
    vim.keymap.set('n', '<C-j>', function()
      local qf_list = vim.fn.getqflist()
      local cur_pos = vim.fn.line('.')
      if #qf_list > 1 and cur_pos >= 1 and cur_pos <= #qf_list then
        local new_pos
        if cur_pos == #qf_list then
          -- Wrap to top
          local item = table.remove(qf_list, #qf_list)
          table.insert(qf_list, 1, item)
          new_pos = 1
        else
          -- Move down normally
          qf_list[cur_pos], qf_list[cur_pos + 1] = qf_list[cur_pos + 1], qf_list[cur_pos]
          new_pos = cur_pos + 1
        end
        vim.fn.setqflist(qf_list, 'r')
        vim.fn.cursor(new_pos, 1)
      end
    end, { desc = "Move quickfix item down", buffer = event.buf })
  end,
})

-- Add current cursor position to quickfix list
vim.keymap.set('n', '<leader>qa', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local line_text = vim.api.nvim_buf_get_lines(bufnr, cursor[1] - 1, cursor[1], false)[1] or ""
  vim.fn.setqflist({{ filename = filename, lnum = cursor[1], col = cursor[2] + 1, text = line_text }}, 'a')
  vim.notify('Added ' .. filename .. ':' .. cursor[1] .. ' to quickfix list')
end, { desc = "[Quickfix] Add current position" })
