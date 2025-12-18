local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

local predicates = {}
function predicates.in_text()
  return true
end

-- Extensible list of org block environments
-- Add or remove block types here as orgmode develops
local org_block_types = {
  "SRC",
  "QUOTE",
  "EXAMPLE",
  "CENTER",
  "VERSE",
  "EXPORT",
  "COMMENT",
  "HTML",
  "LATEX",
}

return {

  s({ trig = '#+BEGIN', name = 'org-block', dscr = 'Org mode block with visual selection support' },
    {
      t("#+BEGIN_"),
      c(1, vim.tbl_map(function(block_type)
        return i(nil, block_type)
      end, org_block_types)),
      t({ "", "" }),
      d(2, function(args, parent)
        local selection = parent.snippet.env.LS_SELECT_RAW
        if selection and #selection > 0 and selection[1] ~= "" then
          return sn(nil, t(selection))
        else
          return sn(nil, i(1))
        end
      end),
      t({ "", "#+END_" }),
      f(function(args)
        return args[1][1]
      end, { 1 }),
    }
  ),
  s("url-add-url", fmt([[
    <content>
  ]], {
    content = d(1, function(args, parent_node)
      local selectedText = parent_node.snippet.env.LS_SELECT_RAW
      if (#selectedText > 0) then
        return sn(nil, fmt([=[
          [[<url>][<title>]]
        ]=], { title = t(selectedText), url = i(1, "__url__") }, { delimiters = "<>" }))
      else -- If LS_SELECT_RAW is empty, return a blank insert node
        return sn(nil, i(1, "<url>"))
      end
    end),
  }, { delimiters = "<>" })),

  s("url-add-title",
    fmt([=[
    <content>
  ]=], {
      content = d(1, function(args, parent_node)
        local selectedText = parent_node.snippet.env.LS_SELECT_RAW
        if (#selectedText > 0) then
          return sn(nil, fmt([=[
          [[<url>][<title>]]
        ]=], { url = i(2, selectedText), title = i(1) }, { delimiters = "<>" }))
        else -- If LS_SELECT_RAW is empty, return a blank insert node
          return sn(nil, i(1, "<url>"))
        end
      end),
    }, { delimiters = "<>" })),
  s(
    {
      trig = "FeedbackAutoSnippet",
      snippetType = "autosnippet",
      desc =
      "Feedback expansion for orgmode since it only supports interpolating variables once."
    },
    fmta([[
      <>
      ** TODO Refine Feedback %%?
      DEADLINE: _ OPENED: [_]
    ]], { i(1, "text") }
    )
  )

}
