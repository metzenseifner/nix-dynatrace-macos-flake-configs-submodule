local ls = require("luasnip")
local s = ls.snippet
local fmt = require("luasnip.extras.fmt").fmt
return {
  s("zoom-joko", fmt([[
    [Joko's Personal Zoom Room](https://dynatrace.zoom.us/j/4336505524?pwd=NjIwVUxmMldZK0dRSVpMdlNKUzlRQT09)
  ]], {}, { delimiters = "<>" }))
}
