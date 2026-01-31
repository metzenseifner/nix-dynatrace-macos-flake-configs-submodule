-- Confluence.nvim - Edit Confluence pages directly in Neovim
local M = {}

-- Plugin configuration
M.config = {
  base_url = nil,           -- e.g., "https://dt-rnd.atlassian.net"
  auth = {
    email = nil,            -- Confluence user email
    token_supplier = nil,   -- Function that returns API token
  },
  buffer_options = {
    filetype = "confluence", -- Default filetype for syntax highlighting
    wrap = true,            -- Enable line wrapping
    spell = true,           -- Enable spell checking
  },
  pandoc = {
    enabled = false,        -- Enable pandoc conversions
    executable = "pandoc", -- Pandoc executable path
  },
  retry = {
    max_attempts = 5,      -- Maximum number of retry attempts
    backoff_type = "exponential", -- "exponential" or "logarithmic"
    initial_delay_ms = 1000, -- Initial delay in milliseconds
    max_delay_ms = 30000,  -- Maximum delay between retries
  }
}

-- Cache for page data
local page_cache = {}

-- HTTP client using curl
local http = require('confluence.http')
local api = require('confluence.api')
local buffer = require('confluence.buffer')
local pandoc = require('confluence.pandoc')

-- Parse Confluence URL to extract page info
local function parse_confluence_url(url)
  -- Pattern: https://domain/wiki/spaces/SPACE/pages/PAGE_ID/Page+Title
  local domain, space, page_id, title = url:match("^(https?://[^/]+)/wiki/spaces/([^/]+)/pages/(%d+)/(.*)$")
  
  if not (domain and space and page_id) then
    return nil, "Invalid Confluence URL format"
  end
  
  return {
    domain = domain,
    space = space,
    page_id = tonumber(page_id),
    title = title and title:gsub("+", " ") or "Unknown"
  }, nil
end

-- Parse command arguments
local function parse_args(args)
  local parsed = {
    url = nil,
    format = "confluence", -- default format
    options = {}
  }
  
  -- Handle different input types
  if type(args) == "string" then
    -- Single string argument, assume it's a URL
    parsed.url = args
  elseif type(args) == "table" then
    for _, arg in ipairs(args) do
      if arg:match("^--as=") then
        parsed.format = arg:match("^--as=(.+)")
      elseif arg:match("^--") then
        -- Other options can be added here
        local key, value = arg:match("^--([^=]+)=?(.*)$")
        parsed.options[key] = value ~= "" and value or true
      elseif arg:match("^https?://") then
        -- Assume it's the URL
        parsed.url = arg
      end
    end
  end
  
  return parsed
end

-- Open Confluence page for editing
function M.open(args)
  local parsed_args = parse_args(args)
  
  if not parsed_args.url then
    vim.notify("Please provide a Confluence URL", vim.log.levels.ERROR)
    return
  end
  
  local page_info, err = parse_confluence_url(parsed_args.url)
  if not page_info then
    vim.notify("Error parsing URL: " .. err, vim.log.levels.ERROR)
    return
  end
  
  -- Check configuration
  if not M.config.base_url or not M.config.auth.email or not M.config.auth.token_supplier then
    vim.notify("Confluence plugin not configured. Run :Confluence setup", vim.log.levels.ERROR)
    return
  end
  
  -- Validate format
  if parsed_args.format ~= "confluence" and parsed_args.format ~= "orgmode" then
    vim.notify("Unsupported format: " .. parsed_args.format .. ". Use 'confluence' or 'orgmode'", vim.log.levels.ERROR)
    return
  end
  
  -- Check pandoc availability for orgmode
  if parsed_args.format == "orgmode" then
    if not M.config.pandoc.enabled then
      vim.notify("Pandoc support not enabled. Set pandoc.enabled = true in config", vim.log.levels.ERROR)
      return
    end
    if vim.fn.executable(M.config.pandoc.executable) ~= 1 then
      vim.notify("Pandoc executable not found: " .. M.config.pandoc.executable, vim.log.levels.ERROR)
      return
    end
  end
  
  vim.notify("Loading Confluence page: " .. page_info.title .. " (format: " .. parsed_args.format .. ")", vim.log.levels.INFO)
  
  -- Load page content asynchronously
  api.get_page_content(page_info.page_id, function(content, version, err)
    if err then
      vim.notify("Error loading page: " .. err, vim.log.levels.ERROR)
      return
    end
    
    -- Create and setup buffer with specified format
    buffer.create_confluence_buffer(page_info, content, version, parsed_args.format)
    vim.notify("Confluence page loaded successfully", vim.log.levels.INFO)
  end)
end

-- Save current buffer back to Confluence  
function M.save()
  local buf = vim.api.nvim_get_current_buf()
  local page_data = page_cache[buf]
  
  if not page_data then
    vim.notify("Current buffer is not a Confluence page", vim.log.levels.WARN)
    return
  end
  
  -- Get current buffer content
  local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local current_content = table.concat(current_lines, "\n")
  
  -- Convert content based on format
  local storage_content
  if page_data.format == "orgmode" then
    storage_content = pandoc.orgmode_to_confluence(current_content)
    if not storage_content then
      vim.notify("Error converting org-mode to Confluence format", vim.log.levels.ERROR)
      return
    end
  else
    -- Default confluence format
    storage_content = buffer.readable_to_storage(current_content)
  end
  
  vim.notify("Saving to Confluence...", vim.log.levels.INFO)
  
  api.update_page_content(page_data.page_id, storage_content, page_data.version + 1, function(success, err)
    if success then
      page_data.version = page_data.version + 1
      vim.notify("Page saved successfully", vim.log.levels.INFO)
      -- Mark buffer as saved
      vim.bo[buf].modified = false
    else
      vim.notify("Error saving page: " .. err, vim.log.levels.ERROR)
    end
  end)
end

-- Reload current Confluence buffer from server
function M.reload()
  local buf = vim.api.nvim_get_current_buf()
  local page_data = page_cache[buf]
  
  if not page_data then
    vim.notify("Current buffer is not a Confluence page", vim.log.levels.WARN)
    return
  end
  
  vim.notify("Reloading page from Confluence...", vim.log.levels.INFO)
  
  -- Get fresh content from server
  api.get_page_content(page_data.page_id, function(content, version, err)
    if err then
      vim.notify("Error reloading page: " .. err, vim.log.levels.ERROR)
      return
    end
    
    -- Convert content based on format
    local readable_content
    if page_data.format == "orgmode" then
      readable_content = pandoc.confluence_to_orgmode(content)
      if not readable_content then
        vim.notify("Error converting Confluence to org-mode format", vim.log.levels.ERROR)
        return
      end
    else
      -- Default confluence format
      readable_content = buffer.storage_to_readable(content)
    end
    
    local lines = vim.split(readable_content, "\n", { plain = true })
    
    -- Replace buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Update cache with new version
    page_data.version = version
    page_data.original_content = content
    
    -- Mark buffer as unmodified
    vim.bo[buf].modified = false
    
    vim.notify("Page reloaded successfully (version " .. version .. ")", vim.log.levels.INFO)
  end)
end

-- Show plugin configuration
function M.setup_info()
  print("Confluence Configuration:")
  print("  Base URL: " .. (M.config.base_url or "Not set"))
  print("  Email: " .. (M.config.auth.email or "Not set"))
  print("  Token supplier: " .. (M.config.auth.token_supplier and "Configured" or "Not set"))
  print("  Pandoc enabled: " .. tostring(M.config.pandoc.enabled))
  if M.config.pandoc.enabled then
    local pandoc_available = vim.fn.executable(M.config.pandoc.executable) == 1
    print("  Pandoc available: " .. tostring(pandoc_available))
  end
  print("  Retry configuration:")
  print("    Max attempts: " .. M.config.retry.max_attempts)
  print("    Backoff type: " .. M.config.retry.backoff_type)
  print("    Initial delay: " .. M.config.retry.initial_delay_ms .. "ms")
  print("    Max delay: " .. M.config.retry.max_delay_ms .. "ms")
end

-- Main command handler
function M.command_handler(args)
  local subcommand = args.fargs[1]
  
  if subcommand == "open" then
    -- For open command, we need to handle the URL properly
    local rest_args = {}
    for i = 2, #args.fargs do
      table.insert(rest_args, args.fargs[i])
    end
    
    if #rest_args == 0 then
      vim.notify("Please provide a Confluence URL", vim.log.levels.ERROR)
      return
    end
    
    -- Join the URL parts back together (in case URL was split by spaces)
    local url = table.concat(rest_args, " ")
    
    -- Check if it has format option
    local format = "confluence"
    if url:match("--as=orgmode") then
      format = "orgmode"
      url = url:gsub("%s*--as=orgmode%s*", ""):gsub("^%s+", ""):gsub("%s+$", "")
    end
    
    -- Call open with the URL and format
    M.open_page(url, format)
  elseif subcommand == "save" then
    M.save()
  elseif subcommand == "reload" then
    M.reload()
  elseif subcommand == "setup" then
    M.setup_info()
  else
    vim.notify("Unknown subcommand: " .. (subcommand or "none"), vim.log.levels.ERROR)
    vim.notify("Available commands: open, save, reload, setup", vim.log.levels.INFO)
  end
end

-- Simplified open function that takes URL and format directly
function M.open_page(url, format)
  format = format or "confluence"
  
  if not url then
    vim.notify("Please provide a Confluence URL", vim.log.levels.ERROR)
    return
  end
  
  local page_info, err = parse_confluence_url(url)
  if not page_info then
    vim.notify("Error parsing URL: " .. err, vim.log.levels.ERROR)
    return
  end
  
  -- Check configuration
  if not M.config.base_url or not M.config.auth.email or not M.config.auth.token_supplier then
    vim.notify("Confluence plugin not configured. Run :Confluence setup", vim.log.levels.ERROR)
    return
  end
  
  -- Validate format
  if format ~= "confluence" and format ~= "orgmode" then
    vim.notify("Unsupported format: " .. format .. ". Use 'confluence' or 'orgmode'", vim.log.levels.ERROR)
    return
  end
  
  -- Check pandoc availability for orgmode
  if format == "orgmode" then
    if not M.config.pandoc.enabled then
      vim.notify("Pandoc support not enabled. Set pandoc.enabled = true in config", vim.log.levels.ERROR)
      return
    end
    if vim.fn.executable(M.config.pandoc.executable) ~= 1 then
      vim.notify("Pandoc executable not found: " .. M.config.pandoc.executable, vim.log.levels.ERROR)
      return
    end
  end
  
  vim.notify("Loading Confluence page: " .. page_info.title .. " (format: " .. format .. ")", vim.log.levels.INFO)
  
  -- Load page content asynchronously
  api.get_page_content(page_info.page_id, function(content, version, err)
    if err then
      vim.notify("Error loading page: " .. err, vim.log.levels.ERROR)
      return
    end
    
    -- Create and setup buffer with specified format
    buffer.create_confluence_buffer(page_info, content, version, format)
    vim.notify("Confluence page loaded successfully", vim.log.levels.INFO)
  end)
end

-- Setup plugin configuration
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- Create main command with subcommands
  vim.api.nvim_create_user_command('Confluence', M.command_handler, {
    nargs = '+',
    desc = 'Confluence operations',
    complete = function(arg_lead, cmd_line, cursor_pos)
      local subcommands = { 'open', 'save', 'reload', 'setup' }
      local args = vim.split(cmd_line, '%s+')
      if #args <= 2 then
        return vim.tbl_filter(function(cmd)
          return cmd:match('^' .. arg_lead)
        end, subcommands)
      end
      return {}
    end
  })
  
  -- Don't create global autocmd - handle in buffer.lua instead
end

-- Get page data for buffer (used by buffer module)
function M._get_page_data(buf)
  return page_cache[buf]
end

-- Expose URL parsing for debugging
function M._parse_url(url)
  return parse_confluence_url(url)
end

-- Register page in cache
function M._register_page(buf, page_data)
  page_cache[buf] = page_data
  
  -- Clean up cache when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    buffer = buf,
    callback = function()
      page_cache[buf] = nil
    end,
  })
end

return M