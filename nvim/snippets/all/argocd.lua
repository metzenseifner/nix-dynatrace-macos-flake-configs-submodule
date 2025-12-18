local ls  = require("luasnip")
local s   = ls.snippet
local sn  = ls.snippet_node
local i   = ls.insert_node
local t   = ls.text_node
local d   = ls.dynamic_node
local c   = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  s("url-for-service-on-argocd",
    d(1, function(_, parent)
      -- Prefer LS_SELECT_RAW, fall back to SELECT_RAW if needed
      local sel = parent.snippet.env.LS_SELECT_RAW or parent.snippet.env.SELECT_RAW or ""
      local default_name = (sel ~= "" and sel) or "dtp-hard201-apigw-istio-gateway-external"

      return sn(nil, fmt([[
<argocd_instance><argocd_name><name>
<choice>
]], {
        argocd_instance = t(""),
        argocd_name     = t(""),

        -- Single editable name, reused via rep() below
        name = i(1, default_name),

        -- Choice contains complete variants to avoid reusing the same node twice
        choice = c(2, {
          sn(nil, fmt([[
https://argo-cd.dtp.cd.internal.dynatrace.com/applications?showFavorites=false&proj=&sync=&autoSync=&health=&namespace=&cluster=&labels=&search=<name>
https://argo-cd.dtp.cd.internal.dynatrace.com/applications
]], { name = rep(1) }, { delimiters = "<>" })),

          sn(nil, fmt([[
https://argo-cd.dtp.cd.internal.dynatracelabs.com/applications?showFavorites=false&proj=&sync=&autoSync=&health=&namespace=&cluster=&labels=&search=<name>
https://argo-cd.dtp.cd.internal.dynatracelabs.com/applications
]], { name = rep(1) }, { delimiters = "<>" })),
        }),
      }, { delimiters = "<>" }))
    end)
  ),
}
