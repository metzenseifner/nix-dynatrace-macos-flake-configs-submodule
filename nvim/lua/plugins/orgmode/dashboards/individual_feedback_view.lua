require('plugins.orgmode.dashboards.types')

---Creates a team-wide feedback dashboard by combining individual feedback views
---@param make_individual_feedback_view_for fun(name: string): OrgAgendaCustomCommand Factory function for individual views
---@param members string[] Array of team member names
---@return OrgAgendaCustomCommand The combined team dashboard configuration
local make_team_feedback_view_for = function(make_individual_feedback_view_for, members)
  local member_boards = {}
  for _, member in ipairs(members) do
    vim.list_extend(member_boards, make_personal_development_view_for(member).types)
  end
  return {
    description = "Team CARE's Development Dashboard",
    types = member_boards
  }
end

return {
  make_team_feedback_view_for = make_team_feedback_view_for,
}
