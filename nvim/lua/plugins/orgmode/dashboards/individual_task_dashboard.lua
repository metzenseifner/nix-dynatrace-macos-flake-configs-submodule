require('plugins.orgmode.dashboards.types')

local function current_week_monday()
  local current_day = os.date("*t").wday
  local days_to_monday = (current_day == 1) and 6 or (current_day - 2)
  return os.date("%Y-%m-%d", os.time() - (days_to_monday * 24 * 60 * 60))
end

local function current_week_friday()
  local current_day = os.date("*t").wday
  local days_to_friday = (current_day == 6) and 0 or (current_day == 7) and 6 or (5 - current_day)
  return os.date("%Y-%m-%d", os.time() + (days_to_friday * 24 * 60 * 60))
end

---Creates a task dashboard for an individual team member
---@param name string The name of the team member
---@return fun(): OrgAgendaCustomCommand A function that returns the dashboard configuration
local make_individual_task_dashboard_for = function(name)
  return function()
    local portable = require('config.portable')
    local sprint = vim.fn.trim(portable.safe_system("sprint_supplier", "orgmode_sprint"))
    local sprint_num = tonumber(sprint)
    local prev_sprint = sprint_num and (sprint_num - 1) or "N/A"

    return {
      description = string.format("%s's Dashboard of Things to Do", name),
      types = {
        {
          org_agenda_overriding_header = string.format("# %s's Daily Tasks", name),
          type = "tags",
          match = string.format('+TYPE="Daily"&BY="%s"&DEADLINE<="%s +1d"', name, current_week_friday())
        },
        {
          org_agenda_overriding_header = string.format("# %s's Active Tasks", name),
          type = "tags",
          match = string.format('+TYPE="INPROGRESS"', name)
        },
        -- {
        --   org_agenda_overriding_header = string.format("# %s's Team Captain Tasks", name),
        --   type = "tags",
        --   match = string.format('+TYPE="Team Captain"&BY="%s"', name),
        -- },
        {
          org_agenda_overriding_header = string.format("# %s's Announcements", name),
          type = "tags_todo",
          match = '+TYPE="Announcement"',
        },
        {
          org_agenda_overriding_header = string.format("# %s's Follow-ups", name),
          type = "tags",
          match = string.format('+TODO="TODO"&TYPE="Follow-up"&BY="%s"', name),
        },
        {
          org_agenda_overriding_header = string.format("# %s's High Priority Items", name),
          type = "tags_todo",
          match = '+PRIORITY="A"&TODO="TODO"|+PRIORITY="A"&TODO="INPROGRESS"',
        },
        {
          org_agenda_overriding_header = string.format("# %s's Sprint %s Tickets", name, sprint ~= "" and sprint or "N/A"),
          type = "tags",
          match = string.format('BY="%s"&SPRINT="%s"', name, sprint ~= "" and sprint or "N/A"),
        },
        {
          org_agenda_overriding_header = string.format("# %s's Previous Sprint (%s) Tickets", name, prev_sprint),
          type = "tags",
          match = string.format('BY="%s"&SPRINT="%s"', name, prev_sprint),
        },
        {
          org_agenda_overriding_header = "# Initiatives",
          type = "tags",
          match = string.format('+TYPE="Initiative"')
        },
        {
          type = "tags",
          match = string.format('+TYPE="Observation"'),
          org_agenda_overriding_header = string.format("# Observations"),
        },
        {
          org_agenda_overriding_header = string.format("# %s's Agenda of Tasks with Due or Scheduled Date", name),
          type = "agenda",
          org_agenda_span = 'week',
          org_agenda_start_on_weekday = 1,
          org_agenda_remove_tags = false
        },
      }
    }
  end
end

return {
  make_task_dashboard_for = make_individual_task_dashboard_for,
}
