-------------------------------------------------------------------------------
--                               Documentation                                --
--                         from nvim-orgmode project                          --
--------------------------------------------------------------------------------
-- Filtering https://orgmode.org/manual/Matching-tags-and-properties.html

local function current_week_monday()
  local current_day = os.date("*t").wday
  local days_to_monday = (current_day == 1) and 6 or (current_day - 2)
  return os.date("%Y-%m-%d", os.time() - (days_to_monday * 24 * 60 * 60))
end

local function current_week_friday()
  local current_day = os.date("*t").wday
  local days_to_friday = (current_day == 6) and 0 or (current_day == 7) and 6 or (5 - current_day)
  return os.date("%Y-%m-%d", os.time() + (days_to_friday * 24 * 60 * 60))
end

-- Function to include properties in LaTeX export
local function include_properties_in_latex(headline)
  local properties = headline.properties
  local latex_properties = ""

  for key, value in pairs(properties) do
    latex_properties = latex_properties .. string.format("\\textbf{%s}: %s\\newline\n", key, value)
  end

  return latex_properties
end

-- Function to archive DONE TODOs older than 1 month
-- Function to archive DONE TODOs older than a specified duration (in months)
local function archive_done_items()
  local orgmode = require('orgmode')
  local headlines = orgmode.action('get_headlines')
  for _, headline in ipairs(headlines) do
    if headline.todo_keyword == 'DONE' then
      vim.notify("simulate archiving of", headline)
      -- orgmode.action('archive', headline)
    end
  end
end

local make_feedback_overview = function(members)
  local make_feedback_view_for = function(member)
    return {
      description = string.format("%s's Feedback", member.name),
      types = {
        {
          type = "tags",                                                               -- Type can be agenda | tags | tags_todo
          match = string.format('+TYPE="Feedback"&FOR="%s"&TODO="DONE"', member.name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
          org_agenda_overriding_header = string.format("# %s's Feedback Given", member.name),
        },
        {
          type = "tags_todo",                                              -- Type can be agenda | tags | tags_todo
          match = string.format('+TYPE="Feedback"&FOR="%s"', member.name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
          org_agenda_overriding_header = string.format("# %s's Feedback Ungiven", member.name),
        },
      }
    }
  end
  local feedback_boards = {}
  for i, member in ipairs(members) do
    vim.list_extend(feedback_boards, make_feedback_view_for(member))
  end
end

local make_team_development_view_for = function(make_personal_development_view_for, members)
  local member_boards = {}
  for _, member in ipairs(members) do
    vim.list_extend(member_boards, make_personal_development_view_for(member).types)
  end
  return {
    description = "Team CARE's Development Dashboard",
    types = member_boards
  }
end

-- For my personal dashboard of things to do
local make_dashboard_for = function(name)
 -- local members = { 'Jonathan Komar', 'Nikolas Keuck', 'Matthaeus Huber' }

 -- ---@return OrgAgendaCustomCommandAgenda
 -- local make_observations_types = function(members)
 --   local result = {}
 --   for i, v in ipairs(members) do
 --    --table.insert(result, 
 --    --{
 --    -- type = "tags_todo",                                       -- Type can be agenda | tags | tags_todo
 --    -- match = string.format('+TYPE="Feedback"&FOR="%s"', name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
 --    -- org_agenda_overriding_header = string.format("# %s's Feedback Ungiven", name),
 --   --})
 --   --table.insert(result,
 --    -- {
 --    --   type = "tags",                                               -- Type can be agenda | tags | tags_todo
 --    --   match = string.format('+TYPE="Observation"&FOR="%s"', name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
 --    --   org_agenda_overriding_header = string.format("# Observations of %s's ", name),
 --    --  })
 --   -- end
 --   return result
 -- en d
  ---@return OrgAgendaCustomCommandAgenda
  return function()
    local portable = require('config.portable')
    local sprint = vim.fn.trim(portable.safe_system("sprint_supplier", "orgmode_sprint"))
    local sprint_num = tonumber(sprint)
    local prev_sprint = sprint_num and (sprint_num - 1) or "N/A"

    return {
      description = string.format("%s's Dashboard of Things to Do", name),
      types = {
        --------------------------------------------------------------------------------
        --                 Special Case of Daily Tasks to not forget                  --
        --------------------------------------------------------------------------------
        {
          org_agenda_overriding_header = string.format("# %s's Daily Tasks", name),
          type = "tags",
          -- match = string.format('+TYPE="Daily"&BY="%s"&DEADLINE="<today>"', name),
          match = string.format('+TYPE="Daily"&BY="%s"&DEADLINE<="%s +1d"', name, current_week_friday())
          -- type = "agenda",
          -- org_agenda_span = "day",
          -- org_agenda_start_on_weekday = 1,
          -- org_agenda_remove_tags = false
        },
        {
          org_agenda_overriding_header = string.format("# %s's Active Tasks", name),
          type = "tags",
          -- match = string.format('+TYPE="Daily"&BY="%s"&DEADLINE="<today>"', name),
          match = string.format('+TYPE="INPROGRESS"', name)
        },
        --------------------------------------------------------------------------------
        --               Team Captain-specific tasks that might replace               --
        --                                Daily Tasks                                 --
        --------------------------------------------------------------------------------
        {
          org_agenda_overriding_header = string.format("# %s's Team Captain Tasks", name),
          type = "tags",
          match = string.format('+TYPE="Team Captain"&BY="%s"', name),
        },
        {
          org_agenda_overriding_header = string.format("# %s's Announcements", name),
          type = "tags_todo",
          match = '+TYPE="Announcement"',
        },
        {
          org_agenda_overriding_header = string.format("# %s's Follow-ups", name),
          type = "tags",
          match = string.format('+TODO="TODO"&TYPE="Follow-up"&BY="%s"', name),
        },
        {
          org_agenda_overriding_header = string.format("# %s's High Priority Items", name),
          type = "tags_todo",
          match = '+PRIORITY="A"&TODO="TODO"|+PRIORITY="A"&TODO="INPROGRESS"',
        },
        {
          org_agenda_overriding_header = string.format("# %s's Sprint %s Tickets", name, sprint ~= "" and sprint or "N/A"),
          type = "tags",
          match = string.format('BY="%s"&SPRINT="%s"', name, sprint ~= "" and sprint or "N/A"),
        },
        {
          org_agenda_overriding_header = string.format("# %s's Previous Sprint (%s) Tickets", name, prev_sprint),
          type = "tags",
          match = string.format('BY="%s"&SPRINT="%s"', name, prev_sprint),
        },
        {
          org_agenda_overriding_header = "# Initiatives",
          type = "tags",
          match = string.format('+TYPE="Initiative"')
        },
        {
          type = "tags",                                -- Type can be agenda | tags | tags_todo
          match = string.format('+TYPE="Observation"'), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
          org_agenda_overriding_header = string.format("# Observations"),
        },
        {
          org_agenda_overriding_header = string.format("# %s's Agenda of Tasks with Due or Scheduled Date", name),
          type = "agenda",
          org_agenda_span = 'week',
          org_agenda_start_on_weekday = 1, -- Start on Monday
          org_agenda_remove_tags = false   -- Do not show tags only for this view
        },
      }
    }
  end
end

-- Make a Performance Enablement / Growth Dashboard for each team member
local make_personal_development_view_for = function(name)
  return {
    description = string.format("%s's Growth View", name),
    types = {
      {
        type = "tags", -- Type can be agenda | tags | tags_todo
        match = string.format('+TYPE="Initiative"&BY="%s"', name, name),
        org_agenda_overriding_header = string.format("# %s's Initiatives", name),
      },
      {
        type = "tags",                                                                             -- Type can be agenda | tags | tags_todo
        match = string.format('+TYPE="COMMITMENT"&BY="%s"|TYPE="Commitment"&BY="%s"', name, name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
        org_agenda_overriding_header = string.format("# %s's Commitments", name),
      },
      {
        type = "tags",                                      -- Type can be agenda | tags | tags_todo
        match = string.format('+TYPE="Gap"&BY="%s"', name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
        org_agenda_overriding_header = string.format("# %s's Gaps", name),
      },
      {
        type = "tags_todo",                                  -- Type can be agenda | tags | tags_todo
        match = string.format('+TYPE="Wish"&BY="%s"', name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
        org_agenda_overriding_header = string.format("# %s's Wishes / Desires", name),
      },
      {
        type = "tags",                                       -- Type can be agenda | tags | tags_todo
        match = string.format('+TYPE="Goal"&BY="%s"', name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
        org_agenda_overriding_header = string.format("# %s's Goals", name),
      },
      {
        type = "tags",                                                        -- Type can be agenda | tags | tags_todo
        match = string.format('+TYPE="Feedback"&FOR="%s"&TODO="DONE"', name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
        org_agenda_overriding_header = string.format("# %s's Feedback Given", name),
      },
      {
        type = "tags_todo",                                       -- Type can be agenda | tags | tags_todo
        match = string.format('+TYPE="Feedback"&FOR="%s"', name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
        org_agenda_overriding_header = string.format("# %s's Feedback Ungiven", name),
      },
      {
        type = "tags",                                               -- Type can be agenda | tags | tags_todo
        match = string.format('+TYPE="Observation"&FOR="%s"', name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
        org_agenda_overriding_header = string.format("# Observations of %s's ", name),
      },
      {
        type = "tags",                                                   -- Type can be agenda | tags | tags_todo
        match = string.format('+TYPE="Follow-up"&FOR="%s"', name, name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
        org_agenda_overriding_header = string.format("# %s's Follow-ups", name),
      },
      {
        type = "tags",                                                  -- Type can be agenda | tags | tags_todo
        match = string.format('+TYPE="Self-assessment"&BY="%s"', name), --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
        org_agenda_overriding_header = string.format("# %s's Self-assessment", name),
      },
    },
  }
end


-- Setup Checklist for things ourside of this module
--
-- 1. setup treesitter with
-- ```
--     -- Setup treesitter in treesitter config (unfortunate coupling)
--     --require('nvim-treesitter.configs').setup({
--     --  highlight = {
--     --    enable = true,
--     --    additional_vim_regex_highlighting = { "org" },
--     --  },
--     --  ensure_installed = { "org" },
--     --})
-- ```
--
-- 2. setup nvim-cmp by adding orgmode to list of sources
--
-- ```
-- require'cmp'.setup({
--   sources = {
--     { name = 'orgmode' }
--   }
-- })
-- ```
--
-- 3. setup your neovim locale for date generation (global setting)
-- ```
-- vim.cmd('language en_US.utf8')
-- ```
--vim.fn.stdpath("data")

local data_dir = vim.fn.stdpath('data') .. "/orgmode"
local main_dir = vim.g.jonathans_special_files
local files_dir = {
  vim.g.jonathans_special_files .. "/tasks.org",
  vim.g.jonathans_special_files .. "/standup.org",
  vim.g.jonathans_special_files .. "/learn.org",
  vim.g.jonathans_special_files .. "/1on1-team-care/**/*.org",
  vim.fn.expand("~") .. "/devel/team-development/**/*.org"
}

local timestamp_format = "%<%Y-%m-%d %a %H:%M-%S%z>"

-- Utility
local open_in_buffer = function(path, config)
  local conf = config or {
    org_archive_location = '%s_archive',
    ui = {
      agenda = {
        custom_format = function(item)
          local prop = item:get_property('REF') or ''
          return string.format('%s [%s]', item.title, prop)
        end
      }
    },
    buf = vim.api.nvim_create_buf(true, false), --vim.api.nvim_get_current_buf(),
    enter = false,
    buffer_options = {
      -- 'filetype'	explicitly set by autocommands
      -- 'syntax'	explicitly set by autocommands
      -- 'bufhidden'	denote |special-buffers|
      -- 'buftype'	denote |special-buffers|
      -- 'readonly'	will be detected automatically
      -- 'modified'	will be detected automatically
    },
    open_win_config = config or {
      split = 'right',
      win = 0,
    }
  }
  -- vim.fn.bufadd(path)
  vim.api.nvim_buf_set_name(conf.buf, path)
  vim.fn.bufload(path)
  for opt, value in pairs(conf.buffer_options) do
    vim.api.nvim_set_option_value(value, opt, { buf = conf.buf })
  end
  vim.api.nvim_open_win(conf.buf, conf.enter, conf.open_win_config)
  vim.cmd("edit") -- no lua api for this yet. https://www.reddit.com/r/neovim/comments/zg52kl/recommended_neovim_apilua_way_to_load_an_exiting/
end

local after_export_hook = function(cxt)
  vim.notify(string.format("Copying path '%s' to the clipboard", vim.inspect(cxt.target_file)))
  require("osc52").copy(cxt.target_file)
end

return {
  'nvim-orgmode/orgmode',
  enabled = true,
  lazy = true,
  ft = { "org" },
  keys = {
    { '<leader>oa', function() require('orgmode').action('agenda.prompt') end,  desc = 'Open orgmode agenda' },
    { '<leader>oc', function() require('orgmode').action('capture.prompt') end, desc = 'Open orgmode capture' },
  },
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter', lazy = true },
  },
  ---@diagnostic disable-next-line: unused-local
  config = function(mod, opts)
    ---@class OrgConfigOpts
    local conf = {
      org_agenda_files = files_dir,
      org_default_notes_file = data_dir .. "/refile_default_captures.org",

      org_todo_keywords = {
        'TODO',
        'COMMITMENT(o)',
        'GOAL',
        'GAP',
        'INPROGRESS(i)',
        'FEEDBACK(f)',
        'BLOCKED(b)',
        'REVIEW(r)',
        '|',
        'DONE(d)', -- counterpart: todo
        -- 'COMMITMENT_FULFILLED(m)', -- counterpart: commitment
        -- 'GAP_CLOSED',              -- counterpart: gap
        -- 'ACHIEVED',                -- counterpart: goal
        'DELEGATED(l)',
        -- 'FEEDBACK_GIVEN(g)',       -- counterpart: feedback
        'CANCELED(c)'
      },

      org_todo_keyword_faces = {
        WAITING = ':foreground blue :weight bold',
        DELEGATED = ':background #FFFFFF :foreground:#000000 :slant italic :underline on',
        TODO = ':foreground red :slant italic :weight normal', -- overrides builtin color for `TODO` keyword
        NEXT = ':foreground red :slant italic :weight bold',
        COMMITMENT = ':foreground orange :slant italic :weight bold',
        GAP = ':foreground blue :background white :slant italic :weight bold',
        GAP_CLOSED = ':foreground green :slant italic :weight bold',
        COMMITMENT_FULFILLED = ':foreground green :slant italic :weight bold',
        INPROGRESS = ':foreground orange :weight bold',
        FEEDBACK = ':foreground gray :slant italic :weight normal', -- overrides builtin color for `TODO` keyword
        BLOCKED = ':background yellow :slant italic',
        REVIEW = ':foreground blue :slant italic :weight normal',   -- overrides builtin color for `TODO` keyword
        CANCELED = ':slant italic :weight normal',
        WONTDO = ':foreground gray :weight normal',

      },

      mappings = {
        disable_all = false,
        global = {
          -- Global mappings moved to lua/config/keymap/init.lua for lazy-loading
          org_agenda = false,
          org_capture = false,
        },
        org = {
          --org_toggle_checkbox = '<leader>x' -- replaced by custom function
        }
      },

      org_startup_folded = 'showeverything',
      org_startup_indented = false,
      org_blank_before_new_entry = { heading = true, plain_list_item = false },
      org_adapt_indentation = false,
      org_edit_src_content_indentation = 0,

      -- Agenda settings
      org_deadline_warning_days = 0,
      org_agenda_span = 'week',
      org_agenda_min_height = 50,
      org_agenda_start_on_weekday = 1, -- 1 is Monday
      org_agenda_skip_scheduled_if_done = false,
      org_agenda_skip_deadline_if_done = false,
      -- org_agenda_text_search_extra_files = {}
      org_agenda_custom_commands = {
        u = {
          name = 'Unscheduled Tasks',
          description = "Any unscheduled task",
          command = 'agenda',
          query = {
            todo_only = true,
            tags = { '-SCHEDULED', '-DEADLINE' },
          },
        },
        d = make_dashboard_for("Jonathan Komar")(),
        --f = make_feedback_overview(members),
        j = make_personal_development_view_for("Jonathan Komar"),
        z = make_personal_development_view_for("Jonas Erhart"),
        x = make_personal_development_view_for("Jan Berger"),
        y = make_personal_development_view_for("Matthaeus Huber"),
        n = make_personal_development_view_for("Nikolas Keuck"),
        i = make_personal_development_view_for("Matthieu Gusmini"),
        o = make_personal_development_view_for("Nico Riedmann"),
        g = (function()
          local portable = require('config.portable')
          local team_members_str = portable.safe_system("yaml-supplier --key team_members", "orgmode_yaml_supplier")
          local team_members = team_members_str ~= "" and vim.split(team_members_str, '\n') or {}
          return make_team_development_view_for(make_personal_development_view_for, team_members)
        end)(),
        s = {
          description = 'TODOs sorter',
          types = {
            {
              type = "tags_todo",
              match = "-SCHEDULED={.+}-DEADLINE={.+}",
              org_agenda_overriding_header = "# Unscheduled TODOs without a due date",
            },
            {
              type = "tags",
              match = 'TODO="DONE"',
              org_agenda_overriding_header = "# Completed TODOs",
            }
          },
        },
        -- c = {
        --   description = "Combined view", -- Description shown in the prompt for the shortcut
        --   types = {
        --     {
        --       type = "tags_todo",                       -- Type can be agenda | tags | tags_todo
        --       match = '+PRIORITY="A"',                  --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
        --       org_agenda_overriding_header = "High priority todos",
        --       org_agenda_todo_ignore_deadlines = "far", -- Ignore all deadlines that are too far in future (over org_deadline_warning_days). Possible values: all | near | far | past | future
        --     },
        --     {
        --       type = "agenda",
        --       org_agenda_overriding_header = "My daily agenda",
        --       org_agenda_span = "day" -- can be any value as org_agenda_span
        --     },
        --     {
        --       type = "tags",
        --       match = "WORK",                           --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
        --       org_agenda_overriding_header = "My work todos",
        --       org_agenda_todo_ignore_scheduled = "all", -- Ignore all headlines that are scheduled. Possible values: past | future | all
        --     },
        --     {
        --       type = "agenda",
        --       org_agenda_overriding_header = "Whole week overview",
        --       org_agenda_span = 'week',        -- 'week' is default, so it's not necessary here, just an example
        --       org_agenda_start_on_weekday = 1, -- Start on Monday
        --       org_agenda_remove_tags = true    -- Do not show tags only for this view
        --     },
        --   }
        -- },
      },

      -- Tags Settings
      --org_tags_column = "80", -- negative means flush right
      org_use_tag_inheritance = true,
      --org_tags_exclude_from_inheritance = {}

      org_custom_exports = {
        -- For quick checks to see how the Pandoc generates the AST for a given string,
        -- printf '*** DONE' | pandoc --from org -t native
        f = {
          label = 'Export to RTF format',
          action = function(exporter)
            local current_file = vim.api.nvim_buf_get_name(0)
            local target = vim.fn.fnamemodify(current_file, ':p:r') .. '.rtf'
            local command = { 'pandoc', current_file, '-o', target }
            local on_success = function(output)
              print('Success!')
              vim.api.nvim_echo({ { table.concat(output, '\n') } }, true, {})
            end
            local on_error = function(err)
              print('Error!')
              vim.api.nvim_echo({ { table.concat(err, '\n'), 'ErrorMsg' } }, true, {})
            end
            return exporter(command, target, on_success, on_error)
          end
        },
        w = {
          label = 'Export to Word format',
          action = function(exporter)
            local current_file = vim.api.nvim_buf_get_name(0)
            local target = vim.fn.fnamemodify(current_file, ':p:r') .. '.docx'
            local command = { 'pandoc', current_file, '-o', target }
            local on_success = function(output)
              vim.notify('Export Success!')
              vim.api.nvim_echo({ { table.concat(output, '\n') } }, true, {})
            end
            local on_error = function(err)
              vim.notify('Export Error!')
              vim.api.nvim_echo({ { table.concat(err, '\n'), 'ErrorMsg' } }, true, {})
            end
            return exporter(command, target, on_success, on_error)
          end
        },
        g = {
          label = "Export to Markdown format (applying custom filters)",
          action = function(exporter)
            local cxt = {}
            cxt.current_file = vim.api.nvim_buf_get_name(0)
            cxt.target_file = vim.fn.fnamemodify(cxt.current_file, ':p:r') .. '.slack.md'
            local command = { 'pandoc', '--lua-filter', vim.fn.expand('~') ..
            '/.local/share/pandoc/orgmode-task-to-markdown-checkbox-filter.lua', cxt.current_file, '-o', cxt.target_file }
            vim.notify("Executing: " .. table.concat(command, ' '))
            local on_success = function(output)
              vim.notify('Export Success!')
              after_export_hook(cxt)
              vim.api.nvim_echo({ { table.concat(output, '\n') } }, true, {})
            end
            local on_error = function(err)
              vim.notify('Export Error!')
              vim.api.nvim_echo({ { table.concat(err, '\n'), 'ErrorMsg' } }, true, {})
            end
            return exporter(command, cxt.target_file, on_success, on_error)
          end
        },
        s = {
          label = 'Export to Slack Markdown format',
          action = function(exporter)
            local cxt = {}
            cxt.current_file = vim.api.nvim_buf_get_name(0)
            cxt.target_file = vim.fn.fnamemodify(cxt.current_file, ':p:r') .. '.slack.md'
            local command = { 'pandoc', '--lua-filter', vim.fn.expand('~') ..
            '/.local/share/pandoc/orgmode-task-to-icon-filter.lua', '-t', vim.fn.expand('~') ..
            '/.local/share/pandoc/slack.lua', cxt.current_file, '-o',
              cxt.target_file }

            vim.notify("Executing: " .. table.concat(command, ' '))
            local on_success = function(output)
              vim.notify('Export Success!')
              after_export_hook(cxt)
              open_in_buffer(cxt.target_file, nil)
              vim.api.nvim_echo({ { table.concat(output, '\n') } }, true, {})
            end
            local on_error = function(err)
              vim.notify('Export Error!')
              vim.api.nvim_echo({ { table.concat(err, '\n'), 'ErrorMsg' } }, true, {})
            end
            return exporter(command, target, on_success, on_error)
          end
        },
        x = {
          label = 'Produce PDF with xelatex',
          action = function(exporter)
            local current_file = vim.api.nvim_buf_get_name(0)
            local target = vim.fn.fnamemodify(current_file, ':p:r') .. '.pdf'
            local command = { 'pandoc', current_file, '-o', target, '--pdf-engine=xelatex', '-M',
              'documentclass=komar', '--template=' .. vim.fn.stdpath("config") .. "/lua/plugins/orgmode/latex.template" }
            local on_success = function(output)
              vim.notify('Export Success! ' .. table.concat(output, ' '))
              vim.api.nvim_echo({ { table.concat(output, '\n') } }, true, {})
            end
            local on_error = function(err)
              vim.notify('Export Error! ' .. table.concat(err, ' '))
              vim.api.nvim_echo({ { table.concat(err, '\n'), 'ErrorMsg' } }, true, {})
            end
            return exporter(command, target, on_success, on_error)
          end

        },
        --c = {
        --  label = 'Produce Confluence Markdown',
        --  action = function(exporter)
        --    local current_file = vim.api.nvim_buf_get_name(0)
        --    local target = vim.fn.fnamemodify(current_file, ':p:r') .. '.confluence.wiki'
        --    local command = { 'pandoc', current_file, '-o', target, '--write', 'jira' }
        --    local on_success = function(output)
        --      vim.notify('Export Success! ' .. table.concat(output, ' '))
        --      vim.api.nvim_echo({ { table.concat(output, '\n') } }, true, {})
        --    end
        --    local on_error = function(err)
        --      vim.notify('Export Error! ' .. table.concat(err, ' '))
        --      vim.api.nvim_echo({ { table.concat(err, '\n'), 'ErrorMsg' } }, true, {})
        --    end
        --    return exporter(command, target, on_success, on_error)
        --  end
        --},
        h = {
          label = 'Produce HTML',
          action = function(exporter)
            local current_file = vim.api.nvim_buf_get_name(0)
            local target = vim.fn.fnamemodify(current_file, ':p:r') .. '.html'
            local template_path = vim.fn.stdpath('config') .. "/lua/plugins/orgmode/easy_template.html.template"
            local css_path = vim.fn.stdpath('config') .. "/lua/plugins/orgmode/elegant_boostrap.css"
            local command = { 'pandoc', current_file, '-o', target, '--write', 'html', '--template=' .. template_path,
              '--toc', '--standalone', '--embed-resources', '--css=' .. css_path }
            local on_success = function(output)
              vim.notify('Export Success! ' .. table.concat(output, ' '))
              vim.api.nvim_echo({ { table.concat(output, '\n') } }, true, {})
            end
            local on_error = function(err)
              vim.notify('Export Error! ' .. table.concat(err, ' '))
              vim.api.nvim_echo({ { table.concat(err, '\n'), 'ErrorMsg' } }, true, {})
            end
            return exporter(command, target, on_success, on_error)
          end
        }
      },

      org_capture_templates = { -- https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md#org_capture_templates
        -- key here represents keystroke in capture menu
        t = {
          description = 'Task',
          template = "",
          --           string.format([[
          -- * TODO [#C] %%?
          --   DEADLINE: %%t
          --   :PROPERTIES:
          --   :OPENED: [%s]
          --   :END:
          --           ]], timestamp_format),
          target = main_dir .. "/tasks.org"
        },
        --         r = {
        --           description = "Review",
        --           template = string.format([[
        -- * TODO [#C] %%?
        --   DEADLINE: %%t
        --   :PROPERTIES:
        --   :OPENED: [%s]
        --   :END:
        --           ]], timestamp_format),
        --           target = main_dir .. "/reviews.org",
        --         },
        --         s = {
        --           description = "Self-study / Learning",
        --           template = string.format([[
        -- * TODO [#C] %%?
        --   DEADLINE: %%t
        --   :PROPERTIES:
        --   :OPENED: [%s]
        --   :END:
        --           ]], timestamp_format),
        --           target = main_dir .. "/learn.org"
        --         },
        --         f = {
        --           description = "Feedback",
        --           template = string.format(
        --             [[
        -- * FEEDBACK [#C] Feedback: %%? :unrefined:feedback:
        --   :PROPERTIES:
        --   :OPENED: [%s]
        --   :END:
        --             ]],
        --             timestamp_format),
        --           target = main_dir .. "/feedback.org"
        --         }
      }
    }
    -- Setup orgmode
    require('orgmode').setup(conf)

    --------------------------------------------------------------------------------
    --                             Archival Functions                             --
    --------------------------------------------------------------------------------
    -- Function to archive DONE TODOs older than a specified duration (in months)
    local Path = require('plenary.path')
    local orgmode = require "orgmode"

    local archive_old_done_todos = function(months)
      return function(months)
        local agenda_files = orgmode.api.get_agenda_files()
        local current_date = os.date('*t')
        current_date.month = current_date.month - months
        if current_date.month <= 0 then
          current_date.year = current_date.year + math.floor((current_date.month - 1) / 12)
          current_date.month = current_date.month % 12 + 12
        end
        local target_date = os.time(current_date)

        for _, file in ipairs(agenda_files) do
          local items = orgmode.api.parse_file(file)
          local basename = Path:new(file):make_relative():match("([^/]+)%.org$")
          local archive_file = string.format('~/org/%s_archive.org', basename)

          for _, item in ipairs(items) do
            if item.todo_keyword == 'DONE' and item.timestamp then
              local item_time = os.time(item.timestamp)
              if item_time < target_date then
                orgmode.api.archive_subtree(item, archive_file)
              end
            end
          end
        end
      end
    end
    -- notifications = {
    --   reminder_time = { 0, 1, 5, 10 },
    --   repeater_reminder_time = { 0, 1, 5, 10 },
    --   deadline_warning_reminder_time = { 0 },
    --   cron_notifier = function(tasks)
    --     for _, task in ipairs(tasks) do
    --       local title = string.format('%s (%s)', task.category, task.humanized_duration)
    --       local subtitle = string.format('%s %s %s', string.rep('*', task.level), task.todo, task.title)
    --       local date = string.format('%s: %s', task.type, task.time:to_string())
    --
    --       if vim.fn.executable('notify-send') then
    --         vim.loop.spawn('notify-send', {
    --           args = {
    --             '--icon=/home/kristijan/github/orgmode/assets/nvim-orgmode-small.png',
    --             '--app-name=orgmode',
    --             '--urgency=critical',
    --             string.format('%s\n%s\n%s', title, subtitle, date),
    --           },
    --         })
    --       end
    --     end
    --   end
    -- }



    --------------------------------------------------------------------------------
    --                              String Functions                              --
    --------------------------------------------------------------------------------
    -- Function to convert visual-line selection to Org-mode checklist
    function ConvertToChecklist()
      -- Get the start and end positions of the visual selection
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")

      -- Iterate over each line in the selection
      for line_num = start_pos[2], end_pos[2] do
        -- Get the current line content
        local line = vim.fn.getline(line_num)
        -- Prepend '- [ ] ' to the line
        vim.fn.setline(line_num, '  - [ ] ' .. line)
      end
    end

    -- Function to fold all tasks except the current one in Org-mode
    function FoldOtherTasks()
      -- Get the current line number
      local current_line = vim.fn.line('.')

      -- Fold all lines
      vim.cmd('normal! zM')

      -- Unfold the current task
      vim.cmd('normal! zR')
      vim.cmd('normal! ' .. current_line .. 'G')
      vim.cmd('normal! zA')
    end

    -- Function to unfold the current task and all its subtasks in Org-mode
    function UnfoldCurrentTaskAndSubtasks()
      -- Get the current line number
      local current_line = vim.fn.line('.')

      -- Fold all lines
      vim.cmd('normal! zM')

      -- Unfold the current task and its subtasks
      vim.cmd('normal! ' .. current_line .. 'G')
      vim.cmd('normal! zR')
      vim.cmd('normal! zA')
    end

    function FoldOtherTasksExceptCurrentAndSubtasks()
      -- Get the current line number
      local current_line = vim.fn.line('.')

      -- Fold all lines
      vim.cmd('normal! zM')

      -- Unfold the current task and its subtasks
      vim.cmd('normal! ' .. current_line .. 'G')
      vim.cmd('normal! zR')
      vim.cmd('normal! zA')

      -- Fold all tasks above the current one
      for i = current_line - 1, 1, -1 do
        vim.cmd(i .. 'G')
        vim.cmd('normal! zc')
      end

      -- Move back to the original line
      vim.cmd('normal! ' .. current_line .. 'G')
    end

    function toggle_checkbox()
      local mode = vim.fn.mode()
      local start_line, end_line

      if mode == 'v' or mode == 'V' then
        start_line = vim.fn.line("'<")
        end_line = vim.fn.line("'>")
      else
        start_line = vim.fn.line('.')
        end_line = start_line
      end

      local lines = vim.fn.getline(start_line, end_line)
      local checkbox_pattern = "%[.%]"
      local checked_pattern = "%[X%]"
      local unchecked_pattern = "%[ %]"

      for i, line in ipairs(lines) do
        if line:match(checkbox_pattern) then
          if line:match(checked_pattern) then
            lines[i] = line:gsub(checked_pattern, "[ ]")
          else
            lines[i] = line:gsub(unchecked_pattern, "[X]")
          end
        end
      end

      vim.fn.setline(start_line, lines)
    end

    --------------------------------------------------------------------------------
    --                               Global Keymap                                --
    --------------------------------------------------------------------------------

    vim.keymap.set('v', '<leader>l', ':lua ConvertToChecklist()<CR>',
      { noremap = true, silent = true, desc = "Convert selection to checklist in orgmode" })
    -- vim.api.nvim_set_keymap('n', '<leader>l', ':lua FoldOtherTasksExceptCurrentAndSubtasks()<CR>',
    --   { noremap = true, silent = true, desc = "Fold other tasks in orgmode." })

    -- Map the function to a keybinding, for example <leader>c
    vim.keymap.set('n', '<leader>x', function() toggle_checkbox() end, { noremap = true, silent = true })
    vim.keymap.set('v', '<leader>x', function() toggle_checkbox() end, { noremap = true, silent = true })


    vim.keymap.set('n', '<leader><leader>od', function() archive_done_items() end, { noremap = true, silent = true })
    --------------------------------------------------------------------------------
    --                               User Commands                                --
    --------------------------------------------------------------------------------
    -- The filter syntax assumes that there is no overlap between categories and tags. Otherwise, tags take priority.
    -- https://orgmode.org/manual/Filtering_002flimiting-agenda-items.html#index-org_002dagenda_002dfilter
    -- if you call the command with a double prefix argument, or if you add an
    -- additional ‘+’ (e.g., ‘++work’) to the front of the string, the new
    -- filter elements are added to the active ones.
    -- See each task as an entry that is parsed as an Outline node, which is a "data container"
    --
    --vim.api.nvim_replace_termcodes('<CR>', true, true, true),
    --vim.api.nvim_feedkeys("CLOSED: " .. yesterday .. "\\|CLOSED: " .. now
    -- CLOSED>"[2024-11-01 Sun 09:00]"+CLOSED<"[2024-11-10 Sun 11:25]"
    -- from https://orgmode.org/worg/org-tutorials/advanced-searching.html
    -- see Special Properties which includes CLOSED and SCHEDULED
    -- see Querying timestamps
    -- org-entry-properties
    -- + means "include matches" i.e. a logical AND concatenator operator for matches whereas
    -- + also prefixes all properties, but it is implied in first element if first element is not found as a file name. I prefer to use it to be explicit.
    -- - is the exlusion operator
    -- Example
    -- vim.api.nvim_feedkeys("+CLOSED>=\"<-1d>\"+CLOSED<=\"<today>\"" ..
    --
    --

    -- @param name - name of the command; must conform to vim user command naming conventions
    -- @param filter - An orgmode filter. https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md#org_agenda_filter
    local create_agenda_command = function(name, filter)
      vim.api.nvim_create_user_command(name, function()
        local agendaapi = require("orgmode.api.agenda")
        vim.defer_fn(function()
          vim.api.nvim_feedkeys(filter ..
            vim.api.nvim_replace_termcodes('<CR>', true, true, true),
            'n', false)
        end, 10)
        agendaapi.tags()
      end, {})
    end
    local create_agenda_command_in_lua = function(name, filter)
      vim.api.nvim_create_user_command(name, function()
        local open_custom_agenda = function()
          require("orgmode.api.agenda").tags({
            query = filter,
            todo_only = false,
          })
        end
        local open_custom_agenda_2 = function()
          require('orgmode.api.agenda').agenda({
            span = 3,
            filters = '+COMMITMENT'
          })
        end
        open_custom_agenda_2()
      end, {})
    end

    vim.api.nvim_create_user_command("OrgArchiveOlderThanOneMonth", archive_old_done_todos(1), {})


    create_agenda_command('AgendaClosedOver14DaysAgo', [[+CLOSED<="<-14d>"]])
    create_agenda_command('AgendaStandup', [[+CLOSED>="<-1d>"+CLOSED<="<today>"]])
    create_agenda_command('AgendaFeedback', [[+feedback]])
    create_agenda_command('AgendaCommitments', [[+TYPE="COMMITMENT"]])
    create_agenda_command('AgendaAnnouncments', [[+TYPE="Announcement"]])
    create_agenda_command('AgendaCommitmentsForJan', [[+TYPE="COMMITMENT"&+BY="Jan Berger"]])
    create_agenda_command('AgendaSprint', [[+TYPE="Sprint"]])

    create_agenda_command('AgendaDaily',
      string.format('+TYPE="Daily"&BY="%s"&DEADLINE>="%s"+DEADLINE<="%s"', "Jonathan Komar", current_week_monday(),
        os.date("%Y-%m-%d", os.time() + (5 * 24 * 60 * 60))))
    --DEADLINE: <2024-11-06 Wed> CLOSED: [2024-11-07 Thu 09:32] OPENED: [2024-11-05 Tue 13:38-09+0100]
    --
    vim.api.nvim_create_user_command('AgendaYesterdayFromJonas', function()
      local agendaapi = require("orgmode.api.agenda")
      local yesterday = os.date("[%Y-%m-%d %a %H:%M]", os.time() - 24 * 60 * 60)
      local now = os.date("[%Y-%m-%d %a %H:%M]", os.time())
      vim.defer_fn(function()
        -- CLOSED"
        vim.api.nvim_feedkeys("CLOSED>\"" .. yesterday .. "\"+CLOSED<\"" .. now .. "\"" ..
          vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'n', false)
      end, 10)
      --DEADLINE: <2024-11-04 Mon> CLOSED: [2024-11-05 Thu 09:33] OPENED: [2024-11-04 Mon 16:28-33+0100]

      agendaapi.tags()
    end, {})

    --------------------------------------------------------------------------------
    --                          Browser Preview Function                          --
    --------------------------------------------------------------------------------
    -- USAGE:
    --   One-time preview: :OrgPreview or <leader>mp (in org/markdown files)
    --   Live preview:     :OrgPreviewLive or <leader>mP (auto-refresh on save)
    --   Stop live:        :OrgPreviewStop or <leader>ms
    --
    -- Supports both .org and .md files. Uses pandoc to convert to HTML.
    -- One-time preview: Opens once in browser
    -- Live preview: Auto-refreshes browser every 2 seconds (regenerates on save)
    --------------------------------------------------------------------------------

    -- Function to preview current file in browser (supports org and markdown)
    local preview_in_browser = function()
      local current_file = vim.api.nvim_buf_get_name(0)
      local filetype = vim.bo.filetype

      -- Determine if we're dealing with org or markdown
      local is_org = filetype == 'org' or current_file:match('%.org$')
      local is_markdown = filetype == 'markdown' or current_file:match('%.md$')

      if not (is_org or is_markdown) then
        vim.notify('Preview only supports org and markdown files', vim.log.levels.WARN)
        return
      end

      -- Generate temporary HTML file
      local temp_html = vim.fn.tempname() .. '.html'
      local template_path = vim.fn.stdpath('config') .. "/lua/plugins/orgmode/easy_template.html.template"
      local css_path = vim.fn.stdpath('config') .. "/lua/plugins/orgmode/elegant_boostrap.css"

      -- Build pandoc command
      local from_format = is_org and 'org' or 'markdown'
      local command = {
        'pandoc',
        current_file,
        '-f', from_format,
        '-t', 'html',
        '-o', temp_html,
        '--standalone',
        '--embed-resources',
        '--template=' .. template_path,
        '--css=' .. css_path,
        '--toc',
        '--metadata', 'title=' .. vim.fn.fnamemodify(current_file, ':t:r')
      }

      -- Execute pandoc
      local result = vim.fn.system(command)
      local exit_code = vim.v.shell_error

      if exit_code ~= 0 then
        vim.notify('Pandoc failed: ' .. result, vim.log.levels.ERROR)
        return
      end

      -- Open in browser (cross-platform approach)
      local open_cmd
      if vim.fn.has('mac') == 1 then
        open_cmd = 'open'
      elseif vim.fn.has('unix') == 1 then
        open_cmd = 'xdg-open'
      elseif vim.fn.has('win32') == 1 then
        open_cmd = 'start'
      else
        vim.notify('Unsupported platform for browser preview', vim.log.levels.ERROR)
        return
      end

      vim.fn.jobstart({ open_cmd, temp_html }, {
        detach = true,
        on_exit = function()
          vim.notify('Preview opened in browser: ' .. temp_html, vim.log.levels.INFO)
        end
      })
    end

    -- Create user command and keymap for preview
    vim.api.nvim_create_user_command('OrgPreview', preview_in_browser, {
      desc = 'Preview current org/markdown file in browser'
    })

    -- Live preview with auto-reload on save
    local live_preview_jobs = {}

    local preview_in_browser_live = function()
      local current_file = vim.api.nvim_buf_get_name(0)
      local bufnr = vim.api.nvim_get_current_buf()
      local filetype = vim.bo.filetype

      local is_org = filetype == 'org' or current_file:match('%.org$')
      local is_markdown = filetype == 'markdown' or current_file:match('%.md$')

      if not (is_org or is_markdown) then
        vim.notify('Preview only supports org and markdown files', vim.log.levels.WARN)
        return
      end

      -- Generate persistent HTML file in temp directory
      local temp_html = vim.fn.tempname() .. '.html'

      -- Function to regenerate HTML
      local regenerate_html = function()
        local template_path = vim.fn.stdpath('config') .. "/lua/plugins/orgmode/easy_template.html.template"
        local css_path = vim.fn.stdpath('config') .. "/lua/plugins/orgmode/elegant_boostrap.css"
        local from_format = is_org and 'org' or 'markdown'

        -- Add auto-reload script to HTML
        local command = {
          'pandoc',
          current_file,
          '-f', from_format,
          '-t', 'html',
          '-o', temp_html,
          '--standalone',
          '--embed-resources',
          '--template=' .. template_path,
          '--css=' .. css_path,
          '--toc',
          '--metadata', 'title=' .. vim.fn.fnamemodify(current_file, ':t:r'),
          '--metadata', 'header-includes=<meta http-equiv="refresh" content="2">'
        }

        vim.fn.system(command)
        if vim.v.shell_error == 0 then
          vim.notify('Preview updated', vim.log.levels.INFO)
        end
      end

      -- Initial generation
      regenerate_html()

      -- Open in browser
      local open_cmd = vim.fn.has('mac') == 1 and 'open' or
          vim.fn.has('unix') == 1 and 'xdg-open' or
          vim.fn.has('win32') == 1 and 'start' or nil

      if open_cmd then
        vim.fn.jobstart({ open_cmd, temp_html }, { detach = true })
      end

      -- Set up auto-regeneration on save
      if live_preview_jobs[bufnr] then
        vim.api.nvim_del_autocmd(live_preview_jobs[bufnr])
      end

      live_preview_jobs[bufnr] = vim.api.nvim_create_autocmd('BufWritePost', {
        buffer = bufnr,
        callback = regenerate_html,
        desc = 'Auto-regenerate preview on save'
      })

      vim.notify('Live preview started. File will refresh every 2 seconds in browser.', vim.log.levels.INFO)
    end

    -- Stop live preview
    local stop_live_preview = function()
      local bufnr = vim.api.nvim_get_current_buf()
      if live_preview_jobs[bufnr] then
        vim.api.nvim_del_autocmd(live_preview_jobs[bufnr])
        live_preview_jobs[bufnr] = nil
        vim.notify('Live preview stopped', vim.log.levels.INFO)
      else
        vim.notify('No active live preview for this buffer', vim.log.levels.WARN)
      end
    end

    -- Create user commands
    vim.api.nvim_create_user_command('OrgPreviewLive', preview_in_browser_live, {
      desc = 'Live preview current org/markdown file in browser (auto-refresh)'
    })

    vim.api.nvim_create_user_command('OrgPreviewStop', stop_live_preview, {
      desc = 'Stop live preview for current buffer'
    })

    -- Add keymaps for org and markdown files
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'org', 'markdown' },
      callback = function()
        vim.keymap.set('n', '<leader>mp', preview_in_browser, {
          buffer = true,
          desc = 'Preview in browser (one-time)'
        })
        vim.keymap.set('n', '<leader>mP', preview_in_browser_live, {
          buffer = true,
          desc = 'Live preview in browser (auto-refresh)'
        })
        vim.keymap.set('n', '<leader>ms', stop_live_preview, {
          buffer = true,
          desc = 'Stop live preview'
        })
      end
    })
  end,
}

-- todos filter only is a string to search for '/[^/]*/?'
--
--agendaapi.todos({filters=})
--agendaapi.tags({ filters = "CLOSED>\"" .. yesterday .. "\"+CLOSED<\"" .. now .. "\"" })
