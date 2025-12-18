return {
  event = "InsertEnter",
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/dynatrace_snippets.nvim",
  dependencies = {
    "L3MON4D3/LuaSnip",
  },
  lazy = true,
  disable = true,
  config = function()
    require'dynatrace_snippets'.setup()
  end
}
