return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/colorscheme_select.nvim",
  event = "UIEnter",
  dependencies = {
    "lunarvim/darkplus.nvim",
    "daschw/leaf.nvim"
  },
  config = function(modname, opts)
    -- Dotted path deliberately, to share one package.loaded entry with
    -- config.options, which reads the same detection.
    local appearance = require 'config.terminal_appearance'

    local conf = {
      -- Follow the terminal instead of a hard-coded choice. "light" | "dark"
      -- still work if you want to pin it.
      startup_mode = appearance.detect(),
      dark_schemes = {
        "wind",
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
    -- Recorded before the colorscheme writes 'background' itself, so the
    -- detector does not mistake our own write for the terminal's.
    appearance.last_applied = conf.startup_mode

    local cs = require 'colorscheme_select'
    cs.setup(conf)

    -- Composition point: the detector knows nothing about colorschemes, and
    -- the plugin knows nothing about terminals. This is the only place the two
    -- domains meet.
    appearance.on_change(function(mode)
      cs.set_mode(mode, cs.runtime_state)
    end)

    vim.api.nvim_create_user_command("Colorschemeselectauto", function(cmd_opts)
      appearance.sync()
      print(appearance.describe())
    end, {
      desc = "Re-detect the terminal's light/dark appearance and follow it.",
      nargs = "*",
    })
  end
}
