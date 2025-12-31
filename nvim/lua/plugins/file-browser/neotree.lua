return {
  "nvim-neo-tree/neo-tree.nvim",
  event = "VeryLazy",
  branch = "v2.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  keymaps = {

  },
  config = function(plugin, opts)
    --vim.keymap.set('n', '<leader>tb', function() vim.cmd("Neotree focus left dir=" .. vim.fn.expand('%:h')) end,
    -- { desc = "Open neo-tree in parent directory of buffer if file backed by buffer." })

    local config = {
      -- not working
      --window = {
      --  mappings = {
      --    ["<C-v"] = "open_vsplit",
      --  }
      --},
      source_selector = {
        winbar = true,                         -- toggle to show selector on winbar
        statusline = false,                    -- toggle to show selector on statusline
        show_scrolled_off_parent_node = false, -- this will replace the tabs with the parent path
        -- of the top visible node when scrolled down.
        sources = {
          { source = "filesystem" },
          -- { source = "buffers" },
          { source = "git_status" },
        },
      },
      highlight_tab = "NeoTreeTabInactive",
      highlight_tab_active = "NeoTreeTabActive",
      highlight_background = "NeoTreeTabInactive",
      highlight_separator = "NeoTreeTabSeparatorInactive",
      highlight_separator_active = "NeoTreeTabSeparatorActive",
      filesystem = {
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            -- '.git',
            -- '.DS_Store',
            -- 'thumbs.db',
          },
          never_show = {},
        },
      },
      -- Auto follow buffer in neotree
      -- buffers = { follow_current_file = { enabled = true } }
    }

    require("neo-tree").setup(config)

    vim.keymap.set('n', '<leader>tr', ':Neotree filesystem reveal left<CR>', {desc="Reveal buffer file in Neotree."})
  end,
}
