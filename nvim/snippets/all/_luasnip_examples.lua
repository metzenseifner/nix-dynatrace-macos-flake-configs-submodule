local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")


--node.snippet.env contains
--LS_TRIGGER: text that triggered the snippet
--LS_SELECT_RAW:
--LS_SELECT_DEDENT
--TM_SELECTED_TEXT: for VS CODE capatibility

--------------------------------------------------------------------------------
--                                Useful nodes                                --
--------------------------------------------------------------------------------
-- :help luasnip-snippetnode :: returns a list of nodes
-- :help luasnip-dynamicnode :: returns a snippetNode
-- :help luasnip-functionnode :: returns a string
--
--------------------------------------------------------------------------------
--                           SnippetNode vs Snippet                           --
--------------------------------------------------------------------------------
-- Snippet[arg0] :: a table describing when to expand and optional description
-- SnippetNode[arg0] :: an integer describing a proxy jump index that may be nil if unused
--
-- # Example
-- Here we have a snippet and a snippetNode
-- local mySnippetNode = sn(1, {t("text then"), i(1, And an insert node.)})
-- local mySnippet = s("sometrigger", snippetNode)
-- The snippet node has a jump index, which will match the insertNode's index.
-- Note that i(0) does not work within snippetNodes.

--------------------------------------------------------------------------------
--                             SnippetNode Usage                              --
--                                  Examples                                  --
--------------------------------------------------------------------------------
local nodes = {}
sn(nil, nodes)

-- use vimtex to determine if we are in a math context
local function math()
  return vim.api.nvim_eval('vimtex#syntax#in_mathzone()') == 1
end

--test whether the parent snippet has content from a visual selection. If yes, put into a text  node, if no then start an insert node
local visualSelectionOrInsert = function(args, parent)
  if (#parent.snippet.env.LS_SELECT_RAW > 0) then
    return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end
local get_visual_selection = function(args, parent)
  if (#parent.snippet.env.LS_SELECT_RAW > 0) then
    return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
  end
end


--s("selected_text", f(function(args, snip)
--  local res, env = {}, snip.env
--  table.insert(res, "Selected Text (current line is " .. env.TM_LINE_NUMBER .. "):")
--  for _, ele in ipairs(env.LS_SELECT_RAW) do table.insert(res, ele) end
--  return res
--end, {}))

return {
  -- snippetType snippet calling expand required | autosnippet chars replaced immediately without need to run expand
  -- desc: A description of the snippet
  -- wordTrig: When true, the snippet will only trigger if there are no preceding characters.
  s({ trig = "helloworld", snippetType = "snippet", desc = "A hellow world snippet", wordTrig = true },
    { t("Just a hint of what's to come!"), }
  ),
  --------------------------------------------------------------------------------
  --                Auto apply snippet immediately after trigger                --
  --                            text has been typed                             --
  --------------------------------------------------------------------------------

  --s({ trig = "\"", snippetType = "autosnippet", desc = "quotation marks" },
  --  fmta(
  --    [[``<>'' ]],
  --    { i(1, "text"), }
  --  )
  --),
  s({ trig = "env", snippetType = "snippet", desc = "Begin and end an arbitrary environment" },
    fmta(
      [[
        \begin{<>}
            <>
        \end{<>}
        ]],
      { i(1), i(2), rep(1), }
    )
  ),
  --------------------------------------------------------------------------------
  --              write snippets that only trigger if we are in a               --
  --                              specific context                              --
  --                The context is a predicate function that can                --
  --             return true if cursor is in the expected context.              --
  --             The math function checks whether the cursor is in              --
  --                            a LaTeX "math zone".                            --
  --------------------------------------------------------------------------------

  --postfixes for vectors, hats, etc. The match pattern is '\\' plus the default (so that hats get put on greek letters,e.g.)
  --  postfix(
  --    {
  --      trig = "hat",
  --      match_pattern = [[[\\%w%.%_%-%"%']+$]], -- if hat is typed after word which has alphanumeric characters or slashes, activate the snippet.
  --      -- I added the escaped backslash (\\) to LuaSnip’s default pattern so that \alphahat (or even ;ahat, thanks to our autosnippet above) correctly gets turned into \hat{\alpha}.
  --      snippetType = "autosnippet",
  --      dscr =
  --      "postfix hat when in math mode"
  --    },
  --    { l("\\hat{" .. l.POSTFIX_MATCH .. "}") },
  --    { condition = math }
  --  ),
  --  postfix(
  --    {
  --      trig = "vec",
  --      match_pattern = [[[\\%w%.%_%-%"%']+$]],
  --      snippetType = "autosnippet",
  --      dscr =
  --      "postfix vec when in math mode"
  --    },
  --    { l("\\vec{" .. l.POSTFIX_MATCH .. "}") },
  --    { condition = math }
  --  ),
  --------------------------------------------------------------------------------
  --               send visually selected text to a snippet node                --
  --                    (already typed text to snippet node)                    --
  --------------------------------------------------------------------------------
  -- take a visual selection mode and wrap it in a \textbf{} command.
  s("textbf",
    f(function(args, snip)
      local res, env = {}, snip.env
      for _, ele in ipairs(env.LS_SELECT_RAW) do table.insert(res, "\\textbf{" .. ele .. "}") end
      return res
    end, {})),
  --------------------------------------------------------------------------------
  --             A “dynamic node” is like a function node, but              --
  --             with a difference: function nodes ultimately             --
  --               just return text, but dynamic nodes can return               --
  --              snippet nodes! This allows you to do wild things              --
  --                 with recursion, or more straightforwardly                  --
  --              dynamically define the set of nodes you want to               --
  --                        have a snippet expand into.                         --
  --------------------------------------------------------------------------------
  -- same as textbf above, but can handle both insert mode or visual selection mode
  -- usage: visually select any text and use the store_select_keys key stroke (default: <Tab>)
  s({ trig = "emph", desc = "the emph command, either in insert mode or wrapping a visual selection" },
    fmta("\\emph{<>}", { d(1, visualSelectionOrInsert), })
  ),
  -- s({ trig = "", desc = "Apply URL to visual selection." }, fmta("[[<link>][<description>]]", { d(1,
  --   function(args, parent)
  --     if (#parent.snippet.env.LS_SELECT_RAW > 0) then
  --       return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
  --     else
  --       return sn(nil, t(parent))
  --     end
  --   end), })
  -- ),
  --  s({ trig = ";I", snippetType = "autosnippet", desc = "integral with infinite or inserted limits", wordTrig = false },
  --    fmta([[
  --        <>
  --        ]],
  --      {
  --        c(1, {
  --          t("\\int_{-\\infty}^\\infty"),
  --          sn(nil, fmta([[ \int_{<>}^{<>} ]], { i(1), i(2) })),
  --        })
  --      }
  --    )
  --  ),
  -- Return visual selection, else return the whatever was cut
  -- usage: visually select any text and use the store_select_keys key stroke (default: <Tab>)
  --s({ trig = "url", desc = "add URL" },
  --  { fmta("[<title>](<url>)}", { title = d(1, get_visual_selection), url = i(2, "url") })
  --  }),
  s(
    {
      trig = "node-from-selection-dynamic",
      desc =
      "example of url-add-title. -- usage: visually select any text and use the store_select_keys key stroke (default: <Tab>)"
    },
    t([==[
  s(
    {
      trig = "node-from-selection-dynamic",
      desc =
      "example of url-add-title. -- usage: visually select any text and use the store_select_keys key stroke (default: <Tab>)"
    },
  fmt([[
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
  ]==])),



}
