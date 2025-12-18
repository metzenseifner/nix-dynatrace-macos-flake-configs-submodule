function generate_snippets()
  snippets = {}

  function get_board_url()
    return
    "https://dev-jira.dynatrace.org/secure/RapidBoard.jspa?rapidView=1983&view=planning.nodetail&quickFilter=20141&issueLimit=100"
  end

  table.insert(snippets,
    s("jira-markdown-docs",
      { t("https://support.atlassian.com/jira-software-cloud/docs/markdown-and-keyboard-shortcuts/") }))

  table.insert(snippets, s("research-jira-ticket", fmt([=[
    *Timebox*: ? Day

    [what]

    ## Desired Outcome

    ## Extra information

  ]=], { what = i(1, "what is being investigated") }, { delimiters = "[]" })))

  table.insert(snippets, s("story-jira-ticket-issue", fmt([=[
    # Goal

    [goal] 

    ## Context

      - [motivation]

    ## Example

    ```
    [code]
    ```

    ## Acceptance Criteria

      - [acceptance_criteria]

    ## Related Information / Technical Details

      - [info]

# Guide from https://dynatrace.sharepoint.com/sites/VCG/SitePages/User-Story.aspx
   User Stories should adhere to the acronym INVEST, which stands for: 
Independent	
    - of order related to other User Stories to deliver
    - of internal and especially external dependencies
Negotiable	
    - Flexible scope
    - Explain the intention/need/pain, not the implementation
Valuable	
    - Value is clear to everyone
    - Persona matches benefit and the goal will deliver the benefit
Estimatable	
    - Development Team is able to size/estimate the story to get a rough idea of the effort, risk/uncertainty, and complexity
Small	
    - fits into a sprint
Testable	
    - can be tested/automated

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
