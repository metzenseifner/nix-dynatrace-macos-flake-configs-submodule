return {
  s("todo-first-responder", fmt([[
    # [First Responder Responsibilities](https://dev-wiki.dynatrace.org/display/ACE/First+Responder) / What should I do? / What's in the scope of this role?

    Upon encountering a problem, decide whether it already has been fixed. Otherwise, open a Bug ticket.


    ## How to Open a Bug Ticket

    - Create and assign to Team Platinum.
    - Add correct component i.e. Jira for Workflows
    - Provide as much information as possible:
      - date+time
      - tenant uuid
      - environment (dev, hardening, sprint)
      - Links to selfmonitoring/logs (so that the next person does not have to fish around for the same log entries)
      - (optional) app version (if known)
        sometimes this is tricky to find out because we do not have access to all tenants in a given SaaS stage)
        There are ideas floating around to remedy this in the future.

    ## Task List

    - [ ] A story for booking your time should exist, created by previous First Responder. Otherwise, create a story, assigning to yourself in the current sprint.
          This ticket also serves to identify the current first respond by ownership of ticket.

      - [ ] Investigate notifications in channel [#team-ca-platinum-selfmonitoring](https://dynatrace.slack.com/archives/C054N06GRSA), and put a :green_heavy_check_mark: on all the notifications you have investigated.

      - [ ] Check for log entries for all stages / SaaS environments in the respective self-monitoring environments: dev | staging | prod
        - [Self-monitor of dev SaaS Logs](https://deve2e.dev.dynatracelabs.com/ui/logs-events?advancedQueryMode=true&visualizationType=table&isDefaultQuery=false&gtf=-2h&gf=all&query=%2F%2F%20scanLimitGBytes:%20-1%20is%20equivalent%20to%20no%20limit%20on%20how%20many%20bytes%20to%20scan%0Afetch%20logs,%20from:now()-24h,%20to:%20now(),%20scanLimitGBytes:%20-1%20%20%0A%7C%20filter%20matchesValue(loglevel,%20%22ERROR%22)%20AND%20(dt.app.id%20%3D%3D%20%22dynatrace.slack%22%20OR%20dt.app.id%20%3D%3D%20%22dynatrace.jira%22)%20%20%20%20%20%20%20%0A%7C%20fields%20timestamp,%20dt.tenant.uuid,%20dt.app.id,%20status%20%3D%20upper(loglevel),%20content%0A%7C%20sort%20timestamp%20desc%0A&sortDirection=desc&visibleColumns=timestamp&visibleColumns=status&visibleColumns=content)
        - [Self-monitor of sprint SaaS Logs](https://eva38390.sprint.dynatracelabs.com/ui/logs-events?advancedQueryMode=true&visualizationType=table&isDefaultQuery=false&gtf=-2h&gf=all&query=%2F%2F%20scanLimitGBytes:%20-1%20is%20equivalent%20to%20no%20limit%20on%20how%20many%20bytes%20to%20scan%0Afetch%20logs,%20from:now()-24h,%20to:%20now(),%20scanLimitGBytes:%20-1%20%20%0A%7C%20filter%20matchesValue(loglevel,%20%22ERROR%22)%20AND%20(dt.app.id%20%3D%3D%20%22dynatrace.slack%22%20OR%20dt.app.id%20%3D%3D%20%22dynatrace.jira%22)%20%20%20%20%20%20%20%0A%7C%20fields%20timestamp,%20dt.tenant.uuid,%20dt.app.id,%20status%20%3D%20upper(loglevel),%20content%0A%7C%20sort%20timestamp%20desc%0A&sortDirection=desc&visibleColumns=timestamp&visibleColumns=status&visibleColumns=content)
        - [Self-monitor of prod SaaS Logs](https://ntd44713.live.dynatrace.com/ui/logs-events?advancedQueryMode=true&visualizationType=table&isDefaultQuery=false&gtf=-2h&gf=all&query=%2F%2F%20scanLimitGBytes:%20-1%20is%20equivalent%20to%20no%20limit%20on%20how%20many%20bytes%20to%20scan%0Afetch%20logs,%20from:now()-24h,%20to:%20now(),%20scanLimitGBytes:%20-1%20%20%0A%7C%20filter%20matchesValue(loglevel,%20%22ERROR%22)%20AND%20(dt.app.id%20%3D%3D%20%22dynatrace.slack%22%20OR%20dt.app.id%20%3D%3D%20%22dynatrace.jira%22)%20%20%20%20%20%20%20%0A%7C%20fields%20timestamp,%20dt.tenant.uuid,%20dt.app.id,%20status%20%3D%20upper(loglevel),%20content%0A%7C%20sort%20timestamp%20desc%0A&sortDirection=desc&visibleColumns=timestamp&visibleColumns=status&visibleColumns=content)

    - [ ] Main Branch Build Check (Jenkins Pipeline)
      - [ ] Decision Point: If it is a temporary fluke (e.g., SSO problems, Platform
      temporarily down), then re-trigger the pipeline. For other cases, create a Bug
      ticket with link to failing build. [Example
      Ticket](https://dev-jira.dynatrace.org/browse/CA-3614)
      - [ ] Add :green_heavy_check_mark: for entries daily here: [#team-ca-platinum-pipeline](https://dynatrace.slack.com/archives/C054UJGH21G)
      - [ ] [Jira for Workflows main Builds (Blue Ocean)](https://dynatrace-apps-jenkins.ci.dynalabs.io/blue/organizations/jenkins/DynatraceApps%2Fjira-app/activity/?branch=main); [Jira for Workflows main Builds (Jenkins UI)](https://dynatrace-apps-jenkins.ci.dynalabs.io/job/DynatraceApps/job/jira-app/job/main/)
      - [ ] Report about build issues either at our Standup or in [#team-ca-platinum](https://dynatrace.slack.com/archives/C0547SE6PTN)

    - [ ] Regularly Monitor Slack Channels for News
      Open RFA if it involes more than 10m work, or if it originates from a Support Engineer. Assign ticket to Team Platinum.
      - [ ] [#int-cap-cloudautomation](https://dynatrace.slack.com/archives/C03V4AS0495)
      - [ ] [#help-cloud-automation-solution](https://dynatrace.slack.com/archives/C011DUELHFG)
      - [ ] [#help-workflow](https://dynatrace.slack.com/archives/C029P7AG909)
      - [ ] [#help-log-monitoring for issues with the self-monitoring environments](https://dynatrace.slack.com/archives/C7H2U4M6K/p1683723464145139)

    - [ ] Open Story ticket for next First Responder and assign it to that person.
    - [ ] Close your story and link to next First Responder ticket (relation: "relates to")

  ]], {}, {delimiters="<>"})),
  s("todo-team-captain", fmt([[
    # [Team Captain Responsibilities](https://dynatrace.sharepoint.com/sites/RnD/SitePages/Team-Captain.aspx)

    Responsibilities

    - [ ] **Mentors team members** and helps along their growth path in Dynatrace (e.g. empowering team members to take over more responsibilities)
    - [ ] Conducts **1:1** and [**Personal feedback talks** ](https://dynatrace.sharepoint.com/sites/Career_Dev/SitePages/Personal-Feedback-Talk.aspx?csf=1&web=1&e=lp4nMV&cid=a0581885-ad8f-4171-b0bd-12e74c4ca47fhttp%3a//http%3a//)with team members
    - [ ] Organizes team events
    - [ ] Cares about collaboration, motivation, and performance within the team
    - [ ] Encourages team members to share knowledge
    - [ ] Carries out administrative management tasks (e.g. administers time tracking, [DT Teams](https://teams.internal.dynatrace.com/))
    - [ ] **Advocates Dynatrace's culture**
    - [ ] Works on team-level impediments based on feedback and metrics and resolves conflicts
    - [ ] **Makes promotion suggestions** for team members
    - [ ] Provides information about staffing needs
    - [ ] **Conducts interviews** and reviews candidates
    - [ ] Informs team about company decisions or updates and implements them on a team level
    - [ ] Acts as a gatekeeper for team well-being and provides general team pulse to Manager/Director

    Interactions / Interface

    Team
    
    - gets:
      - Employee enablement (support for personal development, career guidance, ...)
      - Impediment removal and conflict resolution 
      - Context for strategic topics and ongoing initiatives and changes 
      - Mentoring 
      - Personal feedback 
    - gives: 
      - Feedback on individual job satisfaction
      - Suggestions for improvements 
      - Alerts for potential risks 
      - Expectations on the career path 
    
    Manager/Director
    
    - gets:
      - Team Captain feedback and aggregated team feedback 
      - Suggestions for improvements 
      - Alerts for potential risks 
      - Input on team happiness and team member assignments, job satisfaction, and career path 
      - Recruiting input and feedback on candidates 
    - gives: 
      - Consultation 
      - Information (strategic topics, planned changes) 
      - Team updates 
      - Impediment and conflict resolution 
    
    Agile Coach
    
    - gets: commitment, support, and drive for needed agreed changes
    - gives: mentoring and support with Agile practices and team setup
    
    Team Captain peers
    
    - gets/gives: sharing lessons learned and spreading good practices. Mentoring, info, and knowledge exchange

    Out of scope

    - Not responsible for the team backlog  
    - Not the gatekeeper between the team and product needs
    - Not the Master of Ceremonies
  ]], {}, {delimiters="<>"}))
}
