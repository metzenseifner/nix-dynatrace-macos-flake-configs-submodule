-- links:
--   topic:
--     - link1:
--     - link2:
--     - link3:
--
--     topic should be a snippet the writes all links to output
--     each link should use its trigger for its content
--
local links = {
  videmo = {
    { url = "https://dynatrace.sharepoint.com/:v:/r/sites/Automations/Shared%20Documents/Video%20recordings/Product%20Demos/2024-02-29%20VI%20Demo%20Emails%20in%20Workflows.mp4?csf=1&web=1&e=Qok1gX",                                          name = "recording-emails-and-ms365" },
    { url = "https://dynatrace.sharepoint.com/:p:/r/sites/Automations/Shared%20Documents/Video%20recordings/VI%20Demo%20Email/20240229_VIDemo_Microsoft365-and-Email-for-workflows.pptx?d=wc5fa429cc8e342f98d8b9eae6fd512fb&csf=1&web=1&e=JM3JTS", name = "slides-emails-and-ms365" },
  },
  carpe = {
    { url = 'https://dynatrace.sharepoint.com/sites/dynatrace.carpe/SitePages/home.aspx', name = 'Sharepoint CARPE Home',          description = 'Cloud Application Readiness Peer Enablement' },
    { url = 'https://dev-wiki.dynatrace.org/display/ruxit/CARPE',                         name = 'dev-wiki CARPE' },
    { url = 'https://a-string-with-config',                                               name = 'a string url with object config' },
    'https://a-string',
    { url = 'https://nam02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdynatrace.sharepoint.com%2F%3Au%3A%2Fr%2Fsites%2FCARPE%2FSitePages%2FWhat-CARPE-pro.aspx%3Fcsf%3D1%26web%3D1%26share%3DEfOXtl5rvwpIqCeELgjNYFwB-R-mQQ195OVbBIERfXqLoQ%26e%3D4%253acNVvys%26fromShare%3Dtrue%26at%3D9&data=05%7C01%7Cjonathan.komar%40dynatrace.com%7C43d7d5a5ffe8435cb0a108dbe6ae1051%7C70ebe3a35b30435d9d677716d74ca190%7C1%7C0%7C638357407494680269%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=8%2BkHEa5h5ijzzT3WuP1Sk1OZHLcU6kKRNJ2LKAxoXCQ%3D&reserved=0',                                          name = "[DRAFT] Self-monitoring: Let's break the myth around it and make it our reality" },
    { url = 'https://nam02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdynatrace.sharepoint.com%2F%3Au%3A%2Fr%2Fsites%2FCARPE%2FSitePages%2FTasks-we-are-currently-performing-and-are-responsible-for.aspx%3Fcsf%3D1%26web%3D1%26share%3DETF5rWmYNbFBm6ErH2onX6cBE9ktfQMxL8tOnIo4MyA7-A%26e%3D4%253agXtzLG%26fromShare%3Dtrue%26at%3D9&data=05%7C01%7Cjonathan.komar%40dynatrace.com%7Cf042c9548f3f4fb5dfb608dbe6adf325%7C70ebe3a35b30435d9d677716d74ca190%7C1%7C0%7C638357407045464005%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=C36HiS4vFnCqZ5Aw6KjQuuNPC63E3EvPVz1JeuGp3n0%3D&reserved=0', name = "[DRAFT] Tasks we are currently performing and are responsible for" },
    { url = "https://dynatrace.sharepoint.com/sites/SRSECOPS/SitePages/LCC-Launch-Coordination-Checklist.aspx",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              name = "LCC Launch Coordination Checklist" }
  },
  saas = {
    { url = 'https://myaccount-hardening.dynatracelabs.com/account/license/overview?account-uuid=15bee47a-a120-4d60-ade0-e19f96f2aeee', description = 'Overview of Sprint/Hardening License ' },
    { url = 'https://myaccount-hardening.dynatracelabs.com/accounts',                                                                   name = 'Sprint/Hardening Accounts' }
  },
  monaco = {
    { url = "https://hub.docker.com/r/dynatrace/dynatrace-configuration-as-code",                                              name = "monaco-docker-image" },
    { url = "https://gotemplate.io",                                                                                           name = "monaco-go-template-preview" },
    { url = "https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/site_reliability_guardian_sample", name = "deploy-a-workflow" },
  },
  git = {
    { url = "https://www.conventionalcommits.org/", name = "Conventional Commits" },
  },
  jenkins = {
    { url = 'https://dynatrace-apps-jenkins.ci.dynalabs.io/job/dynatrace-app-projects/job/jira-app/job/prod/job/main/',              name = 'jira-prod-(main)-jobs',      description = ' Jira for Workflows Prod Main Branch, which runs E2E.' },
    { url = 'https://dynatrace-apps-jenkins.ci.dynalabs.io/job/dynatrace-app-projects/job/jira-app/job/dev/',                        name = 'jira-dev-jobs',              description = 'Jira for Workflows Dev branch builds.' },
    { url = 'https://dynatrace-apps-jenkins.ci.dynalabs.io/job/dynatrace-app-projects/job/microsoft365-connector/job/prod/job/main', name = 'ms365-mail-prod-(main)-jobs' },
    { url = 'https://dynatrace-apps-jenkins.ci.dynalabs.io/job/dynatrace-app-projects/job/microsoft365-connector/job/dev/',          name = 'ms365-mail-dev-jobs' },
    { url = 'https://dynatrace-apps-jenkins.ci.dynalabs.io/job/dynatrace-app-projects/job/email-app/job/prod/',                      name = 'email-app-prod-jobs' },
    { url = 'https://dynatrace-apps-jenkins.ci.dynalabs.io/job/dynatrace-app-projects/job/email-app/job/dev/',                       name = 'email-app-dev-jobs' },
    { url = 'https://iam-jenkins.ci.dynalabs.io/job/IAM/job/iam-policy-management-promote/',                                         name = 'IAM-Policy-Promotions',      description = 'Applying IAM policies to SaaS Environments' },
  },
  react = {
    { url = 'https://dev-jira.dynatrace.org/browse/ADES-5614',                                                                name = 'dt-app-create-template-upgrade-reactv18' },
    { url = 'https://dynatrace.slack.com/archives/C01MYTU5PTQ/p1704711105109739?thread_ts=1668584579.958249&cid=C01MYTU5PTQ', name = 'Slack Thread: React 18 Roadmap' }
  },
  ["self-monitoring"] = {
    {
      url =
      'https://gmg80500.dev.dynatracelabs.com/#dashboard;gtf=l_24_HOURS;gf=all;id=71637f59-6184-301d-a1ce-60b12dba4d9c',
      name = 'Sprint Hardening Dashboard: Jira for Workflows'
    }
  },
  workflows = {
    { url = 'https://github.com/Dynatrace/Dynatrace-workflow-samples',                                  name = 'Dynatrace Workflow Samples Repo' },
    { url = 'https://docs.dynatrace.com/docs/platform-modules/automations/workflows/reference',         name = 'jinja2-reference' },
    { url = 'https://docs.dynatrace.com/docs/platform-modules/automations/workflows/reference#filters', name = 'jinja2-filters' },
    { url = "https://developer.dynatracelabs.com/develop/workflows/create-custom-action/",              name = 'Internal Dev Docs Creating Actions', description = 'Relevant for Partial Updates' }
  },
  zoom = {

    { url = 'https://dynatrace.zoom.us/meeting#/',                                         name = 'Manage Zoom Meetings',                     description = 'Zoom Web Interface Meeting Management' },
    { url = 'https://dynatrace.zoom.us/j/4336505524?pwd=NjIwVUxmMldZK0dRSVpMdlNKUzlRQT09', name = 'Invitation to Personal Zoom Room-Jonathan' },

    { url = 'https://dynatrace.zoom.us/meeting/91726200802',                               name = 'Manage Jonathan 1:1 Simon' },
    { url = 'https://dynatrace.zoom.us/meeting/94868314740?occurrence=1702455300000',      name = 'Manage Jonathan 1:1 Claudia' },
    { url = 'https://dynatrace.zoom.us/meeting/93131472955?occurrence=1702976400000',      name = 'Manage Jonathan 1:1 Johannes' },
    { url = 'https://dynatrace.zoom.us/meeting/98663218232?occurrence=1686641400000',      name = 'Manage Jonathan 1:1 Bernhard' },

    { url = 'https://dynatrace.zoom.us/j/91726200802',                                     name = 'Invitation to Jonathan 1:1 Simon' },
    { url = 'https://dynatrace.zoom.us/j/94868314740',                                     name = 'Invitation to Jonathan 1:1 Claudia' },
    { url = 'https://dynatrace.zoom.us/j/93131472955',                                     name = 'Invitation to Jonathan 1:1 Johannes' },
    { url = 'https://dynatrace.zoom.us/j/98663218232',                                     name = 'Invitation to Jonathan 1:1 Bernhard' },
  },
  services = {
    { url = 'https://email-control.dev.central.internal.dynatracelabs.com/swagger-ui/index.html?urls.primaryName=public#/Emails%20API/sendEmail',                        name = 'sendEmail-central-dev',                description = 'email service managed by Team ' },
    { url = 'https://email-control.sprint.central.internal.dynatracelabs.com/swagger-ui/index.html?urls.primaryName=public#/Emails%20API/sendEmail',                     name = 'sendEmail-central-sprint' },
    { url = 'https://teams.internal.dynatrace.com/capabilities/142',                                                                                                     name = 'Cluster Deployment Capability' },
    { url = 'https://teams.internal.dynatrace.com/teams/52804',                                                                                                          name = 'Team Mission Control' },
    { url = "https://eva38390.sprint.dynatracelabs.com/#problems/problemdetails;gtf=p_114583043507662114_1706671800000V2;gf=all;pid=114583043507662114_1706671800000V2", name = "problems-email-service" },
    { url = "https://docs.dynatrace.com/docs/platform/davis-ai/anomaly-detection/metric-events",                                                                         name = "metric-events-for-alert-profiles" },
    { url = "https://email-control.dev.central.internal.dynatracelabs.com/swagger-ui/index.html?urls.primaryName=public#/Emails%20API/sendEmail",                        name = "email-control-proxy-sendEmail-dev",    description = "The singleton proxy to the underlaying email-service that our public HTTP API proxy forwards to." },
    { url = "https://email-control.sprint.central.internal.dynatracelabs.com/swagger-ui/index.html?urls.primaryName=public",                                             name = "email-control-proxy-sendEmail-sprint", description = "The singleton proxy to the underlaying email-service that our public HTTP API proxy forwards to." }

  },
  eslint = {
    { url = 'https://github.com/microsoft/vscode-eslint/tags',                                                   name = 'vscode-eslint VSCode extension Versions',    description = 'The eslint language server in VS Code wrapped in an extension.' },
    { url = 'https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint',          name = 'nvim-lspconfig ESLint Integration Docs',     description = 'Ref to hrsh7th/vscode-langservers-extracted, where the binary vscode-eslint-language-server comes from.' },
    { url = 'https://github.com/hrsh7th/vscode-langservers-extracted',                                           name = 'vscode-eslint-language-server Repo',         description = 'Extracts eslint language server from vscode-eslint extension.' },
    { url = 'https://github.com/hrsh7th/vscode-langservers-extracted/tags',                                      name = 'vscode-eslint-language-server Versions',     description = 'Extracts eslint language server from vscode-eslint extension.' },
    { url = 'https://github.com/hrsh7th/vscode-langservers-extracted/blob/master/script/build-vscode-eslint.sh', name = 'vscode-eslint-language-server Build Script', description = 'This builds from the HEAD commit of the vscode-eslint master branch.' },

    { url = 'https://github.com/manateelazycat/lsp-bridge/commit/7a24d8934c3e3ca185de7d4f7a7c1362e6f63beb',      name = 'emacs VSCode ESLint Bridge',                 description = 'Commit that adds vscode-eslint-language-server from vscode-langservers-extracted to lsp-bridge' },
  },
  dynatrace = {
    { url = 'https://dt-rnd.atlassian.net/jira/dashboards/44400',                          name = 'Platform Promotions',    description = 'Promotions from Sprint/Hardening/Staging to Production' },
    { url = 'https://dynatrace.sharepoint.com/sites/RnD/SitePages/Employee_Universe.aspx', name = 'Employee Universe',      description = 'sharepoint-Top-level Menu for Dynatracers' },
    { url = "https://dynatrace.sharepoint.com/sites/ACE_Services",                         name = "sharepoint-ace-services" }
  },
  dynatrace_developer = {
    { url = 'https://developer.dynatracelabs.com/',                                                                                             name = '3rd Gen App Dev Docs',                                                     description = 'Internal Developer Guide' },
    { url = 'https://developer.dynatracelabs.com/reference/app-toolkit/plugin-system/',                                                         name = 'Plugins' },
    { url = 'https://developer.dynatracelabs.com/reference/app-toolkit/plugin-system/',                                                         name = 'Plugins' },
    { url = 'https://artifactory.lab.dynatrace.org/ui/packages/npm:%2F%2F@dynatrace-sdk%2Fapp-environment?name=%40dynatrace-sdk&type=packages', name = 'Artifactory Publication app.config.ts API @dynatrace-sdk/app-environment', description = 'Provide app.config.ts contextual information at runtime.' },
    { url = 'https://developer.dynatracelabs.com/reference/sdks/app-environment/',                                                              name = 'SDK app.config.ts API Dev Docs',                                           description = 'Runtime access to app.config.ts data.' },
  },
  jira = {
    { url = 'https://dt-rnd.atlassian.net/wiki/spaces/RNDOPS/pages/79496706/How+to+grant+access+to+a+Space+in+Confluence+SaaS+Cloud', name = 'Grant access to user space' },
    { url = 'https://dt-rnd.atlassian.net/wiki/spaces/ACE/pages/276168707/2023-12-20+Maintenance+Labels+Refresher',                   name = 'labels' },
    { url = 'https://dev-jira.dynatrace.org//secure/CreateIssue.jspa?issuetype=1&pid=17090',                                          name = 'open-bitbucket-team-ep-ticket' },
    { url = 'https://dev-jira.dynatrace.org//secure/CreateIssue.jspa?issuetype=1&pid=19093',                                          name = 'open-jira-team-rndopssup-ticket' },
  },
  owners = {
    { url = 'https://cloudcontrol-dev.internal.dynatracelabs.com/#tenants',    name = 'cloudcontrol-dev',                   description = 'Find out who owns a tenant.' },
    { url = 'https://cloudcontrol-sprint.internal.dynatracelabs.com/#tenants', name = 'cloudcontrol-sprint',                description = 'Find out who owns a tenant in the Sprint SaaS.' },
    { url = 'https://cloudcontrol.internal.dynatrace.com/',                    name = 'cloudcontrol-prod',                  description = 'Find out who owns a tenant in the Prod SaaS.' },
    { url = 'https://cloudcontrol-dev.internal.dynatracelabs.com/#tenants',    name = 'cloudcontrol-dev-paying-tenants',    description = 'Find out who owns a tenant.' },
    { url = 'https://cloudcontrol-dev.internal.dynatracelabs.com/#tenants',    name = 'cloudcontrol-dev-trial-tenants',     description = 'Find out who owns a tenant.' },
    { url = 'https://cloudcontrol-sprint.internal.dynatracelabs.com/#tenants', name = 'cloudcontrol-sprint-paying-tenants', description = 'Find out who owns a tenant in the Sprint SaaS.' },
    { url = 'https://cloudcontrol-sprint.internal.dynatracelabs.com/#tenants', name = 'cloudcontrol-sprint-trial-tenants',  description = 'Find out who owns a tenant in the Sprint SaaS.' },
    { url = "https://admin.myaccount-dev.dynatracelabs.com",                   name = "admin-myaccount-dev",                description = "Find tenant meta information." },
    { url = "https://admin.myaccount-hardening.dynatracelabs.com",             name = "admin-myaccount-sprint",             description = "Find tenant meta information." },
  },
  hubmanager = {
    { url = 'https://hub-manager.spine.internal.dynatrace.com',                name = 'hub-manager-prod' },
    { url = 'https://hub-manager.spine-hardening.internal.dynatracelabs.com/', name = 'hub-manager-sprint' },
    { url = 'https://hub-manager.spine-dev.internal.dynatracelabs.com',        name = 'hub-manager-dev' },
  },
  accountmanagement = {
    { url = "https://myaccount-dev.dynatracelabs.com/accounts",       name = "accountmanager-dev" },
    { url = "https://myaccount-hardening.dynatracelabs.com/accounts", name = "accountmanager-sprint" },
    { url = "?",                                                      name = "accountmanager-prod" },
  },
  dql = {
    { url = "https://docs.dynatrace.com/docs/platform/grail/dynatrace-query-language/data-types",                                    name = 'dql-datatypes' },
    { url = "https://docs.dynatrace.com/docs/platform-modules/business-analytics/ba-events-processing/ba-events-processing-matcher", name = 'DQL matcher in business events' },
    { url = "https://docs.dynatrace.com/docs/platform/grail/dynatrace-query-language/commands",                                      name = "dql-commands" },
    { url = 'https://docs.dynatrace.com/docs/platform/grail/dynatrace-query-language/functions',                                     name = 'dql-functions' }
  },
  docs = {
    { url = "https://docs.dynatrace.com/docs",                                                                                                                             name = 'dynatrace-public-welcome' },
    { url = "https://dynatrace-docs-preview.spine-dev.internal.dynatracelabs.com/pr-748/docs/platform-modules/automations/workflows/building#remove-a-task-transition",    name = "PR Preview Doc PR-748 (Merged, yet Unpublished) Automation Task Transitions" },
    { url = "https://developer.dynatrace.com/reference/sdks",                                                                                                              name = "Dev Docs Guide Dynatrace SDKs for Typescript" },
    { url = "https://docs.dynatrace.com/docs/dynatrace-api/basics/dynatrace-api-authentication/account-api-authentication",                                                name = "create-oauth2-client" },
    { url = "https://docs.dynatrace.com/docs/manage/account-management",                                                                                                   name = "account management" },
    { url = "https://developer.dynatracelabs.com/develop/testing/#layers-of-testing",                                                                                      name = "layers-of-testing",                                                          description = "Testing Category Definitions" },
    { url = "https://docs.dynatrace.com/docs/observe-and-explore/logs/log-management-and-analytics/lma-log-ingestion-via-api",                                             name = "log-ingestion" },
    { url = "https://docs.dynatrace.com/docs/observe-and-explore/notifications-and-alerting/alerting-profiles",                                                            name = "alert-profiles" },
    { url = "https://docs.dynatrace.com/docs/platform/grail/dynatrace-query-language/commands/aggregation-commands#makeTimeseries",                                        name = "makeTimeseries-from-stream" },
    { url = "https://docs.dynatrace.com/docs/platform-modules/automations/workflows/trigger#davis-problem-trigger",                                                        name = "david-problem-trigger" },
    { url = "https://docs.dynatrace.com/docs/platform-modules/digital-experience/synthetic-monitoring/general-information/credential-vault-for-synthetic-monitors",        name = "credential-vault" },
    { url = "https://docs.dynatrace.com/docs/platform-modules/digital-experience/synthetic-monitoring/general-information/credential-vault-for-synthetic-monitors#cv-api", name = "credential-vault-api" },
    { url = "https://developer.dynatrace.com/reference/sdks/automation-utils/",                                                                                            name = "automation-utils" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco",                                                                                         name = "monaco" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/installation",                                                                            name = "Install Monaco Executable" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/manage-configuration",                                                                    name = "monaco-configuration" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/configuration/yaml-configuration#config",                                                 name = "monaco-configuration-yaml" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/configuration/projects",                                                                  name = "monaco-projects" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/configuration#deployment-manifest",                                                       name = "monaco-deployment-manifest" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/configuration/yaml-configuration#dynatrace-configuration-as-code-via-monaco",             name = "monaco-yaml" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/guides/order-of-configurations",                                                          name = "monaco-enforce-order-of-configuration-application" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/guides/create-oauth-client#create-an-oauth-client",                                       name = "monaco-oauth-scopes-permissions" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/guides/configuration-as-code-advanced-use-case",                                          name = "monaco-templates-templating",                                                description = "Dynatrace Monaco CLI projects contain both a config.yaml and JSON template file. " },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/configuration/projects#json-template-file",                                               name = "monaco-json-template-file",                                                  description = "JSON contains the payload pushed (after templating has been applied). YAML contains a list of {config: obj, id: string}." },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/configuration/yaml-configuration#parameters",                                             name = "monaco-variables" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/configuration/yaml-configuration#type-automation",                                        name = "monaco-workflows-type-automation" },
    { url = "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/configuration/yaml-configuration#env-overrides",                                          name = "monaco-override-config-per-environment" },
    { url = "https://youtu.be/blJDhHwZfp4?t=2109",                                                                                                                         name = "monaco-values-syntax-youtube" },

  },
  sdk = {
    url =
    "https://bitbucket.lab.dynatrace.org/projects/APPFW/repos/dynatrace-sdk/browse/packages/dt-app-plugin-client-app-settings",
    name = "sdk-dt-app-plugin-client-app-settings",
    description =
    "Team Config Platform"
  },
  permissions = {
    { url = 'https://idmui.internal.dynatrace.com/ui/dashboard',                                                 name = 'idmui-dev' },
    { url = 'https://idmui-sprint.internal.dynatracelabs.com/ui/dashboard',                                      name = 'idmui-sprint' },
    { url = '',                                                                                                  name = 'idmui-prod' },
    { url = 'https://dynatrace.sharepoint.com/sites/SRSECOPS/SitePages/Management-of-employee-permissions.aspx', name = 'sharepoint-docs-employee-permissions' }
  },
  tickets = {
    { url = 'https://dev-jira.dynatrace.org/browse/PS-12634', name = 'As a app developer, I want the app version to be attached to logs so that I can correlate issues to app versions', description = 'Silvio Doblhofer helped here. It should involve small effort on their part for a big gain on the self-monitoring side.' }
  },
  snyk = {
    { url = 'https://bitbucket.lab.dynatrace.org/projects/COPS/repos/heimdall-dt-saas-managed/browse/groups/Snyk/snyk-capability_cloud_automation-admin',        name = 'heimdall-admins' },
    { url = 'https://bitbucket.lab.dynatrace.org/projects/COPS/repos/heimdall-dt-saas-managed/browse/groups/Snyk/snyk-capability_cloud_automation-collaborator', name = 'heimdall-collaborators' },
    { url = 'https://backstage.internal.dynatrace.com/catalog/internal-systems/component/snyk-shared-jenkins-library/docs/usage/',                               name = ':ocs-backstage' }
  }
}

local filter = function(sequence, predicate)
  local newlist = {}
  for i, v in ipairs(sequence) do
    if predicate(v) then
      table.insert(newlist, v)
    end
  end
  return newlist
end

local map = function(sequence, transformation)
  local newlist = {}
  for i, v in pairs(sequence) do
    newlist[i] = transformation(v)
  end
  return newlist
end

local reduce = function(sequence, operator)
  if #sequence == 0 then
    return nil
  end
  local out = nil
  for i = 1, #sequence do
    out = operator(out, sequence[i])
  end
  return out
end

-- @returns a config table conforming to standard format
local parseConfig = function(elem)
  -- string check must come first
  if (type(elem) == "string") then
    return { name = elem }
  end

  local result = {}
  if (elem.description ~= nil) then
    result = { description = elem.description }
  end

  if (elem.name ~= nil) then
    result = vim.tbl_extend('error', result, { name = elem.name })
  else
    result = vim.tbl_extend('error', result, { name = elem.url })
  end
  return result
end

-- TODO
local assertUrl = function(value) return true end

-- elem is a url input element
-- @returns a url table conforming to standard format
local parseUrl = function(elem)
  -- Simple case
  if (type(elem) == "string") then
    return { url = elem }
  end
  return { url = elem.url }
end

-- @returns - a table in standardized format
local parseInput = function(rawTable)
  local result = {}
  for topic, elems in pairs(rawTable) do
    for _, linkObj in pairs(elems) do
      local urlTbl = parseUrl(linkObj)
      local configTbl = parseConfig(linkObj) -- TODO outdated
      local joinedTbl = vim.tbl_deep_extend('error', urlTbl, configTbl, { topic = topic })
      table.insert(result, joinedTbl)
    end
  end
  return result
end


local make_markdown_link = function(name, url)
  return string.format("[%s](%s)", name, url)
end

--------------------------------------------------------------------------------
--                          Snippet Table Generator                           --
--------------------------------------------------------------------------------

local function generate_links(rawInput)
  local snippets = {}
  local input = parseInput(rawInput)
  --P(input) -- a list of objects whose topic key can be filtered

  local topicsTblForFiltering = {}

  for idx, v in ipairs(input) do
    table.insert(topicsTblForFiltering, v.topic)
    ------------------------------------------------------
    table.insert(snippets,
      s(string.format("%s-%s-link", v.topic, v.name), { t(string.format("[%s](%s)", v.name, v.url)) }))
    if (v.description) then
      table.insert(snippets, s(string.format("%s-%s-link-full", v.topic, v.name), {
        t(v.description),
        t(' -> '),
        t(make_markdown_link(v.name, v.url)),
      }))
    end
  end

  -- We need a sequence of topics for creating one snippet per topic
  local reduceFunction = function(acc, val)
    local set_util = function(sequence)
      local set = {}
      if (sequence ~= nil) then
        for _, e in ipairs(sequence) do set[e] = true end
      end
      return set
    end

    local _acc = set_util(acc)
    if _acc[val] then return _acc else return table.insert(acc, val) end
  end

  --P(topicsTblForFiltering)
  --local topics = reduce(topicsTblForFiltering, reduceFunction)

  -- generate by-topic snippets
  --for idx, topic in ipairs(topics) do
  --local topicPredicate = function(tbl) return tbl.topic == topic end
  --local relatedLinks = filter(input, topicPredicate)
  ---- construct the content string
  --local text_node_content = ""
  --for _, link in pairs(relatedLinks) do
  --  text_node_content = { string.format("*%s*", link.name:lower():gsub("^%l", string.upper)), '' }

  --  local lineContent = ""
  --  if link.description then
  --    lineContent = ' - ' .. link.description .. " -> " .. make_markdown_link(link.name, link.url)
  --  else
  --    lineContent = ' - ' .. make_markdown_link(link.name, link.url)
  --  end

  --  table.insert(text_node_content, lineContent)
  --  table.insert(text_node_content, "")
  --end

  -- Insert the generated content for each topic
  --table.insert(snippets, s(topic .. '-ALL_LINKS', t(text_node_content)))
  --end
  return snippets
end

return generate_links(links)
