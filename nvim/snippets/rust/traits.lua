local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s("rust", {
    -- trait definition
    s("trait", fmt([[
    trait {} {{
        {}
    }}
  ]], {
      i(1, "Name"),
      i(0),
    })),
  })
}
