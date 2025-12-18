local s = require("luasnip").snippet
local c = require("luasnip").choice_node

-- @class Trigger
-- @field name string
-- @field snippetType "snippet" | "autosnippet"
Trigger = { trig = nil, name = nil, snippetType = nil }

return {
  s({ trig = "auth", name = "Authentication Type" }, {
    t("Authentication Type: "),
    c(1, {
      t("Basic"),
      t("Bearer"),
      t("Digest"),
      t("OAuth"),
      t("None"),
    }),
    t({ "", "Username: " }), i(2, "username"),
    t({ "", "Password: " }), i(3, "password"),
  }),
}
