return {
  s("dql-github-prs", fmt([[
    fetch events
    | filter contains(dt.openpipeline.source, "github")
    | filter number == 376007 AND action == "opened"
  ]], {}, { delimiters = "<>" })),
  s("dql-exec of dtp-orchestrator", fmt([[
    fetch logs, scanLimitGBytes: -1, from:"2025-04-02T09:59", to:"2025-04-02T10:10"
    | filter contains (k8s.pod.name, "metainfo-cronworkflow-nonprod")
    | filter contains(content, "starting generating metainfo for repo")
    | fields timestamp, content, k8s.pod.name
    | sort timestamp desc
  ]], {}, {})),
  s("dql-rename", fmt([[
    | fieldsRename workflow_id = `request_attribute.Automation Workflow ID`
  ]], {}, {})),
  s("dql-summarize", fmt([[
    // https://docs.dynatrace.com/docs/platform/grail/dynatrace-query-language/commands/aggregation-commands#summarize
    // summarize [optional_field_name = ] aggregation function, ... [, by: {[field =] expression to group by, ...}]
    | summarize count = count(), avg(duration_seconds), min(duration_seconds), max(duration_seconds) , stddev(duration_seconds)}, by:{workflowname}


    e.g.

    data record(a = 2),
     record(a = 3),
     record(a = 7),
     record(a = 7),
     record(a = 1)
    | summarize avg(a)


    e.g.

    fetch events
    | filter event.kind == "SDLC_EVENT" AND matchesPhrase(event.type, "phasedrelease")
    | summarize {count=count()}, by: {event.type}
  ]], {}, { delimiters = "<>" })),
  s("entity-name-to-entity-id-for-cloud-applications", fmt([[
    fetch dt.entity.cloud_application
      | fields entity.name, id, tags
      | filter matchesPhrase(entity.name, "email-control")
  ]], {}, { delimiters = "[]" })),
  s("filter-custom-alert-by-app-id", fmt([[
    event.type == "CUSTOM_ALERT"
    AND event.kind == "DAVIS_EVENT"
    AND event.status == "ACTIVE"
    AND (
      event.name == "dynatrace.jira"
      OR event.name == "dynatrace.microsoft365.connector"
      OR event.name == "dynatrace.email"
    )
  ]], {}, { delimiters = "[]" })),
  s("dql-fetch-email-service-sprint", fmt([[
    fetch logs //, scanLimitGBytes: 500, samplingRatio: 1000
      | filter matchesValue(dt.kubernetes.cluster.name, "dtp-hard-csc-central-services")
u       and matchesValue(k8s.namespace.name, "email-service")
        and matchesValue(loglevel, "ERROR")
      | sort timestamp desc
  ]], {}, { delimiters = "[]" })),
  s("dql-fetch-log-emitted-within-automation", fmt([[
    // scanLimitGBytes: -1 is equivalent to no limit on how many bytes to scan
    fetch logs, scanLimitGBytes: -1
      | filter dt.process.name == "automation-server-engine"
      | filter contains(content, "something else")
  ]], {}, { delimiters = "[]" })),
  s("dql-fetch-errors-for-platinum-apps", fmt([[
     // scanLimitGBytes: -1 is equivalent to no limit on how many bytes to scan
     fetch logs, from:now()-24h, to: now(), scanLimitGBytes: -1
      | filter matchesValue(loglevel, "ERROR") AND (dt.app.id == "dynatrace.slack" OR dt.app.id == "dynatrace.jira")
      | fields timestamp, dt.tenant.uuid, dt.app.id, status = upper(loglevel), content
      | sort timestamp desc
  ]], {}, { delimiters = "[]" })),
  s("dql-trace", fmt([[
    fetch logs, scanLimitGBytes: -1
      | filter matchesValue(trace_id, "[trace_id]")
      | fields timestamp, dt.tenant.uuid, dt.app.id, status = upper(loglevel), content
      | sort timestamp desc
  ]], { trace_id = i(1, "traceID") }, { delimiters = "[]" })),
  s("dql-time-expressions", fmt([[
    // Time Range
    from:-24h, to:-2h

    // Time Range Referencing Current Time
    from:now()-7d,

    // Time Frame / Span Using Timestamps
    timeframe:"2021-10-20T00:00:00Z/2021-10-28T12:00:00Z"

    // A specific Day in Zulu+2 hours / CEST
    fetch logs, timeframe:"2023-09-14T00:00:00+02:00/2023-09-14T23:59:59+02:00", scanLimitGBytes: -1
    | filter matchesValue(loglevel, "ERROR") AND (dt.app.id == "dynatrace.jira")
    | fields timestamp, dt.tenant.uuid, dt.app.id, status = upper(loglevel), content
    | sort timestamp desc
  ]], {}, {})),

  s("dql-filter-using-keys-value-is-in-array", fmt([[
    // scanLimitGBytes: -1 is equivalent to no limit on how many bytes to scan
    fetch logs, from:now()-24h, to: now(), scanLimitGBytes: -1
    | filter matchesValue(loglevel, "ERROR") AND in(dt.app.id, array("dynatrace.jira","dynatrace.microsoft365.connector"))
    | fields timestamp, dt.tenant.uuid, dt.app.id, status = upper(loglevel), content
    | sort timestamp desc
  ]], {}, {}))
}
