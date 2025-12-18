local c = require("luasnip").choice_node

local visualSelectionOrInsert = function(args, parent)
  if (#parent.snippet.env.LS_SELECT_RAW > 0) then
    return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

local keysToNodes = function(tbl, snippetNodeFn)
  targetSnippetNode = node or snippetNodeFn
  local keyToNode = function(key)
    return targetSnippetNode(key)
  end
  local nodes = {}
  for k, v in pairs(tbl) do
    table.insert(nodes, keyToNode(k))
  end
  return nodes
end

-- should become deprecated
local categories = {
  'TODO',
  'COMMITMENT',
  'GOAL',
  'INPROGRESS',
  'FEEDBACK',
  'REVIEW',
}

-- Todo = { props = { {name="BY", default="Jonathan Komar"}, "FOR" } },
-- maps types to todo properties
local todo_types = {
  Feedback = { props = { "BY", "FOR" }, content = { "# Behavior, Effect, Desire Model (B.E.D.)", "Situation, Behavior, Impact Model (S.B.I.)", "You've shown up late to our 1:1 several times now, making we wait for you in our calls. This makes me feel like you're not valuing me and my time. What can we do to resolve this and fully use our scheduled time" } },
  Task = { props = { "BY", "FOR" } },
  ["Follow-up"] = { props = { "BY", "FOR" } },
  Ticket = { props = { { name = "BY", default = "Jonathan Komar" }, "REF", "SUBREF", "PARENTREF", "SPRINT" } },
  Goal = { props = { "BY", "LEAD" }, desc = { "A S.M.A.R.T. goal." } },
  Gap = { props = { "BY", "LEAD" }, desc = { "There are two kinds of gaps: 1. Gaps according to you (self-analysis gaps) and 2. Gaps according to others that you didn't know about (blind spots) These describe what is between you and your goal." } },
  Commitment = { props = { "BY", "LEAD" }, desc = { "An action that your agree to." } },
  Announcement = { "BY", "FOR" },
  ["Self-assessment"] = { "BY", "LEAD" },
  Wish = { props = { "BY", "LEAD" }, desc = { "A desire to achieve something." } },
  ["Team Captain"] = { props = { { name = "BY", defaultValue = "Jonathan Komar" } }, desc = { "Team Captain specific task" } },
  ["Daily"] = { props = { "BY", "FOR" }, desc = { "Daily tasks" } },
  Initiative = { props = { "BY", "COLLABORATORS", "FACILITATOR", "LEAD" }, desc = { "Track initiatives" } },
  Observation = { props = { { name = "BY", defaultValue = "Jonathan Komar" }, "FOR" }, desc = { "An observation, perhaps notable, perhaps contributes to formal feedback." } },
}

local todo_template_sample = [[
* TODO [#A] Some nice title{ticket}
  DEADLINE: <2025-02-11 Tue>
  :PROPERTIES:
  :OPENED: [{timestamp}]
  :TYPE: Gap
  :BY: {by} -- meaning: done by
  :FOR: {for} -- person who is affected
  :END:
  <content>
]]

local todo_template = [[
{depth} TODO {ticket}{desc}
  DEADLINE: <{deadline}>
  :PROPERTIES:
  :OPENED: [{timestamp}]
  :TYPE: {todo_type}{dynamic}
  :END:
  {body}
]]

return {
  s({ trig = "TODO", snippetType = "autosnippet" }, fmt(todo_template, {
      desc = d(1, visualSelectionOrInsert),
      -- priority = c(2, { t("[#A]"), t("[#B]"), t("[#C]") }),
      depth = t("*"),
      todo_type = c(2, keysToNodes(todo_types, t)),
      ticket = f(function(values)
        local todo_type = values[1][1]
        local props = todo_types[todo_type] and todo_types[todo_type].props or {}
        for _, prop in ipairs(props) do
          if (type(prop) == "string" and prop == "REF") or (type(prop) == "table" and prop.name == "REF") then
            return " [#A] Some nice title"
          end
        end
        return ""
      end, { 2 }),
      body = d(4, function(values)
        local todo_type = values[1][1]
        local content = todo_types[todo_type].content or {}
        local nodes = {}
        if content == {} then
          return sn(nil, { i(1) })
        end
        for i, line in ipairs(content) do
          table.insert(nodes, sn(idx,
            sn(i, { t(line) }, { indent_string = "", dedent = false })))
        end
        table.insert(nodes, sn(i, { i(1) }, { indent_string = "", dedent = false }))
        return sn(nil, nodes)
      end, { 2 }),
      -- dynamic= t("test"),
      dynamic = d(3, function(values)
        local todo_type = values[1][1]
        local props = todo_types[todo_type].props or {}
        local nodes = {}
        if props == {} then
          return sn(nil, { t("") })
        end
        for idx, prop in ipairs(props) do
          if type(prop) == "string" then
            table.insert(nodes,
              sn(idx, fmt('\n\n  :{}: {}', { t(prop), i(1, '_value_') }, { indent_string = "", dedent = false })))
          else -- assume table
            table.insert(nodes,
              sn(idx,
                fmt('\n\n  :{}: {}', { t(prop.name), i(1, prop.defaultValue) }, { indent_string = "", dedent = false })))
          end
        end
        -- isn(1, nodes, "$PARENT_INDENT\t")
        return sn(nil, nodes)
      end, { 2 }),
      timestamp = f(function(_, _, _) return require("date_utils").timestamp_orgmode() end, {}, {}),
      deadline = f(function() return require "date_utils".datestamp_orgmode() end, {}, {}),
    },
    { delimiters = "{}" }))
}
