return {
  -- provides peek at definition (maybe this can be implemented without lspsaga)
  "glepnir/lspsaga.nvim",
  branch = "main",
  config = function()
    require("lspsaga").setup({
      outline = {
        win_position = 'right',
        win_width = 30,
        auto_preview = true,
        detail = true,
        auto_close = true,
        close_after_jump = false,
        layout = 'normal',
        max_height = 0.5,
        left_width = 0.3,
        keys = {
          toggle_or_jump = 'e',
          quit = 'q',
          jump = '<leader>gd',
        },
      },
      lightbulb = {
        enable = false,
        enable_in_insert = true,
        sign = true,
        sign_priority = 40,
        virtual_text = true,
      },
    })
  end,
  dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
