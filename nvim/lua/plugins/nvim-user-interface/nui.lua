return {
  "MunifTanjim/nui.nvim",
  event = "VeryLazy",
  config = function(_, _)
    -- Override vim.ui.input with nui.input
    local Input = require("nui.input")
    local event = require("nui.utils.autocmd").event

    vim.ui.input = function(opts, on_confirm)
      local input = Input({
        position = {
          row = "100%",
          col = 0,
        },
        size = {
          width = "100%",
          height = 1,
        },
        border = {
          style = "single",
          text = {
            top = opts.prompt or " Input ",
            top_align = "center",
          },
        },
        win_options = {
          winhighlight = "Normal:Normal,FloatBorder:TelescopeBorder",
        },
      }, {
        prompt = "",
        default_value = opts.default or "",
        on_submit = on_confirm,
      })

      input:mount()
      input:on(event.BufLeave, function()
        input:unmount()
      end)
    end
  end
}
