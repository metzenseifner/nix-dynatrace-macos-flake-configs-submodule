local DT = {}
DT.hubmanagers_spec = {
  { saas_type = "sprint ", url = "https://hub-manager.spine-hardening.internal.dynatracelabs.com/" },
  { saas_type = "dev",     url = "https://hub-manager.spine-dev.internal.dynatracelabs.com/" },
}

DT.apps_spec = {
  { name = "slack-app", id = "dynatrace.slack" },
  { name = "jira-app",  id = "dynatrace.jira" }
}

local Utils = {
  filter = function(t, predicate)
    local result = {}
    for _, elem in pairs(t) do
      if (predicate(elem)) then
        table.insert(result, elem)
      end
    end
    return result
  end,
}

local Factories = {
  hub_manager_from = function(hubmanager_spec_elem)
    return { saas_type = hubmanager_spec_elem.saas_type, url = hubmanager_spec_elem.url }
  end,
  app_from = function(apps_spec_elem, hubmanagers_spec)
    return {
      name = apps_spec_elem.name,
      dev_hub_url = Utils.filter(hubmanagers_spec, function(e) return e.saas_type == "dev" end).url,
      sprint_hub_url = "sprint",
      prod_hub_url = "prod"
    }
  end
}

local function generate_snippets(hubmanagers_spec, apps_spec)
  local snippets = {}
  for _, hm in pairs(hubmanagers_spec) do
    local hubmanager = Factories.hub_manager_from(hm)

    table.insert(
      snippets,
      s(string.format("hubmanager_%s", hubmanager.saas_type),
        f(function(args, snip, user_arg_1)
          return string.format("[%s Hub Manager](%s)", hubmanager.saas_type, hubmanager.url)
        end)
      )
    )

    --for _, a_spec in pairs(apps_spec) do
    --  local app = Factories.app_from(a_spec, hubmanagers_spec)
    --  table.insert(snippets,
    --    s(string.format("hubmanager_%s_%s", hubmanager.saas_type, app.name),
    --      f(function(args, snip, user_arg_1)
    --        return string.format("[%s Hub Manager for %s](%s)", hubmanager.saas_type, app.name, hubmanager.url)
    --      end
    --      )
    --    ))
    --end
  end

  -- for _, a_spec in pairs(apps_spec) do
  --   local app = Factories.app_from(a_spec, hubmanagers_spec)
  --   table.insert(snippets,
  --     s(string.format("hubmanager_%s_%s", app..saas_type, app.name),
  --       f(function(args, snip, user_arg_1)
  --         return string.format("[%s Hub Manager for %s](%s)", hubmanager.saas_type, app.name, hubmanager.url)
  --       end
  --       )))
  -- end
  return snippets
end




return generate_snippets(DT.hubmanagers_spec, DT.apps_spec)
