-- Functional diagnostic popup utilities
-- Provides flexible, extensible diagnostic popup functionality using functional design principles

local M = {}

-- Pure function: Creates default options for diagnostic float window
-- @return table: Default float window options
local function default_float_opts()
  return {
    scope = "cursor",
    focusable = false,
    close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre" },
    border = "rounded",
    source = "if_many",
    prefix = " ",
  }
end

-- Pure function: Creates options for full diagnostic display (no truncation)
-- @return table: Float window options with unlimited width
local function full_diagnostic_opts()
  local opts = default_float_opts()
  opts.max_width = nil  -- Remove width limit
  opts.max_height = nil -- Remove height limit
  opts.wrap = true      -- Enable text wrapping
  opts.focus = false    -- Don't steal focus
  return opts
end

-- Pure function: Merges user options with defaults
-- @param user_opts table|nil: User-provided options
-- @param base_opts table: Base options to merge with
-- @return table: Merged options table
local function merge_opts(user_opts, base_opts)
  if not user_opts then
    return base_opts
  end
  return vim.tbl_deep_extend("force", base_opts, user_opts)
end

-- Pure function: Checks if cursor has moved since last invocation
-- @param current_cursor table: Current cursor position [row, col]
-- @param last_cursor table|nil: Last cursor position [row, col]
-- @return boolean: True if cursor has moved
local function cursor_moved(current_cursor, last_cursor)
  if not last_cursor or not last_cursor[1] or not last_cursor[2] then
    return true
  end
  return current_cursor[1] ~= last_cursor[1] or current_cursor[2] ~= last_cursor[2]
end

-- Higher-order function: Creates a popup handler with custom options
-- @param opts_fn function: Function that returns float window options
-- @param debounce boolean: Whether to debounce (only show once per cursor position)
-- @return function: Configured popup handler
function M.create_popup_handler(opts_fn, debounce)
  opts_fn = opts_fn or default_float_opts
  debounce = debounce == nil and true or debounce
  
  return function()
    local current_cursor = vim.api.nvim_win_get_cursor(0)
    
    if debounce then
      local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }
      
      if not cursor_moved(current_cursor, last_popup_cursor) then
        return
      end
      
      vim.w.lsp_diagnostics_last_cursor = current_cursor
    end
    
    local float_opts = opts_fn()
    vim.diagnostic.open_float(0, float_opts)
  end
end

-- Factory function: Creates a full diagnostic popup handler (shows complete message)
-- @param user_opts table|nil: Optional user-provided options
-- @return function: Handler that shows full diagnostics
function M.create_full_diagnostic_handler(user_opts)
  return M.create_popup_handler(function()
    return merge_opts(user_opts, full_diagnostic_opts())
  end, false) -- No debounce for manual invocation
end

-- Factory function: Creates a debounced popup handler (for auto-show on cursor hold)
-- @param user_opts table|nil: Optional user-provided options
-- @return function: Debounced handler
function M.create_debounced_handler(user_opts)
  return M.create_popup_handler(function()
    return merge_opts(user_opts, default_float_opts())
  end, true)
end

-- Convenience function: Show full diagnostic popup immediately
-- @param user_opts table|nil: Optional user-provided options
function M.show_full_diagnostic(user_opts)
  local handler = M.create_full_diagnostic_handler(user_opts)
  handler()
end

-- Convenience function: Show debounced diagnostic popup
-- @param user_opts table|nil: Optional user-provided options
function M.show_debounced_diagnostic(user_opts)
  local handler = M.create_debounced_handler(user_opts)
  handler()
end

return M
