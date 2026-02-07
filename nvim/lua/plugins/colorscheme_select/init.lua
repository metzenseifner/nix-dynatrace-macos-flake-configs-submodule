return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/colorscheme_select.nvim",
  event = "UIEnter",
  dependencies = {
    "lunarvim/darkplus.nvim",
    "daschw/leaf.nvim"
  },
  config = function(modname, opts)
    local conf = {
      startup_mode = "dark", -- "light" | "dark"
      dark_schemes = {
        "ayu-mirage",
        "grail",
        "nightfox",
        "slate",
        "duskfox",
        "melange", -- has issue with light green visibility
        "ayu-dark",
        "darkplus",
      },
      light_schemes = {
        "lunaperche",
        "dayfox",
        "dawnfox",
        "leaf",
        "shine",
        "dawnfox",
        "ayu-light",
        "PaperColor",
      }
    }
    require 'colorscheme_select'.setup(conf)
  end
}
