-- Import luasnip functions
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- YAML loader function
local function load_team_config()
  local yaml_path = vim.fn.expand("~/.config/yaml-supplier/team_care.yml")

  -- Check if file exists
  if vim.fn.filereadable(yaml_path) ~= 1 then
    vim.notify("Team care YAML file not found: " .. yaml_path, vim.log.levels.WARN)
    return nil
  end

  -- Check if yq is available for YAML parsing
  if vim.fn.executable("yq") ~= 1 then
    vim.notify("yq not found. Install yq for YAML parsing or update team_care.yml manually", vim.log.levels.WARN)
    return nil
  end

  -- Use yq directly to convert YAML to JSON
  local yq_cmd = string.format("yq . %s --output-format json", yaml_path)
  local portable_ok, portable = pcall(require, 'config.portable')
  local result_json = ""

  if portable_ok then
    result_json = portable.safe_system(yq_cmd, "team_config_loader")
  else
    -- Fallback to direct system call if portable module not available
    local ok, handle = pcall(io.popen, yq_cmd)
    if ok and handle then
      result_json = handle:read("*a")
      handle:close()
    end
  end

  if result_json == "" or result_json:match("parse error") then
    vim.notify("Failed to parse YAML file: " .. yaml_path, vim.log.levels.WARN)
    return nil
  end

  -- Decode JSON
  local ok, config = pcall(vim.json.decode, result_json)
  if not ok then
    vim.notify("Failed to decode JSON from YAML: " .. tostring(config), vim.log.levels.WARN)
    return nil
  end

  return config
end

-- Get team configuration with empty fallback
local function get_team_config()
  local config = load_team_config()

  if config then
    vim.notify("Loaded team config from YAML: " .. #config.team_members .. " members", vim.log.levels.INFO)
    return config
  end

  -- Empty fallback - no sensitive data hardcoded
  vim.notify("No team configuration available. Check ~/.config/yaml-supplier/team_care.yml and yq installation.",
    vim.log.levels.WARN)
  return {
    team_members = {},
    sprint = "SPRINT-UNAVAILABLE",
    team_name = "Team",
    team_type = "unknown"
  }
end

-- Load team configuration
local team_config = get_team_config()
local team_members = team_config and team_config.team_members or {}

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
      --f(function() return string.rep('-', 80) end, {}, {}),
      LF(),
      t({ '* DONE Jonathan 1:1 ' .. member.name }),
      LF(),
      f(function(values)
        return "  CLOSED: [" .. require 'date_utils'.timestamp_orgmode() .. "]"
      end, {}),
      LF(),
      f(function(values)
        local multiline = string.format([[  :PROPERTIES:
  :OPENED: [%s]
  :TYPE: Team Captain
  :BY: Jonathan Komar
  :END:]], require('date_utils').timestamp_orgmode())
        return vim.split(multiline, '\n')
      end, {}),
      LF(),
      t(''),
      LF(),
      sn(nil, fmt([[
# Why do we do this: It is about building trust and a connection
# https://andiroberts.com/leadershiplibrary/
      ]], {}, { delimiters = "{}" })),

      --f(function() return string.rep('-', 80) end, {}, {}),
      LF(),
      LF(),
      sn(nil, fmt([[
# Coaching (for development vs for performance) whereby -> Try to shift to "Development"
# (shifts from the problem to the person handling the problem)
#
# How to focus on a topic: Let them choose between 3 Ps
#
# We can approach this from different angles / Given topic X, approach three anglesfacets/perspective using the 3 P Model:
# (for deciding which aspect of a challenge might be at the heart of a difficulty that the person is working through)
# -> Project, Person, Pattern  (Bungay Stanier (2016, chap. 1, page 39))
#
# development: turning focus from the issue to person, focus on who is dealing with the issue
# performance: addresses and fixing a specific problem or challenge, putting out the fire, banking the fire
      ]], {}, {})),
      sn(nil, fmt([[
# The 7 Coaching Habit Questions come from Michael Bungay Stanier’s book
# The Coaching Habit: Say Less, Ask More & Change the Way You Lead Forever.
# They’re designed to make coaching conversations practical and effective:
# 1.	The Kickstart Question: “What’s on your mind?”
#     → Opens the conversation and focuses quickly on what matters most.
# 2.	The AWE Question: “And what else?”
#     → Encourages deeper thinking and prevents jumping too quickly to solutions.
# 3.	The Focus Question: “What’s the real challenge here for you?”
#     → Helps cut through the noise to the core issue.
# 4.	The Foundation Question: “What do you want?”
#     → Surfaces clarity about needs and goals.
# 5.	The Lazy Question: “How can I help?”
#     → Prevents assumptions about what support is actually useful.
# 6.	The Strategic Question: “If you’re saying yes to this, what are you saying no to?”
#     → Encourages conscious prioritization and trade-offs.
# 7.	The Learning Question: “What was most useful for you?”
#     → Reinforces reflection and embeds learning from the conversation.
      ]], {}, { delimiters = "{}" })),
      LF(),
      t('# Whats on your mind?'),
      LF(),
      sn(nil, fmt([[
# Building Trust and Connection
# https://andiroberts.com/leadershiplibrary/
# If you want to do great work, make great connections https://andiroberts.com/community-peterblock-booksummary/
# **  Where are you personally?
# **  Where are you professionally?
# ** What is the biggest challenge facing you now?
      ]], {}, {})),
      LF(),
      t('** Open Points / Follow-Up'),
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



  -- Use to convert team member name into a fully formatted block
  local function team_member_to_block_nodes(idx, team_member)
    local isPO = function(member)
      if (member['roles'] == nil) then return false end
      return has_value(member.roles, 'PO')
    end
    local isDevManager = function(member)
      if (member['roles'] == nil) then return false end
      return has_value(member.roles, 'Dev Manager')
    end
    local isOrgLead = function(member)
      if (member['roles'] == nil) then return false end
      return has_value(member.roles, 'Org Lead')
    end
    -- fmt only works with direct string input and does not accept textNodes
    -- this is unforunate.
    local nodes = {}
    if (isPO(team_member)) then
      local a = Utils.appender_function_hof(nodes)
      a(t(string.format('** %s (%s)', team_member.name, table.concat(team_member.roles, " "))))
      a(LF())
      a(t('*** PO Updates'))
      a(LF())
      -- a(t('- '))
      -- a(LF())
      a(LF())
      return nodes
    end
    if (isDevManager(team_member) or isOrgLead(team_member)) then
      return nodes
    end
    local a = Utils.appender_function_hof(nodes)
    a(t(string.format('** %s', team_member.name)))
    a(LF())
    --a(t('- ')) --  a(i(idx + 2, string.format('%s', idx +1)))
    a(LF())
    return nodes
  end

  local daily_standup_nodes = {
    --f(function() return string.rep('-', 80) end, {}, {}),
    --f(Utils.make_line, {}, { user_args = { line_char = "underscore", char = { "_" }, times = { 80 } }}),
    t({ string.format('* DONE :care: Daily Standup Sprint %s (%s)', conf.sprint, require 'date_utils'.datestamp_orgmode()) }),
    LF(),
    f(function(values)
      return "  CLOSED: [" .. require 'date_utils'.timestamp_orgmode() .. "]"
    end),
    LF(),
    f(function(values)
      local multiline = string.format([[  :PROPERTIES:
  :OPENED: [%s]
  :TYPE: Team Captain
  :BY: Jonathan Komar
  :END:]], require('date_utils').timestamp_orgmode())
      return vim.split(multiline, '\n')
    end, {}),
    -- f(function() return string.rep('-', 80) end, {}, {}),
    --f(Utils.make_line, {}, { user_args = { "single" } }),
    LF(),
    t('** Sprint Goal(s)'),
    LF(),
    f(function(_)
      local sprint_goal = "SPRINT_GOAL_UNKNOWN"

      if vim.fn.executable('sprint_goal_supplier') == 1 then
        local ok, process = pcall(io.popen, 'sprint_goal_supplier')
        if ok and process then
          local stdout = process:read('*l')
          local rc = { process:close() }
          if stdout and stdout ~= "" then
            sprint_goal = stdout
          end
        end
      end
      return sprint_goal
    end, {}),
    LF(),
    t('** :postal_horn: Announcements'),
    LF(),
    t('[[https://dt-rnd.atlassian.net/issues?jql=summary%20~%20%22DTP%20Support%20%2F%20Enablement%22%20AND%20%20(%22Team%5BTeam%5D%22%20%3D%2039167d95-7b82-4268-8b46-83d2ac7006d7-1304)%20AND%20Sprint%20in%20openSprints()%20ORDER%20BY%20issuekey][Who is goalkeeper?]]'),
    i(1), -- convenience cursor position TODO add indexed insert notes for each position for each member
    LF(),
    t('** :wip: Poststandup Sync Topics'),
    LF(),
    LF(),
    t('** Hurdles or Action Points'),
    LF(),
    LF(),
    t('** Remarks for Team Captain'),
    LF(),
    LF()
  }

  Utils.insert_nodes(daily_standup_nodes, 2, members, team_member_to_block_nodes)
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
  -- table.insert(nodes, f(function() return string.rep('_', 80) end, {}, {}))
  return { s("standup-care", daily_standup_nodes) }
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
-- Determine sprint number from various sources
local sprint_number = "SPRINT-UNAVAILABLE"

-- 1. Try sprint_supplier executable first
if vim.fn.executable('sprint_supplier') == 1 then
  local ok, process = pcall(io.popen, 'sprint_supplier')
  if ok and process then
    local stdout = process:read('*l')
    local rc = { process:close() }
    if stdout and stdout ~= "" then
      sprint_number = stdout
    end
  end
end


-- 2. Fallback to team config if sprint_supplier failed
if sprint_number == "SPRINT-UNAVAILABLE" and team_config and team_config.sprint then
  sprint_number = team_config.sprint
end

-- Generate snippets with determined sprint number
if team_members and #team_members > 0 then
  snippets = generate_snippets(team_members, {
    sprint = sprint_number,
    goal = sprint_goal,
    team_name = team_config and team_config.team_name or "Team",
    team_type = team_config and team_config.team_type or "unknown"
  })
else
  vim.notify("No team members found! Check your team_care.yml file.", vim.log.levels.WARN)
  snippets = {}
end

return snippets
