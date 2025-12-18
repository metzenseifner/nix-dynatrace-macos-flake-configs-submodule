return {
  s({ trig = "multiTrigger", snippetType = "snippet", desc = "Multiple triggers for the same snippet" }, fmt([[
    local ms = require("luasnip").multisnippet
    -- ms(contexts, nodes, opts) -> addable
    ms({
    		{trig = "matchme", condition = function(line_to_cursor) return line_to_cursor ~= "matchme" end, snippetType = "snippet"},
    		{trig = "matchmetoo", condition = function(line_to_cursor) return line_to_cursor ~= "matchmetoo" end, snippetType = "snippet"},
    	},
      { t"some node"},
      nil),
  ]], {}, { delimiters = "[]" })),
  s("s", fmt([=[
    --- @param trig string: The trigger for the snippet
    --- @param nodes table: The nodes that make up the snippet
    s({trig="triggertext", snippetType= ,desc=""}, fmt([[
      content
    ]], {}, {delimiters="<<>>"}))
  ]=], {}, { delimiters = "<>" })),
  s("camelcase-lower-initial-func", fmt([[local lowerCamelCase = values[1][1]:gsub("^%u", string.lower)]], {}, {})),
  s("f", fmt([[function(args,snip) return <body> end]], { body = i(1) }, { delimiters = "<>" })),
  s("functionNode-identity", fmt([[
  f(function(values) return values[1][1] end, { <> })
  ]], { i(1, "list of node indexes you want in the values table") }, { delimiters = "<>" })),
  -- s("dynamic node example", fmt([=[
  --   [[<url>],[<title>]]
  -- ]=], {
  --   -- https://www.youtube.com/watch?v=vLb6k5cfJ-g&list=PL0EgBggsoPCnZ3a6c0pZuQRMgS_Z8-Fnr&index=4
  --   url = d(1, function(args, parent_node)
  --     local choices = {
  --       "Story",
  --       "Bug",
  --       "RFA",
  --       "Vulnerability",
  --     }
  --     for index, value in ipairs(choices) do
  --       choiceToChoiceNode
  --     end
  --
  --     if (#parent.snippet.env.LS_SELECT_RAW > 0) then
  --       return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
  --     else -- If LS_SELECT_RAW is empty, return a blank insert node
  --       return sn(nil, i(1, "<url>"))
  --     end
  --   end),
  --   title = i(2, "title")
  -- }, { delimiters = "<>" })),
  s({trig="d", desc="dynamic node using selected text"}, fmt([[
  d(1, function(args, parent)
    local insertSnippetNodeFromSelectionElseInsertNode = function(args, parent)
      if (#parent.snippet.env.LS_SELECT_RAW > 0) then
        return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
      else -- If LS_SELECT_RAW is empty, return a blank insert node
        return sn(nil, i(1))
      end
    end
    insertSnippetNodeFromSelectionElseInsertNode(args, parent)
  end)
  ]], {}, {})),
  s("dynamicNode", fmt([==[
  ------------------------------------------------------------------------------
                              SnippetNode Usage                              --
                                   Examples                                  --
  ------------------------------------------------------------------------------
  local lazyFunctionReturningSnippetNode = function(args, snip, old_state, user_args1,...user_argsN)
    local firstNodeRef = args[1][1]
    local nodes = {}
    return sn(nil, nodes)
  end
  local node_references = 1
  -- dynamicNode(idx, lazyFunctionReturningSnippetNode, { node_references }, { opts })
  -- d(jump_index, function, node-references, opts)
  s("sometrigger", fmt([[
  SomeText {}
  ]], { d(1, lazyFunctionReturningSnippetNode, { nodeRefsAvailableIn_lazyFunctionReturningSnippetNode }, {
        user_args = { --  special key
          -- Pass the functions used to manually update the dynamicNode as user args.
          -- The n-th of these functions will be called by dynamic_node_external_update(n).
          -- These functions are pretty simple, there's probably some cool stuff one could do
          -- with `ui.input`
          function(snip) snip.rows = snip.rows + 1 end,
        }
      })
    })
  )
  ]==], {}, { delimiters = "<>" })),
  s("triggers-multiple", fmt([[
    ls.setup_snip_env()

    local ms = ls.multi_snippet

    ls.add_snippets("all", {
      ms({
        {trig = "a", condition = function(ltc) return ltc ~= "a" end, snippetType = "autosnippet"},
        {trig = "b", condition = function(ltc) return ltc ~= "b" end},
        "c"
      }, {t"a or b"})
    }, {
      key = "ab"
    })
  ]], {}, { delimiters = "<>" })),
}
