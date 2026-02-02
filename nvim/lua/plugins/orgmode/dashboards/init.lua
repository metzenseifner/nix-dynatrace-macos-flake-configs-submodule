require('plugins.orgmode.dashboards.types')

local M = {}

local individual_task_dashboard = require('plugins.orgmode.dashboards.individual_task_dashboard')
local individual_development_view = require('plugins.orgmode.dashboards.individual_development_view')
local team_development_view = require('plugins.orgmode.dashboards.team_development_view')

---Factory function to create a task dashboard for a team member
---@type fun(name: string): fun(): OrgAgendaCustomCommand
M.make_task_dashboard_for = individual_task_dashboard.make_task_dashboard_for

---Factory function to create a development view for a team member
---@type fun(name: string): OrgAgendaCustomCommand
M.make_personal_development_view_for = individual_development_view.make_personal_development_view_for

---Factory function to create a team-wide development dashboard
---@type fun(make_personal_development_view_for: fun(name: string): OrgAgendaCustomCommand, members: string[]): OrgAgendaCustomCommand
M.make_team_development_view_for = team_development_view.make_team_development_view_for

-- Generate dynamic team member development views
---@param team_members_str string Newline-separated list of team member names
---@return table[] Array of view objects with name and view fields
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
---@param team_members_str string Newline-separated list of team member names
---@return table<string, OrgAgendaCustomCommand> Map of keyboard shortcuts to agenda commands
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
