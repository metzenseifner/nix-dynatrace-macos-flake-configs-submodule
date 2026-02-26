-- Utility module for working with current working directory
-- Respects tab-local, window-local, and global cwd hierarchy

local M = {}

-- Get the most specific cwd (tab-local > window-local > global)
-- Returns the tab-local cwd if set, otherwise falls back to window-local, then global
function M.get()
  -- getcwd(-1, 0) gets the tab-local cwd for current tab
  -- getcwd(0, 0) gets the window-local cwd for current window
  -- getcwd() gets the global cwd
  local tab_cwd = vim.fn.getcwd(-1, 0)
  if tab_cwd and tab_cwd ~= "" and tab_cwd ~= vim.fn.getcwd() then
    return tab_cwd
  end
  
  local win_cwd = vim.fn.getcwd(0, 0)
  if win_cwd and win_cwd ~= "" and win_cwd ~= vim.fn.getcwd() then
    return win_cwd
  end
  
  return vim.loop.cwd() or vim.fn.getcwd()
end

-- Set tab-local cwd
function M.set_tab(path)
  vim.cmd('tcd ' .. vim.fn.fnameescape(path))
end

-- Set window-local cwd
function M.set_window(path)
  vim.cmd('lcd ' .. vim.fn.fnameescape(path))
end

-- Set global cwd
function M.set_global(path)
  vim.cmd('cd ' .. vim.fn.fnameescape(path))
end

return M
