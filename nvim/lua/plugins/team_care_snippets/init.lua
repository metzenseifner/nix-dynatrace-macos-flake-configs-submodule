return {
  event = "InsertEnter",
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/team_care_snippets.nvim",
  dependencies = {
    "L3MON4D3/LuaSnip",
  },
  lazy = true,
  config = function()
    require'team_care_snippets'.setup()
  end
}
