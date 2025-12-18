return {
  event = "InsertEnter", -- VeryLazy
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/jonathan_komar_snippets.nvim",
  dependencies = {
    "L3MON4D3/LuaSnip"
  },
  lazy = true,
  config = function()
    require'jonathan_komar_snippets'.setup()
  end
}
