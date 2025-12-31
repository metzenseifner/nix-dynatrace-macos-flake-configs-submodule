-- lua/json_menu.lua
-- A simple JSON actions picker using vim.ui.select
local M = {}

-- Define actions (reuse your safe wrappers)
local actions = {
  { label = "Pretty-print buffer (jq .)",   run = function() require('json_fmt').buf_pretty() end },
  { label = "Minify buffer (jq -c .)",      run = function() require('json_fmt').buf_minify() end },
  { label = "Sort keys buffer (jq -S .)",   run = function() require('json_fmt').buf_sort_keys() end },

  { label = "Pretty-print selection (jq .)", run = function() require('json_fmt').sel_pretty() end },
  { label = "Minify selection (jq -c .)",    run = function() require('json_fmt').sel_minify() end },
  { label = "Sort keys selection (jq -S .)", run = function() require('json_fmt').sel_sort_keys() end },

  { label = "Expand JSON string → JSON (visual)",   run = function() require('json_str').expand_visual_string() end },
  { label = "Collapse JSON → JSON string (visual)", run = function() require('json_str').collapse_visual_value() end },
}

-- If you're in visual mode, prefer selection-oriented actions at the top
local function sorted_actions_for_mode()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "V" or mode == "\22" then  -- visual, line, block
    local sel = {}
    local buf = {}
    for _, a in ipairs(actions) do
      if a.label:find("selection") or a.label:find("string") then
        table.insert(sel, a)
      else
        table.insert(buf, a)
      end
    end
    -- selection-first
    for _, a in ipairs(buf) do table.insert(sel, a) end
    return sel
  end
  return actions
end

function M.open()
  local items = sorted_actions_for_mode()
  local opts = {
    prompt = "JSON actions",
    format_item = function(item) return item.label end,
  }
  vim.ui.select(items, opts, function(choice)
    if choice and choice.run then choice.run() end
  end)
end

return M
