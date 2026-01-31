local template = [=[
** Team pulse: Healthy / At risk / Unhealthy — brief reason

** Top risks and impediments: description | owner | due date | support needed

** Decisions needed from the manager: decision | deadline | impact if delayed

** Staffing: workload and capacity, vacations, coverage gaps, upcoming needs

** Recruiting: pipeline status, interview feedback, recommendations

** People growth: promotion suggestions, development plans, recognition

** Compliance and administration: time booking status and actions

** Company updates: what was communicated and implemented; gaps or follow‑ups
]=]

return {
  s("dev-manager-one-on-one", fmt(template, {}, { delimiters = "{}" }))
}
