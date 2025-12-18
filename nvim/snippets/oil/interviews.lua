return {
  s({ trig = "interview-file-templates", desc = "Generate Interview Files" }, fmt([[
    <year> - <name> for <team>/{<year> - Interview Agenda - <name>.org, <year> - Interview 2nd Round Review - <name>.org}
  ]],
    {
      year = f(function(values) return vim.fn.trim(vim.fn.system([[date '+%Y']])) end, {}),
      name = d(1, function(args, parent)
        if (#parent.snippet.env.LS_SELECT_RAW > 0) then
          return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
        else -- If LS_SELECT_RAW is empty, return a blank insert node
          return sn(nil, i(1, "<name>"))
        end
      end
      ),
      team = i(2, "Team CARE")
    }, { repeat_duplicates = true, delimiters = "<>" })
  )
}
