local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This extension requires 'telescope.nvim'. (https://github.com/nvim-telescope/telescope.nvim)")
end

return require("telescope").register_extension {
  setup = function(extension_config, user_config)
    --module(setup(config))
    -- access extension config and user config
  end,
  exports = {
    special_files_picker = require("telescope._extensions.special_files.picker")
  },
}
