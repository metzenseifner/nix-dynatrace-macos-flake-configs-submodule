return {
  "rcarriga/nvim-notify",
  lazy = false,
  priority = 1000, -- Load before fidget
  config = function(_, _)
    -- Stop nvim-notify minting a fresh Notify<LEVEL><Section><bufnr> group per
    -- notification, which never gets freed and eventually triggers E849 (too
    -- many highlight groups). The window is invisible here (see below), so
    -- reusing the static base Notify* groups has no visual effect. Must run
    -- before require("notify"), which eagerly captures this factory.
    package.loaded["notify.service.buffer.highlights"] = function(level, buffer, config)
      local function base(section)
        local group = "Notify" .. level .. section
        if vim.fn.hlID(group) == 0 then
          group = "NotifyINFO" .. section
        end
        return group
      end
      local hl = {
        groups = {},
        opacity = 100,
        buffer = buffer,
        _config = config,
        title = base("Title"),
        border = base("Border"),
        body = base("Body"),
        icon = base("Icon"),
      }
      function hl:set_opacity(alpha)
        self.opacity = alpha
        return false
      end
      function hl:get_opacity()
        return self.opacity
      end
      function hl:_redefine_treesitter() end
      return hl
    end

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
