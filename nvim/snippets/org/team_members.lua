local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local ms = ls.multi_snippet

-- Function to get dynamic triggers
local function get_dynamic_triggers()
  if vim.fn.executable("yaml-supplier") ~= 1 then
    return { "team-member-unavailable" }
  end
  
  local ok, result = pcall(vim.fn.system, "yaml-supplier --key team_members")
  if not ok or result == "" then
    return { "team-member-unavailable" }
  end
  
  local choices = vim.split(result, '\n')
  local triggers = {}
  for _, value in ipairs(choices) do
    if value ~= "" then
      table.insert(triggers, value)
    end
  end
  return #triggers > 0 and triggers or { "team-member-unavailable" }
end

-- Function to create snippets with dynamic triggers
local function create_dynamic_snippets()
  local triggers = get_dynamic_triggers()
  local snippets = {}
  for _, trigger in ipairs(triggers) do
    table.insert(snippets, s(trigger, {
      f(function() return trigger end),
    }))
  end
  return snippets
end

return create_dynamic_snippets()
