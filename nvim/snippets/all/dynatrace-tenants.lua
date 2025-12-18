-- TODO generate myaccount links like https://myaccount-dev.dynatracelabs.com/account/settings/environments?account-uuid=b0a4b642-db63-4ed0-8f05-84ec410756cb
-- TODO: links for Hub details given an app.id (or app name): [Slack Sprint Release](https://guu84124.apps.dynatrace.com/ui/apps/dynatrace.hub/browse?details=dynatrace.slack&detailsTab=releases)
--   e.g. for app name -- https://yhf92160.sprint.apps.dynatracelabs.com/ui/apps/dynatrace.hub/manage?search=Jira+for+Workflows
--   https://yhf92160.sprint.apps.dynatracelabs.com/ui/apps/dynatrace.hub/browse/all?search=jira+for+&details=dynatrace.jira&detailsTab=releases
-- TODO: links for Hub details given an app.id: [Jira Sprint Release](https://guu84124.apps.dynatrace.com/ui/apps/dynatrace.hub/browse?details=dynatrace.jira)
-- TODO: links to Hub Managers for each SaaS Environment: https://hub-manager.spine-hardening.internal.dynatracelabs.com/,
-- Generate Dynatrace Tenant Snippets for LuaSnip
local DT = {}
DT.tenants = {
  { name = "vzx38435",   conf = { saas_type = "dev" } },
  { name = "vja49678",   conf = { saas_type = "dev", description = "Used for ownership app, teams internal importer, azure-connector, automation samples" }, account_uuid = "b0a4b642-db63-4ed0-8f05-84ec410756cb" },
  { name = "deve2e",     conf = { saas_type = "dev", monitor_of = "dev" } },
  { name = "gmg80500",   conf = { saas_type = "dev", monitor_of = "dev", alias = "deve2e" } },

  { name = "umsaywsjuo", conf = { saas_type = "dev", description = "Used by Platform Advocates" } },

  { name = "yhf92160",   conf = { saas_type = "sprint" } },
  { name = "msu89794",   conf = { saas_type = "sprint", description = "Used by E2E Tests" } },
  -- Self-monitoring tenants
  { name = "eva38390",   conf = { saas_type = "sprint", monitor_of = "sprint" } },
  { name = "igo04931",   conf = { saas_type = "sprint", monitor_of = "monitor-the-monitor-for-sprint" } },

  { name = "ntd44713",   conf = { saas_type = "prod", monitor_of = "prod" } },
  -- Self-monitoring the self-monitoring tenants
  { name = "guu84124",   conf = { saas_type = "prod" } },
  -- https://ovw30140.live.dynatrace.com/#dashboard;gtf=-30m;gf=all;id=6b38732e-d26b-45c7-b107-e[…]CE-6C2E706BC7800CD4%7Cdynatrace-apps-jenkins-slaves-ni
  { name = "ovw30140",   conf = { saas_type = "prod", monitor_of = "jenkins-and-kubernetes" } },
  {
    name = "kxo25992",
    conf = {
      saas_type = "dev",
      description = "Design System",
      url_extra_patterns = {
        ["design system"] =
        "https://kxo25992.dev.apps.dynatracelabs.com/ui/apps/my.design.system.latest/package/react-icons"
      }
    }
  }
}

local FunctionsToFormDataStructure = {
  -- TODO migrate Utils that make strings
  StringMakers = {}
}

function FunctionsToFormDataStructure.is_prod(value)
  return value == "prod"
end

function FunctionsToFormDataStructure.v3_url_from(name, config)
  if (FunctionsToFormDataStructure.is_prod(config.saas_type)) then
    return string.format("https://%s.apps.dynatrace.com", name)
  end
  return string.format("https://%s.%s.apps.dynatracelabs.com/ui", name, config.saas_type)
end

function FunctionsToFormDataStructure.v2_url_from(name, config)
  if (FunctionsToFormDataStructure.is_prod(config.saas_type)) then
    return string.format("https://%s.live.dynatrace.com", name)
  end
  return string.format("https://%s.%s.dynatracelabs.com", name, config.saas_type)
end

function FunctionsToFormDataStructure.api_url_from(name, config)
  -- https://vzx38435.dev.apps.dynatracelabs.com/platform/swagger-ui/index.html
  if (FunctionsToFormDataStructure.is_prod(config.saas_type)) then
    return string.format("https://%s.live.dynatrace.com", name)
  end
  return string.format("https://%s.%s.apps.dynatracelabs.com/platform/swagger-ui/index.html", name, config.saas_type)
end

function FunctionsToFormDataStructure.cloud_control_from(saas_type)
  if (FunctionsToFormDataStructure.is_prod(saas_type)) then
    return "https://cloudcontrol.internal.dynatracelabs.com/"
  end
  if (saas_type == "dev") or (saas_type == "staging") then
    return string.format("https://cloudcontrol-%s.internal.dynatracelabs.com/", saas_type)
  end
  return "unknown saas type"
end

function FunctionsToFormDataStructure.credential_vault_from(conf)
  -- "https://vzx38435.dev.apps.dynatracelabs.com/ui/apps/dynatrace.classic.credential.vault/#credentialvault"
  return
end

-- Factory for TenantSpec
-- This is the highest level function that composes all others
-- Defines what gets exposed in the generators below
-- @returns - an aggregate data structure to be used by generators
function FunctionsToFormDataStructure.tenant_of(name, conf)
  return {
    environment_id = name,
    saas_type = conf.saas_type,
    domain_v3 = FunctionsToFormDataStructure.v3_url_from(name, { saas_type = conf.saas_type }),
    domain_v2 = FunctionsToFormDataStructure.v2_url_from(name, { saas_type = conf.saas_type }),
    api_url = FunctionsToFormDataStructure.api_url_from(name, { saas_type = conf.saas_type }),
    url_cloud_control = FunctionsToFormDataStructure.cloud_control_from(conf.saas_type),
    monitor_of = conf.monitor_of or nil
  }
end

function FunctionsToFormDataStructure.monitors_string_from(tenant)
  local monitors_string = ''
  if (tenant.monitor_of) then
    monitors_string = string.format("Monitors SaaS type '%s'", tenant.monitor_of)
  else
    monitors_string = ''
  end
  return monitors_string
end

function FunctionsToFormDataStructure.log_urls_from(tenant)
  --local advanced_query_string = string.format(
  --    "%s/ui/logs-events?advancedQueryMode=true&visualizationType=table&isDefaultQuery=false&gtf=-2h&gf=all&query=%%2F%%2F%%20scanLimitGBytes:%%20-1%%20is%%20equivalent%%20to%%20no%%20limit%%20on%%20how%%20many%%20bytes%%20to%%20scan%%0Afetch%%20logs,%%20from:now()-24h,%%20to:%%20now(),%%20scanLimitGBytes:%%20-1%%20%%20%%0A%%7C%%20filter%%20matchesValue(loglevel,%%20%%22ERROR%%22)%%20AND%%20in(dt.app.id,%%20array(%%22dynatrace.jira%%22%%20,%%20%%22dynatrace.microsoft365.connector%%22))%%20%%20%%20%%20%%20%%20%%20%%0A%%7C%%20fields%%20timestamp,%%20dt.tenant.uuid,%%20dt.app.id,%%20status%%20%%3D%%20upper(loglevel),%%20content,%%20trace_id%%0A%%7C%%20sort%%20timestamp%%20desc%%0A&sortDirection=desc&visibleColumns=timestamp&visibleColumns=status&visibleColumns=content",
  --    tenant.domain_v2)
  local advanced_query_string = string.format(
    "%s/ui/logs-events?advancedQueryMode=true&visualizationType=table&isDefaultQuery=false&gtf=-24h&gf=all&query=%%2F%%2F%%20scanLimitGBytes:%%20-1%%20is%%20equivalent%%20to%%20no%%20limit%%20on%%20how%%20many%%20bytes%%20to%%20scan%%0Afetch%%20logs,%%20scanLimitGBytes:%%20-1%%20%%20%%0A%%7C%%20filter%%20matchesValue(loglevel,%%20%%22ERROR%%22)%%20AND%%20in(dt.app.id,%%20array(%%22dynatrace.jira%%22%%20,%%20%%22dynatrace.microsoft365.connector%%22))%%20%%20%%20%%20%%20%%20%%20%%0A%%7C%%20fields%%20timestamp,%%20dt.tenant.uuid,%%20dt.app.id,%%20status%%20%%3D%%20upper(loglevel),%%20content,%%20trace_id%%0A%%7C%%20sort%%20timestamp%%20desc%%0A&sortDirection=desc&visibleColumns=timestamp&visibleColumns=status&visibleColumns=content",
    tenant.domain_v2)
  local simple_query_string = string.format(
    "%s/ui/logs-events?advancedQueryMode=false&visualizationType=table&isDefaultQuery=false", tenant.domain_v2)
  return {
    url_advanced = advanced_query_string,
    url_simple = simple_query_string,
  }
end

local snippet_generating_event_handlers = {}
snippet_generating_event_handlers.onMonitorOf = function(snippets, tenant)
  table.insert(
    snippets,
    s(string.format("logs_monitor_of_%s_saas_logs_%s_tenant", tenant.monitor_of, tenant.environment_id),
      f(function(args, snip, user_arg_1)
        return string.format("[Self-monitor of %s SaaS Logs](%s)", tenant.monitor_of,
          FunctionsToFormDataStructure.log_urls_from(tenant).url_advanced)
      end, {})
    )
  )
  table.insert(snippets, s(string.format("tenant_monitor_%s_of_%s", tenant.environment_id, tenant.monitor_of),
    f(function(args, snip, user_arg_1)
      local third_gen_string = string.format("[Monitor of %s; 3rd Gen; %s](%s)", tenant.monitor_of,
        tenant.environment_id,
        tenant.domain_v3)
      local second_gen_string = string.format("[Monitor of %s; 2nd Gen; %s](%s)", tenant.monitor_of,
        tenant.environment_id,
        tenant.domain_v2)
      return string.format("%s -> %s", third_gen_string, second_gen_string)
    end, {})
  )
  )
  -- same as above, just under a different name for convenience
  -- table.insert(snippets,
  --   s(string.format("self-monitor_of_%s_saas_logs_%s_tenant", tenant.monitor_of, tenant.environment_id),
  --     f(function(args, snip, user_arg_1)
  --       return string.format("[Self-monitor of %s SaaS Logs](%s)", tenant.monitor_of,
  --       Utils.log_urls_from(tenant).url_advanced)
  --     end, {})
  --   ))
end

local snippet_generators = {}
snippet_generators.general_ui_snippets = function(tenant)
  return s(string.format("tenant_%s_%s_2nd_3rd_url", tenant.environment_id, tenant.saas_type), {
    f(function(args, snip, user_arg_1)
      local third_gen_string = string.format("[%s; 3rd Gen; %s](%s)", tenant.environment_id, tenant.saas_type,
        tenant.domain_v3)
      local second_gen_string = string.format("[%s; 2nd Gen; %s](%s)", tenant.environment_id, tenant.saas_type,
        tenant.domain_v2)
      local monitors_string = FunctionsToFormDataStructure.monitors_string_from(tenant)
      local extras =
      {
        saas_overview = "https://dev-wiki.dynatrace.org/display/ruxit/Overview+of+Dynatrace+SaaS+Environments",
        cloud_control = tenant.url_cloud_control
      }
      return string.format("%s %s -> %s", monitors_string, third_gen_string, second_gen_string)
    end, {}),
  })
end

snippet_generators.cloudcontrol_snippets = function(tenant)
  return s(string.format("cloudcontrol_%s (%s)", tenant.environment_id, tenant.saas_type), {
    f(function(args, snip, user_arg_1)
      -- Example
      -- https://cloudcontrol-sprint.internal.dynatracelabs.com/#tenants;textPattern=msu89794
      -- https://cloudcontrol-sprint.internal.dynatracelabs.com/#tenant;uuid=msu89794
      return string.format("[CloudControl for %s](https://cloudcontrol-%s.internal.dynatracelabs.com/#tenant;uuid=%s)",
        tenant.environment_id, tenant.saas_type, tenant.environment_id)
    end, {}),
  })
end


snippet_generating_event_handlers.onNonMonitorTenant = function(snippets, tenant)
  table.insert(snippets, snippet_generators.general_ui_snippets(tenant))

  table.insert(snippets,
    s(string.format("dynatrace_api_openapi_swagger_of_tenant_%s_%s", tenant.environment_id, tenant.saas_type), {
      -- function node may return a string for table of strings for multiline strings where all lines following first will be prefixed with snippets' indentation
      f(function(argnode_text, parent_snippet_or_parent_node, user_args_from_opt_dot_user_args)
        return string.format("[Dynatrace API (OpenAPI/Swagger UI) on %s Tenant (%s)](%s)", tenant.environment_id,
          tenant.saas_type, tenant.api_url)
      end)
    }))

  -- Send Email API Snippets
  table.insert(snippets,
    s(string.format("dynatrace_api_send_email_of_tenant_%s_%s", tenant.environment_id, tenant.saas_type), {
      -- function node may return a string for table of strings for multiline strings where all lines following first will be prefixed with snippets' indentation
      f(function(argnode_text, parent_snippet_or_parent_node, user_args_from_opt_dot_user_args)
        return string.format(
          "[Dynatrace API (OpenAPI/Swagger UI) for Send Email on %s Tenant (%s)](%s?urls.primaryName=Email#/Emails%%20API/sendEmail)",
          tenant.environment_id, tenant.saas_type, tenant.api_url)
      end)
    }))

  table.insert(snippets,
    s(string.format("environmentUrl_%s_%s", tenant.environment_id, tenant.saas_type), {
      f(function(args, snip, user_arg_1)
        return "not yet implemented"
      end)
    })
  )
end

snippet_generating_event_handlers.onEveryTenant = function(snippets, tenant)
  table.insert(snippets, s(string.format("%s_%s", tenant.environment_id, tenant.saas_type), { t(tenant.environment_id) }))
  table.insert(snippets,
    s(string.format("tenant_%s_%s", tenant.environment_id, tenant.saas_type), { t(tenant.environment_id) }))

  table.insert(snippets, snippet_generators.cloudcontrol_snippets(tenant))
end

local function generate_snippets(tenants)
  -- imperatively populate table (Lua...ugly)
  local snippets = {}
  for _, ten in pairs(tenants) do
    -- Convert tenants spec into list of Tenant
    local tenant = FunctionsToFormDataStructure.tenant_of(ten.name, ten.conf)

    snippet_generating_event_handlers.onEveryTenant(snippets, tenant)

    -- Prepare self-monitoring snippets
    if (tenant.monitor_of) then
      snippet_generating_event_handlers.onMonitorOf(snippets, tenant)
    end

    -- Prepare normal tenant snippets
    if (tenant.monitor_of == nil) then
      snippet_generating_event_handlers.onNonMonitorTenant(snippets, tenant)
    end
  end
  table.insert(snippets,
    s("help-dynatrace-docs-public", { t("[Dynatrace Public Documentation](https://www.dynatrace.com/support/help)") }))
  table.insert(snippets,
    s("help-dynatrace-docs-internal", { t("[Dynatrace Internal Documentation](https://developer.dynatracelabs.com)") }))
  return snippets
end
-- Return table conforming to luasnip spec
return generate_snippets(DT.tenants)
