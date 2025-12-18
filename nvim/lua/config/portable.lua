local M = {}
local notified = {}

local function notify(msg, level)
  local ok, n = pcall(require, "notify")
  if ok and type(n) == "function" then
    n(msg, level or vim.log.levels.INFO, { title = "Portable check" })
  else
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Portable check" })
  end
end

function M.has(bin)
  return vim.fn.executable(bin) == 1
end

function M.notify_once(key, msg, level)
  if notified[key] then return end
  notified[key] = true
  notify(msg, level or vim.log.levels.WARN)
end

function M.ensure_bins(bins, feature_name)
  local missing = {}
  for _, b in ipairs(bins) do
    if not M.has(b) then table.insert(missing, b) end
  end
  if #missing > 0 then
    M.notify_once("bins:" .. table.concat(missing, ","),
      string.format("[%s] Missing external tools: %s", feature_name or "feature", table.concat(missing, ", ")),
      vim.log.levels.WARN
    )
    return false, missing
  end
  return true, {}
end

-- pcall a setup function and notify on failure (without blowing up startup)
function M.safe_setup(mod, opts)
  local ok, plugin = pcall(require, mod)
  if not ok then
    M.notify_once("require:" .. mod, "Could not require '" .. mod .. "'", vim.log.levels.WARN)
    return false
  end
  local ok2, err = pcall(function()
    if type(plugin.setup) == "function" then
      plugin.setup(opts or {})
    elseif type(plugin) == "table" and type(plugin[1]) == "function" then
      plugin[1](opts or {})
    end
  end)
  if not ok2 then
    M.notify_once("setup:" .. mod, "Setup failed for '" .. mod .. "': " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  return true
end

-- safe call to vim.fn.system with executable check
function M.safe_system(cmd, feature_name)
  if type(cmd) == "string" then
    local bin = cmd:match("^%S+")
    if not M.has(bin) then
      M.notify_once("system:" .. bin, string.format("[%s] Missing external tool: %s", feature_name or "system", bin), vim.log.levels.WARN)
      return ""
    end
  elseif type(cmd) == "table" and #cmd > 0 then
    if not M.has(cmd[1]) then
      M.notify_once("system:" .. cmd[1], string.format("[%s] Missing external tool: %s", feature_name or "system", cmd[1]), vim.log.levels.WARN)
      return ""
    end
  end
  
  local ok, result = pcall(vim.fn.system, cmd)
  if not ok then
    M.notify_once("system_error:" .. (feature_name or "unknown"), string.format("[%s] System call failed: %s", feature_name or "system", tostring(result)), vim.log.levels.ERROR)
    return ""
  end
  return result
end

-- safe call to io.popen with executable check
function M.safe_popen(cmd, mode, feature_name)
  local bin = cmd:match("^%S+")
  if not M.has(bin) then
    M.notify_once("popen:" .. bin, string.format("[%s] Missing external tool: %s", feature_name or "popen", bin), vim.log.levels.WARN)
    return nil
  end
  
  local ok, handle = pcall(io.popen, cmd, mode or "r")
  if not ok then
    M.notify_once("popen_error:" .. (feature_name or "unknown"), string.format("[%s] Popen failed: %s", feature_name or "popen", tostring(handle)), vim.log.levels.ERROR)
    return nil
  end
  return handle
end

-- safe call to os.execute with executable check
function M.safe_execute(cmd, feature_name)
  local bin = cmd:match("^%S+")
  if not M.has(bin) then
    M.notify_once("execute:" .. bin, string.format("[%s] Missing external tool: %s", feature_name or "execute", bin), vim.log.levels.WARN)
    return false
  end
  
  local ok, result = pcall(os.execute, cmd)
  if not ok then
    M.notify_once("execute_error:" .. (feature_name or "unknown"), string.format("[%s] Execute failed: %s", feature_name or "execute", tostring(result)), vim.log.levels.ERROR)  
    return false
  end
  return result == 0
end

-- Replacement for nvim-mapper functionality with pcall protection
function M.safe_keymap(mode, key, cmd, opts, category, id, description)
  local ok, err = pcall(vim.keymap.set, mode, key, cmd, opts or {})
  if not ok then
    M.notify_once("keymap:" .. key, string.format("Failed to set keymap %s: %s", key, tostring(err)), vim.log.levels.WARN)
  end
end

-- safe call to vim.fn.jobstart with executable check
function M.safe_jobstart(cmd, opts, feature_name)
  if type(cmd) == "table" and #cmd > 0 then
    if not M.has(cmd[1]) then
      M.notify_once("jobstart:" .. cmd[1], string.format("[%s] Missing external tool: %s", feature_name or "jobstart", cmd[1]), vim.log.levels.WARN)
      return -1
    end
  elseif type(cmd) == "string" then
    local bin = cmd:match("^%S+")
    if not M.has(bin) then
      M.notify_once("jobstart:" .. bin, string.format("[%s] Missing external tool: %s", feature_name or "jobstart", bin), vim.log.levels.WARN)
      return -1
    end
  end
  
  local ok, job_id = pcall(vim.fn.jobstart, cmd, opts or {})
  if not ok then
    M.notify_once("jobstart_error:" .. (feature_name or "unknown"), string.format("[%s] Jobstart failed: %s", feature_name or "jobstart", tostring(job_id)), vim.log.levels.ERROR)
    return -1
  end
  return job_id
end

-- Cross-platform safe date/time functions
function M.safe_date_cmd(format, feature_name)
  local formats = {
    string.format("date '+%s'", format),                    -- Unix/Linux/macOS
    string.format("powershell -c \"Get-Date -Format '%s'\"", format:gsub("%%", "")), -- Windows PowerShell
  }
  
  for _, cmd in ipairs(formats) do
    local result = M.safe_system(cmd, feature_name or "date")
    if result ~= "" then
      return vim.fn.trim(result)
    end
  end
  
  -- Return empty string if all external date commands fail
  return ""
end

return M
