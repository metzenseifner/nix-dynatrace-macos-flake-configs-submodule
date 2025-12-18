local M = {}

--------------------------------------------------------------------------------
--                           Example Configuration                            --
--------------------------------------------------------------------------------
-- local lazy_config = {
--   ["/path/to/directory1"] = {
--     keymap = {
--       mode = "n",
--       lhs = "<leader>fb",
--       desc = "Open file browser",
--     },
--     extension = {
--       name = "file_browser",
--       func = "file_browser",
--       opts = {},
--     },
--   },
--   ["/path/to/directory2"] = {
--     keymap = {
--       mode = "n",
--       lhs = "<leader>ff",
--       desc = "Find files",
--     },
--     extension = {
--       name = "find_files",
--       func = "find_files",
--       opts = {},
--     },
--   },
-- }
-- require('your_package_name').setup(lazy_config)

M.setup = function(config)
  for dir, settings in pairs(config) do
    -- Set keymap
    vim.keymap.set(settings.keymap.mode, settings.keymap.lhs, function()
      require('telescope').extensions[settings.extension.name]settings.extension.func
    end, { noremap = true, silent = true, desc = settings.keymap.desc })

    -- Create an autocommand to change directory
    -- vim.api.nvim_create_autocmd("BufEnter", {
    --   pattern = dir .. "/*",
    --   callback = function()
    --     vim.cmd("cd " .. dir)
    --   end,
    -- })
  end
end

return M
