-- Import luasnip functions
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local team_members = {
  { name = 'Jonathan Komar',     roles = { 'Team Captain' } },
  { name = 'Bernhard Fritz' },
  { name = 'Claudia Wisböck',    roles = { 'PO' } },
  { name = 'Johannes Troppacher' },
  { name = 'Simon Kleinfeld' },
  { name = "Daniel Carp-Popescu" },
  { name = "Michael Bernard",    roles = { "Dev Manager" } },
  { name = "Bernhard Dieber",    roles = { "Org Lead" } }
}

local LF = function() return t({ "", "" }) end

local Utils = {}

-- Takes a node that will be appended to.
-- returns append function appending to node
function Utils.appender_function_hof(tbl)
  return function(node)
    table.insert(tbl, node)
  end
end

function Utils.make_line(
    args_from_other_nodes,
    parent_snippet_or_node,
    user_args
)
  --vim.schedule_wrap(P(args))
  --local title = args[1][1]
  --local str_len = vim.fn.strlen(title)
  local line_width = user_args.times
  --local LF() = "\010"
  local char = user_args.char
  if user_args.line_char == "single" then
    char = "-"
  elseif user_args.line_char == "double" then
    char = "="
  elseif user_args.line_char == "underscore" then
    char = "_"
  end
  local underline = string.rep(char, line_width)
  return underline
end

--  for idx, data in pairs(table_of_data) do
--    for _, node in pairs(Utils.team_member_to_block_nodes(init_jump_idx + idx, member)) do
--     table.insert(member_nodes, node)
--    end
--  end


-- insert_nodes :: (initial_table, jump_idx_offset, data_tbl, data_to_nodes_function) -> Table<Nodes>
-- data_to_nodes_function :: (offsetJumpIndex, elementOfData) -> Table<Nodes>
function Utils.insert_nodes(target_table, jump_idx_offset, data_tbl, data_to_nodes_function)
  for idx, entry in pairs(data_tbl) do
    for _, node in pairs(data_to_nodes_function(jump_idx_offset + idx, entry)) do
      table.insert(target_table, node) -- <== this is why lua is bad, mutable args
    end
  end
end

-- all functions return a table of snippets
local generators = {}

--- @returns a table of snippets
generators.one_on_one = function(members, conf)
  local snippets = {}
  for _, member in pairs(members) do
    table.insert(snippets, s(string.format("one-on-one-%s", member.name), {
      f(function() return string.rep('_', 80) end, {}, {}),
      LF(),
      t({ '# Jonathan 1:1 ' .. member.name }),
      LF(),
      f(require 'date_utils'.daystamp, {}, {}),
      LF(),
      f(function() return string.rep('-', 80) end, {}, {}),
      LF(),
      LF(),
      t('## Personal Private Notes'),
      LF(),
      LF(),
      t('  - '), i(1, ''),
      LF(),
      LF(),
      t('## Uncategorized Chat'),
      LF(),
      LF(),
      t('  - '), i(1, ''),
      LF(),
      LF(),
      t('## Updates from their side: (Notes you take from their “10mins”)'),
      LF(),
      LF(),
      t("  - What's on your mind?"), i(2, ''),
      LF(),
      LF(),
      t('## Updates from my side: (Notes you make from your “10mins”)'),
      LF(),
      LF(),
      t('  - '), i(3, ''),
      LF(),
      LF(),
      t('## Open Points / Follow-Up: (Where are they headed? AND, Items that you’ll review at the next meeting)'),
      LF(),
      LF(),
      t('  - '), i(4, ''),
      LF(),
      LF(),
      f(function() return string.rep('_', 80) end, {}, {}),
    }))
  end
  return snippets
end

local function has_value(tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return true
    end
  end

  return false
end
generators.standup = function(members, conf)
  local team_member_to_str = function(a)
    return string.format("  - %s", a.name)
  end
  --local member_iterator = vim.iter(members)
  --member_iterator:map(function(m)
  --  t(Utils.team_member_to_str(member))
  --end)
  --local member_nodes = member_iterator:totable()

  local isPO = function(member)
    if (member['roles'] == nil) then return false end
    return has_value(member.roles, 'PO')
  end

  -- Use to convert team member name into a fully formatted block
  local function team_member_to_block_nodes(idx, team_member)
    -- fmt only works with direct string input and does not accept textNodes
    -- this is unforunate.
    local nodes = {}
    if (isPO(team_member)) then
      local a = Utils.appender_function_hof(nodes)
      a(t(string.format('## %s', team_member.name)))
      a(LF())
      a(t('    - PO Updates'))
      a(LF())
      a(t('      - '))
      a(LF())
      a(LF())
      return nodes
    end
    local a = Utils.appender_function_hof(nodes)
    a(t(string.format('## %s', team_member.name)))
    a(LF())
    a(t('  - Yesterday'))
    a(LF())
    a(t('   - ')) -- a(i(1))
    a(LF())
    a(t('  - Today'))
    a(LF())
    a(t('   - ')) --  a(i(idx + 2, string.format('%s', idx +1)))
    a(LF())
    a(LF())
    return nodes
  end

  local nodes = {
    f(function() return string.rep('_', 80) end, {}, {}),
    --f(Utils.make_line, {}, { user_args = { line_char = "underscore", char = { "_" }, times = { 80 } }}),
    LF(),
    t({ '# Daily Standup Sprint ' .. conf.sprint }),
    LF(),
    --f(function()return 'date'end, {}, {}),
    f(require 'date_utils'.daystamp, {}, {}),
    LF(),
    f(function() return string.rep('-', 80) end, {}, {}),
    --f(Utils.make_line, {}, { user_args = { "single" } }),
    LF(),
    t('## :postal_horn: *Announcements*'),
    LF(),
    t('  - '),
    i(1), -- convenience cursor position TODO add indexed insert notes for each position for each member
    LF(),
    LF(),
    t('## *Poststandup Sync Topics*'),
    LF(),
    t('  - '),
    LF(),
    LF(),
    t('## *Hurdles or Action Points*'),
    LF(),
    t('  - '),
    LF(),
    LF(),
    t('## Remarks for Team Captain'),
    LF(),
    t('  - '),
    LF(),
    LF()
  }

  Utils.insert_nodes(nodes, 2, members, team_member_to_block_nodes)
  --for idx, member_node in pairs(member_nodes) do
  --  table.insert(nodes, member_node)
  --  --table.insert(nodes, member_node)
  --  --table.insert(nodes, LF())
  --  --table.insert(nodes, t'    - ')
  --  --table.insert(nodes, i(idx+1, string.format("is working on...")))
  --  --table.insert(nodes, LF())
  --end
  --table.insert(nodes,
  --  f(Utils.make_line, { 1 }, { user_args = { "underscore" } })
  --)
  table.insert(nodes, f(function() return string.rep('_', 80) end, {}, {}))
  return { s("standup-platinum", nodes) }
end

local function generate_snippets(members, conf)
  local snippets = {}
  for _, snippet in pairs(generators.one_on_one(members, conf)) do
    table.insert(snippets, snippet)
  end
  for _, snippet in pairs(generators.standup(members, conf)) do
    table.insert(snippets, snippet)
  end
  return snippets
end

local snippets
if vim.fn.executable('sprint_supplier') == 1 then
  local ok, process = pcall(io.popen, 'sprint_supplier')
  if ok and process then
    local stdout = process:read('*l')
    local rc = { process:close() }
    snippets = generate_snippets(team_members, { sprint = stdout })
  else
    snippets = generate_snippets(team_members, { sprint = "SPRINT-UNAVAILABLE" })
  end
else
  -- Generate snippets without sprint info if sprint_supplier not available
  snippets = generate_snippets(team_members, { sprint = "SPRINT-UNAVAILABLE" })
end

return snippets
