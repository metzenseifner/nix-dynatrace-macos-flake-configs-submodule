return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/testrunner.nvim",
  config = function(modname, opts)
    require 'testrunner'.setup()
  end
}
