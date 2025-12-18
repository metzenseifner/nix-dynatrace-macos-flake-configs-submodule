local dynatrace_oauth2 = [[
# rest.nvim
# This file works with Neovim rest.nvim and can be used to mimic official HTTP
# syntax and auto-generate curl calls e.g. hover over HTTP declaration and
# execute :Rest curl yank.
# Note that gopass is a secret string provider. Any equivalent string can replace the io.popen("...") calls.

# Client Credentials Flow https://datatracker.ietf.org/doc/html/rfc6749#section-4.4
# Dynatrace Docs https://hub-manager.dev.hub.central.internal.dynatracelabs.com/api/docs/?urls.primaryName=Release+Management+v1
#
# -- dev | hard | prod
@stage = hard

### Use Client ID and Client Secret to Acquire AccessToken from Authorization Server

# @lang=lua
< {%
  local stage = request.variables.stage
  local client_secret = (function()
  local secret = ""
  local stage = "hardening"
  if stage == "dev" then 
     secret = (function(h) local r=h:read("*a"); h:close(); return r end)(io.popen("gopass show -o dt/oauth/dt0s13.team-care-hub-manager-integration/dev/clientsecret"))
  elseif stage == "hardening" then
     secret = (function(h) local r=h:read("*a"); h:close(); return r end)(io.popen("gopass show -o dt/oauth/dt0s13.team-care-hub-manager-integration/hard/clientsecret"))
  elseif stage == "prod" then
    secret = (function(h) local r=h:read("*a"); h:close(); return r end)(io.popen("gopass show -o dt/oauth/dt0s13.team-care-hub-manager-integration/prod/clientsecret"))
  end
  return secret
end
)()
local authorization_server_url = (function(default)
  local result = default
  local stage = "hardening"
  if stage == "dev" then
    result = "https://sso-dev.dynatracelabs.com"
  elseif stage == "hardening" then
    result = "https://sso-sprint.dynatracelabs.com"
  elseif stage == "prod" then
    result = "https://sso.dynatrace.com"
  end
  return result
end)("https://sso-dev.dynatracelabs.com")
request.variables.set("authorization_server_url", authorization_server_url)
request.variables.set("client_secret", client_secret)
%}
@client_id = dt0s13.team-care-hub-manager-integration
@scopes = hub-manager:internal.release-management.apps.releases:read hub-manager:internal.release-management.apps.releases:write
@resouce = ""
POST /sso/oauth2/token
Host: {{authorization_server_url}}
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&
client_id={{client_id}}&
client_secret={{client_secret}}&
scope={{scopes}}&
resource={{}}

# @lang=lua
> {%
local body = vim.json.decode(response.body)
client.global.set("access_token", body.access_token)
client.global.set("access_token_type", body.token_type)
%}

### Get detailed app information

# @lang=lua
< {%
  local host = (function(default)
  local result = default
  local stage = "hardening"
  if stage == "dev" then
    result = "https://hub-manager.dev.hub.central.internal.dynatracelabs.com/internal/release-management/v1"
  elseif stage == "hardening" then
    result = "https://hub-manager.sprint.hub.central.internal.dynatracelabs.com/internal/release-management/v1"
  elseif stage == "prod" then
    result = "https://hub-manager.prod.hub.central.internal.dynatrace.com/internal/release-management/v1"
  end
  return result
  end)("https://hub-manager.dev.hub.central.internal.dynatracelabs.com/internal/release-management/v1")

  request.variables.set("host", host)
%}

@appId=dynatrace.delivery.insights
@appVersion=0.0.2-dev.20250911T141751+c161647
GET /apps/{{appId}}/releases/{{appVersion}}
Host: {{host}}
Authorization: {{access_token_type}} {{access_token}}
accept: application/json

]]

return {
  s("oauth2-dynatrace", fmt(dynatrace_oauth2, {}, {delimiters="[]"}))
}
