return {
  s("vars-format-event-timestamps", fmt([[
    {% set event_start                 = task('format_timestamps').result.event_start_cet     %}
    {% set event_timestamp             = task('format_timestamps').result.event_timestamp_cet %}
    {% set log_range_event_start       = ("%.16s") | format(event_start)                      %}
    {% set log_range_event_timestamp   = ("%.16s") | format(event_timestamp)                  %}
  ]], {}, { delimiters = "[]" })),
  s("vars-workflow-context", fmt([[
    {% set execution_id   = execution().id | default("Unknown")          %}
    {% set workflow_id    = execution().workflow.id | default("Unknown") %}
    {% set workflow_title = execution().title | default("Unknown")       %}
  ]], {}, { delimiters = "<>" })),
  s("vars-begin-comment", t("{# Variables used in content #}")),
  s("vars-end-comment", t("{# CONTENT STARTS BELOW THIS LINE #}")),
  s("content-workflow-context", fmt([[
    {% set tenant_v3_domain = "vzx38435.dev.apps.dynatracelabs.com" %}
    <https://{{ tenant_v3_domain }}/ui/apps/dynatrace.automations/workflows/{{ workflow_id }}|*Workflow:*> `{{workflow_title}}` `{{workflow_id}}`
    <https://{{ tenant_v3_domain }}/ui/apps/dynatrace.automations/executions/{{ execution_id }}|*Execution ID:*> `{{ execution_id }}`
  ]], {}, { delimiters = "[]" })),
  s("vars-davis-problem", fmt([[
    {% set davis_problem  = event()['display_id'] | default("Unknown") %}
    {% set davis_event_id = event()['event.id'] | default("Unknown")   %}
  ]], {}, { delimiters = "<>" })),
  s("content-bug-report", fmt([=[
    {# Variables used in content #}
    
    {% set timestamp_cet               =  result('format_timestamps').timestamp_cet | default(now().strftime('%Y-%m-%dT%H:%M:%S')) %}
    {% set tenant_v3_domain            = "gmg80500.dev.apps.dynatracelabs.com"                                                     %}
    {% set tickets                     = result('open_rfas') | default([[]])                                                       %}
    {% set execution_id                = execution().id | default("Unknown")                                                       %}
    {% set workflow_id                 = execution().workflow.id | default("Unknown")                                              %}
    {% set workflow_title              = execution().title | default("Unknown")                                                    %}
    {% set ticket_type                 = "bug"                                                                                     %}
    {% set source_action               = "open_bugs"                                                                               %}
    {% set jira_domain                 = "https://dt-rnd.atlassian.net"                                                            %}
    {% set ticket_emoji                = ":jira-bug:"                                                                              %}
    
    {# CONTENT STARTS BELOW THIS LINE #}
    
    {{ticket_emoji}} *{{ticket_type | title}} Report for Team Platinum -- {{ timestamp_cet }}*
    
    <https://{{ tenant_v3_domain }}/ui/apps/dynatrace.automations/workflows/{{ workflow_id }}|*Workflow:*> `{{workflow_title}}` `{{workflow_id}}`
    <https://{{ tenant_v3_domain }}/ui/apps/dynatrace.automations/executions/{{ execution_id }}|*Execution ID:*> `{{ execution_id }}`
    
    {{ ':alert: ' if (tickets | length > 0) }} There {{ 'is *1* open ' + ticket_type + ' ticket' if (tickets | length) == 1 else 'are *%s* open ' % (tickets | length) + ticket_type + ' tickets for the team.'  }}
    
    {% for issue in tickets | sort(attribute='fields.priority.id') %}
      `- [[ ]]` `{{issue.fields.issuetype.name | center(15)}}` `Priority: {{issue.fields.priority.name}}` `{{ issue.fields.status.name | center(15) }}` `{{issue.fields.created | truncate(10, killwords=True, end='') }}` `{{ issue.fields.assignee.name | center(21) }}` `{{issue.fields.components | join(',', attribute='name')}}` <https://{{jira_domain}}/browse/{{ issue.key }}>
    {% endfor %}
    
    :point_right: <https://dynatrace.sharepoint.com/sites/RnD/SitePages/Bugs-First!-Policy.aspx|Bugs First! Policy> :point_right: <https://dynatrace.sharepoint.com/sites/AgileCompetenceCenter/SitePages/Priorities.aspx?web=1|Bug Priorities>
  ]=], {}, { delimiters = "[]" }))
}
