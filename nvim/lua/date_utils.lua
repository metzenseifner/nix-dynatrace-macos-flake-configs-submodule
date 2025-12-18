local M = {}
local portable = require('config.portable')

--
-- @returns string timestamp
function M.timestamp()
  -- Try different date command formats for cross-platform compatibility
  local formats = {
    "date '+%Y-%m-%d %H:%M:%S %Z'",           -- Unix/Linux/macOS
    "powershell -c \"Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'\"", -- Windows PowerShell
  }
  
  for _, cmd in ipairs(formats) do
    local result = portable.safe_system(cmd, "timestamp")
    if result ~= "" then
      return vim.fn.trim(result)
    end
  end
  
  -- Fallback to Lua's os.date if external commands fail
  return os.date("%Y-%m-%d %H:%M:%S")
end

--
-- @returns string timestamp in orgmode format
function M.timestamp_orgmode()
  local formats = {
    "date '+%Y-%m-%d %a %H:%M:%S%z'",         -- Unix/Linux/macOS
    "powershell -c \"Get-Date -Format 'yyyy-MM-dd ddd HH:mm:sszzz'\"", -- Windows PowerShell
  }
  
  for _, cmd in ipairs(formats) do
    local result = portable.safe_system(cmd, "timestamp_orgmode")
    if result ~= "" then
      return vim.fn.trim(result)
    end
  end
  
  -- Fallback to Lua's os.date
  return os.date("%Y-%m-%d %a %H:%M:%S")
end

function M.datestamp_orgmode()
  local formats = {
    "date '+%Y-%m-%d %a'",                    -- Unix/Linux/macOS
    "powershell -c \"Get-Date -Format 'yyyy-MM-dd ddd'\"", -- Windows PowerShell
  }
  
  for _, cmd in ipairs(formats) do
    local result = portable.safe_system(cmd, "datestamp_orgmode")
    if result ~= "" then
      return vim.fn.trim(result)
    end
  end
  
  -- Fallback to Lua's os.date
  return os.date("%Y-%m-%d %a")
end

function M.daystamp()
  local formats = {
    "date '+%A, %Y-%m-%d %H:%M:%S %Z'",       -- Unix/Linux/macOS
    "powershell -c \"Get-Date -Format 'dddd, yyyy-MM-dd HH:mm:ss zzz'\"", -- Windows PowerShell
  }
  
  for _, cmd in ipairs(formats) do
    local result = portable.safe_system(cmd, "daystamp")
    if result ~= "" then
      return vim.fn.trim(result)
    end
  end
  
  -- Fallback to Lua's os.date
  return os.date("%A, %Y-%m-%d %H:%M:%S")
end

return M
