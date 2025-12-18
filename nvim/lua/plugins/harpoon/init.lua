return {
  "ThePrimeagen/harpoon",
  dependencies = {
    "nvim-lua/plenary.nvim"
  },
  keys = {
    -- LazyKeysSpec
    {
      "<leader>ha",
      function()
        vim.notify("Adding harpoon mark")
        require("harpoon.mark").add_file()
      end,
      desc =
      "Add file to Harpoon."
    },
    {
      "<leader>hm",
      ":Telescope harpoon marks<CR>",
      --function() require("harpoon.ui").toggle_quick_menu() end,
      desc =
      "Open Harpoon menu."
    },
    {
      "<leader>ht1",
      function() require("harpoon.term").gotoTerminal(1) end,
      desc =
      "Go to terminal 1 else create new terminal buffer and go to it."
    },
    {
      "<leader>hc1",
      function()
        vim.ui.input({ prompt = "Enter command: " },
          function(input) require("harpoon.term").sendCommand(1, input) end)
      end,
      desc =
      "Send command to terminal 1."
    },
  },
  config = function()

    -- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",
--
    vim.keymap.set('n', '<C-b>', function() require('harpoon.ui').nav_prev() end, {desc="Harpoon jump to previous mark."})


    return {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
        global_settings = {
          -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
          save_on_toggle = false,

          -- saves the harpoon file upon every change. disabling is unrecommended.
          save_on_change = true,

          -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
          enter_on_sendcmd = false,

          -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
          tmux_autoclose_windows = false,

          -- filetypes that you want to prevent from adding to the harpoon list menu.
          excluded_filetypes = { "harpoon" },

          -- set marks specific to each git branch inside git repository
          mark_branch = false,

          -- enable tabline with harpoon marks
          tabline = false,
          tabline_prefix = "   ",
          tabline_suffix = "   ",
        }
      }
    }
  end,

}
