local themes = require("telescope.themes")

-- See Dev Docs for Telescope Extensions
-- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md
local module = {}
module.extension_name = "Telescope special_files"
_special_files_config = {} -- TODO replace special_files with extension_name

--[[
    Set of sources
 pecial_files/

  sources = {
    -- ~/.local/share/nvim
    {dir = vim.fn.stdpath('data') .. '/special_files'},
    {dir = vim.fn.expand("$HOME/other_special_files", depth = 2}
  },
  mappings = {
    open_in_browser = "<C-o>",
    open_in_file_browser = "<M-b>",
    open_in_find_files = "<C-f>",
    open_in_live_grep = "<C-g>",
    open_in_terminal = "<C-t>",
    open_plugins_picker = "<C-b>",
    open_lazy_root_find_files = "<C-r>f",
    open_lazy_root_live_grep = "<C-r>g",
    change_cwd_to_plugin = "<C-c>d",
  },
--]]
module.default_config = {
  sources = {
    { dir = vim.fn.stdpath('data') .. '/special_files' },
  },
}


module.configSupplier = function()
  return _special_files_config
end

module.apply_theme = function(user_opts)
  if user_opts.theme and string.len(user_opts.theme) > 0 then
    if not themes["get_" .. user_opts.theme] then
      vim.notify(
        string.format("Could not apply provided telescope theme: '%s'", user_opts.theme),
        vim.log.levels.WARN,
        { title = M.extension_name }
      )
    else
      user_opts = themes["get_" .. user_opts.theme](user_opts)
    end
  end
end

module.setup = function(user_opts)
  user_opts = user_opts or {}
  -- force means right takes precedence (right overrides left)
  _config = vim.tbl_deep_extend("force", {}, module.default_config, user_opts)
  M.apply_theme(user_opts)
end
