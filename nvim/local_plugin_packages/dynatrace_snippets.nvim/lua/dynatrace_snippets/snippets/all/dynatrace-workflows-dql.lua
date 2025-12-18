return {
  s("fetch-errors-with-trace-id", fmt([[
    fetch logs
     | filter trace_id == "{{ event()['trace_id'] }}"
       AND matchesValue(loglevel, "ERROR")
     | fields status, content
  ]], {}, { delimiters = "<>" }))
}
