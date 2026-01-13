return {
  "rcarriga/nvim-notify",
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
      level = 2,
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

    vim.notify = notify

    vim.keymap.set('n', '<leader>pvn', "<cmd>:Telescope notify<CR>", { desc = "Open notification history in telescope." })

    notify.setup(conf)
  end
}
