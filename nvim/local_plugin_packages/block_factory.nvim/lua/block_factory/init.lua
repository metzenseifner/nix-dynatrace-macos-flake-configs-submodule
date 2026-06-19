-- ~/.config/nvim/lua/block_factory.lua
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local M = {}

-- The body adopts the visual selection when one was cut into the snippet (via
-- `cut_selection_keys`, i.e. visual-select → <Tab> → trigger), otherwise it is
-- an empty insert node. Either way the stop is jump-index 1 *inside* this
-- dynamicNode, which itself sits at the snippet's jump-index 2 — so it is
-- reached with a single forward jump out of the choice.
local function visual_body(_, parent)
  local selection = parent.snippet.env.LS_SELECT_RAW
  if selection and #selection > 0 then
    return sn(nil, i(1, selection))
  end
  return sn(nil, i(1, ""))
end

-- The closing terminator mirrors only the block *name* — the first
-- whitespace-delimited token of the chosen opener — so `#+begin_src python`
-- pairs with `#+end_src`.
local function head_name(args)
  return (args[1][1]:match("%S+")) or ""
end

-- blocks: ordered list of { label = string, head = function() -> node }.
-- Each head() returns the text that follows `#+begin_` (e.g. a text node
-- `quote`, or a snippetNode `src {lang}` for openers that take an argument).
-- The choiceNode (jump-index 1) cycles through them; the body (jump-index 2)
-- is a sibling, so jumping forward from the choice lands between the
-- delimiters rather than past the closing terminator.
function M.block_snippets(trigger, blocks)
  local choices = vim.tbl_map(function(block)
    return block.head()
  end, blocks)

  return s(
    { trig = trigger, desc = "Wrap a body in a #+begin_/#+end_ block" },
    fmt("#+begin_{head}\n{body}\n#+end_{tail}", {
      head = c(1, choices),
      body = d(2, visual_body),
      tail = f(head_name, { 1 }),
    })
  )
end

return M
