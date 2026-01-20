local make_team_development_view_for = function(make_personal_development_view_for, members)
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
  make_team_development_view_for = make_team_development_view_for,
}
