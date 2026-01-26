return {
  "rcarriga/nvim-notify",
  lazy = false,
  priority = 1000, -- Load before fidget
  config = function(_, _)
    local notify = require("notify")
    ---
    ---@type notify.Config
    local conf = {
      merge_duplicates = false,
      background_colour = "NotifyBackground",
      fps = 30,
      icons = {
        DEBUG = "",
        ERROR = "",
        INFO = "",
        TRACE = "✎",
        WARN = ""
      },
      level = 1,
      minimum_width = 50,
      render = "compact",
      stages = "fade_in_slide_out",
      time_formats = {
        notification = "%T",
        notification_history = "%FT%T"
      },
      timeout = 3000,
      top_down = false, -- false: bottom-up rendering, true: top-down with relation to horizontal window boundaries
    }

    -- Configure nvim-notify to NOT display (stages = "static" makes it invisible)
    conf.stages = "static"
    conf.timeout = 1 -- Immediately dismiss from view
    conf.on_open = function(win)
      -- Make the window completely invisible
      vim.api.nvim_win_set_config(win, { focusable = false, width = 1, height = 1 })
      vim.api.nvim_win_set_option(win, "winblend", 100)
    end
    
    notify.setup(conf)

    -- Set nvim-notify as the handler (for history storage)
    -- Fidget will intercept and display via override_vim_notify
    vim.notify = notify

    vim.keymap.set('n', '<leader>pvn', "<cmd>:Telescope notify<CR>", { desc = "Open notification history in telescope." })
  end
}
