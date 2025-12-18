return {
  s("slack-filter-by-date", fmt([[
    # Format: YYYY-MM-DD
    before:<before> after:<after> in:<channel>
    ]], {after=i(1,"2025-01-01"), before=i(2, "2025-01-02"), channel=i(3, "#argo-workflow-notifications-team-care")}, {delimiters="<>"}))
}
