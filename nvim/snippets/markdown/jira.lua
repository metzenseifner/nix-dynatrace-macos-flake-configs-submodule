return {
  -- TODO replace with regex
  s("ticket-markdown", fmt([[
    [<ticketnr>](https://dev-jira.dynatrace.org/browse/<ticketnr>)
  ]], { ticketnr = i(1, "ticketnr") }, { delimiters = "<>", repeat_duplicates = true })),
  s("code", fmt([[
    ```
    <body>
    ```
  ]], { body = i(1, "body") }, { delimiters = "<>" }))
}
