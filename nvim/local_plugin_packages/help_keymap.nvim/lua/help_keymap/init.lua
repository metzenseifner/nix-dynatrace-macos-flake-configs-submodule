local M = {}


M.setup = function(plugin, user_opts)
  vim.notifiy(
    string.format(
      "%s plugin does nothing but serve as placeholder for lazy.nvim so that we can utilize the 'keys =' based on filetype feature",
      plugin.name))
end


return M
