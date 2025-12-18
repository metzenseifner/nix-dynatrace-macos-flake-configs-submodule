local ls = require("luasnip")
local s = ls.snippet
local d = ls.dynamic_node
local t = ls.text_node
local sn = ls.sn
local fmt = require("luasnip.extras.fmt").fmt

-- Character to symbol mapping
local function char_to_symbol(_, snip)
  local char = snip.captures[1]
  local map = {
    ["/"] = "✅",
    ["x"] = "❌",
  }
  return sn(nil, t(map[char] or ""))
end

return {
  s({
    trig = "%(([/x])%) ", -- only match (/) or (x)
    regTrig = true,
    --hidden = true,
    name = "Paren Symbol Replacer",
    dscr = "Automatically replaces (/) with ✅, (x) with ❌",
    snippetType = "autosnippet",
  }, {
    d(1, char_to_symbol, {}),
  })
}
