function generate_snippets()
  snippets = {}

  function get_board_url()
    return
    "https://dev-jira.dynatrace.org/secure/RapidBoard.jspa?rapidView=1983&view=planning.nodetail&quickFilter=20141&issueLimit=100"
  end

  table.insert(snippets, s("research-jira-ticket", fmt([=[
    {*}Timebox: 1 Day{*}

    {panel:title=Investigate|borderStyle=dashed|borderWidth=1em|borderColor=#17202a|titleBGColor=#F4F5F7|bgColor=#fbfcfc}
     [what]
    {panel}

    {*}Actual Behavior{*}

    {*}Expected Behavior{*}

    {*}Extra information{*}

  ]=], { what = i(1, "what is being investigated") }, { delimiters = "[]" })))

  table.insert(snippets, s("story-jira-ticket-issue", fmt([=[
    {panel:title=Goal|borderStyle=dashed|borderWidth=1em|borderColor=#17202a|titleBGColor=#F4F5F7|bgColor=#fbfcfc}
    [goal] 
    {panel}

    {*}Motivation{*}

      * [motivation]

    {*}Example{*}

    {code:title=path/to/file.ts|borderStyle=solid}
    [code]
    {code}

    {*}Related Information{*}

      * [info]

    {*}Acceptance Criteria{*}

      * [acceptance_criteria]
  ]=],
    {
      goal = i(1, "goal (what, why)"),
      motivation = i(2, "motivation"),
      code = i(3, "code"),
      info = i(4, "extras"),
      acceptance_criteria = i(5, "acceptance criteria")
    }, { delimiters = "[]" })))


  table.insert(snippets, s("bug-jira-ticket-issue", fmt([[
   # What

   [what] 

   # Current State of Affairs

     - [is_state]

   # Expected State of Affairs

     - [should_state]

   # How to Reproduce

     1. 

   # Related Information

     - [info]

   DQL Query:

   ```
   [dql]
   ```

  ]],
    {
      what = i(1, "what"),
      is_state = i(2, "is"),
      should_state = i(3, "should be"),
      info = i(4, "related info"),
      dql = i(5, "dql")
    }, { delimiters = "[]" })))

  table.insert(snippets, s("link-atlassian", fmt([[
    [{label}|{url}]{eof}
  ]], { url = i(1, "URL"), label = i(2, "Label"), eof = i(0) })))

  table.insert(snippets, s("ticket-jira", fmt([[
    [{ticket}|https://dev-jira.dynatrace.org/browse/{ticket}]{eof}
  ]], { ticket = i(1, "ticketref"), eof = i(0) }, { repeat_duplicates = true })))


  return snippets
end

return generate_snippets()
