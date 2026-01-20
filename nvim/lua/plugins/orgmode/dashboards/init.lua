local M = {}

local personal_dashboard = require('plugins.orgmode.dashboards.personal_dashboard')
local development_view = require('plugins.orgmode.dashboards.development_view')
local team_development_view = require('plugins.orgmode.dashboards.team_development_view')

M.make_dashboard_for = personal_dashboard.make_dashboard_for
M.make_personal_development_view_for = development_view.make_personal_development_view_for
M.make_team_development_view_for = team_development_view.make_team_development_view_for

-- Generate dynamic team member development views
M.generate_team_member_views = function(team_members_str)
  local team_members = team_members_str ~= "" and vim.split(team_members_str, '\n') or {}
  local views = {}
  
  for _, member in ipairs(team_members) do
    if member ~= "" then
      table.insert(views, {
        name = member,
        view = M.make_personal_development_view_for(member)
      })
    end
  end
  
  return views
end

-- Generate keyboard shortcuts dynamically for team member views
-- Returns a table mapping keys to views
M.generate_team_member_shortcuts = function(team_members_str)
  local team_members = team_members_str ~= "" and vim.split(team_members_str, '\n') or {}
  local shortcuts = {}
  
  -- Use lowercase letters starting from 'a', skipping reserved keys
  local reserved_keys = { d = true, u = true, s = true, g = true }
  local key_index = string.byte('a')
  
  for _, member in ipairs(team_members) do
    if member ~= "" then
      local key = string.char(key_index)
      
      -- Skip reserved keys
      while reserved_keys[key] do
        key_index = key_index + 1
        key = string.char(key_index)
      end
      
      shortcuts[key] = M.make_personal_development_view_for(member)
      key_index = key_index + 1
    end
  end
  
  return shortcuts
end

return M
