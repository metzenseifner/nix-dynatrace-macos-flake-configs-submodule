-- HTTP client for Confluence API using curl
local M = {}

-- Get authentication token from supplier
local function get_auth_token()
  local confluence = require('confluence')
  if not confluence.config.auth.token_supplier then
    return nil, "No token supplier configured"
  end
  
  local ok, token = pcall(confluence.config.auth.token_supplier)
  if not ok then
    return nil, "Token supplier failed: " .. tostring(token)
  end
  
  return token, nil
end

-- Create basic auth header
local function create_auth_header(email, token)
  local credentials = email .. ":" .. token
  local encoded = vim.fn.system("echo -n '" .. credentials .. "' | base64"):gsub("\n", "")
  return "Basic " .. encoded
end

-- Calculate backoff delay
local function calculate_backoff_delay(attempt)
  local confluence = require('confluence')
  local config = confluence.config.retry
  local delay
  
  if config.backoff_type == "logarithmic" then
    -- Logarithmic backoff: initial_delay * log(attempt + 1)
    delay = config.initial_delay_ms * math.log(attempt + 1)
  else
    -- Exponential backoff: initial_delay * 2^(attempt - 1)
    delay = config.initial_delay_ms * math.pow(2, attempt - 1)
  end
  
  -- Cap at max_delay_ms
  return math.min(delay, config.max_delay_ms)
end

-- Check if error is retryable
local function is_retryable_error(exit_code, error_msg)
  -- Retry on network errors, timeouts, and 5xx server errors
  if exit_code ~= 0 then
    return true
  end
  if error_msg and (
    error_msg:match("timeout") or
    error_msg:match("connection") or
    error_msg:match("network") or
    error_msg:match("5%d%d")
  ) then
    return true
  end
  return false
end

-- Make HTTP request using curl with retry logic
function M.request(method, url, data, callback)
  local confluence = require('confluence')
  local max_attempts = confluence.config.retry.max_attempts
  
  local function attempt_request(attempt_num)
    -- Get authentication
    local token, err = get_auth_token()
    if not token then
      callback(nil, err)
      return
    end
    
    local auth_header = create_auth_header(confluence.config.auth.email, token)
    
    -- Build curl command
    local cmd = {
      "curl",
      "-s",  -- silent
      "-w", "\n%{http_code}", -- append HTTP status code
      "-X", method,
      "-H", "Content-Type: application/json",
      "-H", "Authorization: " .. auth_header,
    }
    
    -- Add request body if provided
    if data then
      table.insert(cmd, "-d")
      table.insert(cmd, vim.json.encode(data))
    end
    
    table.insert(cmd, url)
    
    -- Execute curl asynchronously
    local stdout_data = {}
    local stderr_data = {}
    
    local job_id = vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, data)
        if data then
          vim.list_extend(stdout_data, data)
        end
      end,
      on_stderr = function(_, data)
        if data then
          vim.list_extend(stderr_data, data)
        end
      end,
      on_exit = function(_, exit_code)
        local response_text = table.concat(stdout_data, "\n")
        local error_msg = table.concat(stderr_data, "\n")
        
        -- Extract HTTP status code from response
        local http_code = response_text:match("\n(%d%d%d)$")
        if http_code then
          response_text = response_text:gsub("\n%d%d%d$", "")
        end
        
        -- Check if request succeeded
        local success = exit_code == 0 and http_code and tonumber(http_code) < 500
        
        if success then
          local ok, response = pcall(vim.json.decode, response_text)
          if ok then
            callback(response, nil)
          else
            -- Invalid JSON might be retryable
            if attempt_num < max_attempts then
              local delay = calculate_backoff_delay(attempt_num)
              vim.notify(string.format("Invalid JSON response, retrying in %.1fs (attempt %d/%d)",
                delay / 1000, attempt_num + 1, max_attempts), vim.log.levels.WARN)
              vim.defer_fn(function()
                attempt_request(attempt_num + 1)
              end, delay)
            else
              callback(nil, "Invalid JSON response after " .. max_attempts .. " attempts: " .. response_text)
            end
          end
        else
          -- Check if error is retryable
          local should_retry = is_retryable_error(exit_code, error_msg) or 
                              (http_code and tonumber(http_code) >= 500)
          
          if should_retry and attempt_num < max_attempts then
            local delay = calculate_backoff_delay(attempt_num)
            vim.notify(string.format("Request failed (HTTP %s), retrying in %.1fs (attempt %d/%d)",
              http_code or "N/A", delay / 1000, attempt_num + 1, max_attempts), vim.log.levels.WARN)
            vim.defer_fn(function()
              attempt_request(attempt_num + 1)
            end, delay)
          else
            local final_error = error_msg ~= "" and error_msg or 
                               ("HTTP request failed with status " .. (http_code or "unknown"))
            if attempt_num >= max_attempts then
              final_error = final_error .. " (failed after " .. max_attempts .. " attempts)"
            end
            callback(nil, final_error)
          end
        end
      end
    })
    
    if job_id <= 0 then
      if attempt_num < max_attempts then
        local delay = calculate_backoff_delay(attempt_num)
        vim.defer_fn(function()
          attempt_request(attempt_num + 1)
        end, delay)
      else
        callback(nil, "Failed to start curl process after " .. max_attempts .. " attempts")
      end
    end
  end
  
  -- Start with attempt 1
  attempt_request(1)
end

-- GET request
function M.get(url, callback)
  M.request("GET", url, nil, callback)
end

-- PUT request  
function M.put(url, data, callback)
  M.request("PUT", url, data, callback)
end

-- POST request
function M.post(url, data, callback)
  M.request("POST", url, data, callback)
end

return M