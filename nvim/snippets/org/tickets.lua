local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local ticketToContext = function(args, snip, old_state, user_args1)
  if (#snip.snippet.env.LS_SELECT_RAW > 0) then
    return sn(nil,
      {
        t("Story "),
        t(snip.snippet.env.LS_SELECT_RAW),
      })
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

local ticketTaskTemplate = [[
  [#<priority>] <ticket_type> <ticket> <description> <tags>
]]

return {
  -- TODO desired choice of Story, Bug, etc.

  s("ticket", fmt(ticketTaskTemplate, {
      priority = i(1, "A"),
      ticket_type = i(2, "Story"),
      -- ticket_type = c(2, {
      --   t("Story"),
      --   t("Bug"),
      --   t("RFA"),
      --   t("Research")
      -- }),
      ticket = d(3, ticketToContext),
      description = i(4),
      tags = f(function(values)
        local param_str = values[1][1]
        return string.format(":%s:", param_str:gsub("-", "_"))
      end, { ticket })

    },
    { delimiters = "<>" })
  )

  -- ------------------------------------------------------------------------------
  --                             SnippetNode Usage                              --
  --                                  Examples                                  --
  -- ------------------------------------------------------------------------------
  -- local lazyFunctionReturningSnippetNode = function(args, snip, old_state, user_args1,...user_argsN)
  --   local firstNodeRef = args[1][1]
  --   local nodes = {}
  --   return sn(nil, nodes)
  -- end
  -- local node_references = 1
  -- -- dynamicNode(idx, lazyFunctionReturningSnippetNode, { node_references }, { opts })
  -- -- d(jump_index, function, node-references, opts)
  -- s("sometrigger", fmt([[
  -- SomeText {}
  -- ]], { d(1, lazyFunctionReturningSnippetNode, { nodeRefsAvailableIn_lazyFunctionReturningSnippetNode }, {
  --       user_args = { --  special key
  --         -- Pass the functions used to manually update the dynamicNode as user args.
  --         -- The n-th of these functions will be called by dynamic_node_external_update(n).
  --         -- These functions are pretty simple, there's probably some cool stuff one could do
  --         -- with `ui.input`
  --         function(snip) snip.rows = snip.rows + 1 end,
  --       }
  --     })
  --   })
  -- )kkkkkkkkkkkk
  --
  --
  -- d(1, function(args, parent)
  --   local insertSnippetNodeFromSelectionElseInsertNode = function(args, parent)
  --     if (#parent.snippet.env.LS_SELECT_RAW > 0) then
  --       return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
  --     else -- If LS_SELECT_RAW is empty, return a blank insert node
  --       return sn(nil, i(1))
  --     end
  --   end
  --   insertSnippetNodeFromSelectionElseInsertNode(args, parent)
  -- end)
}
