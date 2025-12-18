-- pickers: main module which is used to create a new picker.
-- finders: provides interfaces to fill the picker with items.
-- config: values table which holds the user's configuration. So to make it easier we access this table directly in conf.
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"            -- OPTIONAL
local action_state = require "telescope.actions.state" -- OPTIONAL

-- local example_finder = finders.new_table {
--   results = { "red", "green", "blue" }
-- }

-- local finder = finders:new{
--   entry_maker     = function(line) end, -- Entry maker is a function used to transform an item from the finder to an internal entry table
--   fn_command      = function() { command = "", args  = { "ls-files" } } end,
--   static          = false,
--   maximum_results = false
-- }

-- local sorter = function() end
-- local previewer = function() end

-- lua/telescope/pickers.lua
-- pickers:new {
--   prompt_title            = "",
--   finder                  = FUNCTION, -- see lua/telescope/finders.lua
--   sorter                  = FUNCTION, -- see lua/telescope/sorters.lua
--   previewer               = FUNCTION, -- see lua/telescope/previewers/previewer.lua
--   attach_mappings         = FUNCTION, -- OPTIONAL
--   selection_strategy      = "reset",  -- follow, reset, row
--   border                  = {},
--   borderchars             = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
--   default_selection_index = 1, -- Change the index of the initial selection row
--
-- }

-- local actions_override = function(prompt_bufnr, map) -- OPTIONAL If it returns false it means that only the actions defined in the function should be attached.
--   actions.select_default:replace(function()          -- select_default is the default function we are replacing here, trigger mapped to <CR> by default
--     actions.close(prompt_bufnr)
--     local selection = action_state.get_selected_entry()
--     -- print(vim.inspect(selection))
--     vim.api.nvim_put({ selection[1] }, "", false, true)
--   end)
--   return true
-- end

-- start with a picker function:
local f = function(telescope_opts)
  local f_finder = finders:new{
    entry_maker     = function(line) end,
    fn_command      = function() { command = "", args  = { "ls-files" } } end,
    static          = false,
    maximum_results = false
  }

  local f_sorter = function() end
  local f_previewer = function() end

  telescope_opts = telescope_opts or {}

  local picker = pickers:new {
    prompt_title            = "",
    finder                  = f_finder, -- see lua/telescope/finders.lua
    sorter                  = f_sorter, -- see lua/telescope/sorters.lua
    previewer               = f_previewer, -- see lua/telescope/previewers/previewer.lua
    selection_strategy      = "reset",  -- follow, reset, row
    border                  = {},
    borderchars             = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    default_selection_index = 1, -- Change the index of the initial selection row
  }
  local start_picker = picker.find
  start_picker()
end
