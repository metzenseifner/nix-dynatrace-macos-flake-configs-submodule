return {
  s("telescope-picker", fmt([[
    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values

    local finder = finders:new{
      entry_maker     = function(line) end,
      fn_command      = function() { command = "", args  = { "ls-files" } } end,
      static          = false,
      maximum_results = false
    }

    local sorter = function() end
    local previewer = function() end

    -- lua/telescope/pickers.lua
    pickers:new {
      prompt_title            = "",
      finder                  = FUNCTION, -- see lua/telescope/finders.lua
      sorter                  = FUNCTION, -- see lua/telescope/sorters.lua
      previewer               = FUNCTION, -- see lua/telescope/previewers/previewer.lua
      selection_strategy      = "reset",  -- follow, reset, row
      border                  = {},
      borderchars             = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      default_selection_index = 1, -- Change the index of the initial selection row
    }
  ]], {}, { delimiters = "<>" })),
}
