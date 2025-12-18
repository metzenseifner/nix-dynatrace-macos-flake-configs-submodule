return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/help_keymap.nvim",
  lazy = true,
  ft = "help",
  keys = {
    {
      "gd",
      "<C-]>",
      mode = { "n" },
      desc = "Go to definition / Jump to link"
    }
  }
}
