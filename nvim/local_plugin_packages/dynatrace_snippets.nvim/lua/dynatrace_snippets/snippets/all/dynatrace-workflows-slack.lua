return {
  s("format-event-timestamps", fmt([[
    {% set event_start                 = task('format_timestamps').result.event_start_cet     %}
    {% set event_timestamp             = task('format_timestamps').result.event_timestamp_cet %}
    {% set log_range_event_start       = ("%.16s") | format(event_start)                      %}
    {% set log_range_event_timestamp   = ("%.16s") | format(event_timestamp)                  %}
  ]], {}, { delimiters = "[]" }))
}
