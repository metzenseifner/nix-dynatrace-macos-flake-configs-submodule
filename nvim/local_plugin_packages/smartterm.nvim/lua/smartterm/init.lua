-- Smart Terminal - Minimal, fast terminal toggle
local M = {}

-- Cache for O(1) lookups
local cache = {}

-- Config
M.config = { height = 14, start_in_insert = true }

-- Check if terminal is visible
local function is_visible()
  return cache.win and vim.api.nvim_win_is_valid(cache.win)
end

-- Check if terminal job is alive
local function is_alive()
  return cache.buf 
    and vim.api.nvim_buf_is_valid(cache.buf)
    and cache.job
    and vim.fn.jobwait({ cache.job }, 0)[1] == -1
end

-- Create new terminal
local function create_terminal()
  -- Create horizontal split at bottom
  vim.cmd('botright ' .. M.config.height .. 'split')
  
  -- Create a new empty buffer for the terminal
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  
  local win = vim.api.nvim_get_current_win()
  local job = vim.fn.termopen(vim.o.shell)
  
  -- Cache
  cache = { buf = buf, job = job, win = win }
  
  -- Configure
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { buffer = buf })
  
  if M.config.start_in_insert then
    vim.cmd.startinsert()
  end
end

-- Show terminal
function M.open()
  if is_visible() then
    vim.api.nvim_set_current_win(cache.win)
    if M.config.start_in_insert then vim.cmd.startinsert() end
    return
  end
  
  if not is_alive() then
    if cache.buf then pcall(vim.api.nvim_buf_delete, cache.buf, { force = true }) end
    cache = {}
    create_terminal()
    return
  end
  
  -- Show existing terminal
  vim.cmd('botright ' .. M.config.height .. 'split')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, cache.buf)
  cache.win = win
  
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  if M.config.start_in_insert then vim.cmd.startinsert() end
end

-- Hide terminal
function M.close()
  if is_visible() then
    vim.api.nvim_win_close(cache.win, false)
    cache.win = nil
  end
end

-- Toggle terminal
function M.toggle()
  if is_visible() then M.close() else M.open() end
end

-- Setup
function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
  vim.api.nvim_create_user_command('ToggleTerm', M.toggle, {})
end

return M
