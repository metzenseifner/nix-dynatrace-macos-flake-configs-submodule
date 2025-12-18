local config = require("telescope.config").values -- access values table for user's config
local entry_display = require("telescope.pickers.entry_display")
local pickers = require("telescope.pickers")      --main module for new pickers
--local previewers = require("telescope.previewers") --optional

local special_files_actions = require("telescope._extensions.special_files.actions")
local special_files_setup = require("telescope._extensions.special_files.setup")
local special_files_plugins = require("telescope._extensions.special_files.plugins").plugins()

local finder_supplier = require("telescope._extensions.special_files.finder")


local M = {}

M.special_files_picker = function()
  local conf = special_files_setup.configSupplier()



  pickers
      .new(conf, {
        prompt_title = "Search Special Files",
        results_title = "Special Files",
        finder = finder_supplier(conf),
        sorter = config.file_sorter(conf),
        --previewer = previewers.display_content.new(opts),
        --attach_mappings = attach_mappings,
      })
      :find()
end

return M
