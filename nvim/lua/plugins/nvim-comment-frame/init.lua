return {
  "s1n7ax/nvim-comment-frame",
  event = "VeryLazy",
  dependencies = {
    { 'nvim-treesitter' }
  },
  opts = {
    -- GLOBAL Config

    -- if true, <leader>cf keymap will be disabled
    disable_default_keymap = false,

    -- adds custom keymap
    --keymap = '<leader>cc',
    --multiline_keymap = '<leader>C',

    -- start the comment with this string
    start_str = '//',

    -- end the comment line with this string
    end_str = '//',

    -- fill the comment frame border with this character
    fill_char = '-',

    -- width of the comment frame
    frame_width = 80,

    -- wrap the line after 'n' characters
    line_wrap_len = 50,

    -- automatically indent the comment frame based on the line
    auto_indent = true,

    -- add comment above the current line
    add_comment_above = true,

    languages = {
      http = {
        start_str = '#',
        end_str = '#',
        fill_char = '-',
      },
      bash = {
        start_str = '#',
        end_str = '#',
        fill_char = '-',
      },
      zsh = {
        start_str = '#',
        end_str = '#',
        fill_char = '-',
      }
    }
    -- configurations for individual language goes here
    --languages = {
    --  -- configuration for Lua programming language
    --  -- @NOTE global configuration will be overridden by language level
    --  -- configuration if provided
    --  markdown = {
    --    start_str = '-',
    --    end_str = '-',
    --    fill_char = "-"
    --  },
    --  lua = {
    --    -- start the comment with this string
    --    start_str = '--',

    --    -- end the comment line with this string
    --    end_str = '--',

    --    -- fill the comment frame border with this character
    --    fill_char = '-',

    --    -- width of the comment frame
    --    frame_width = 80,

    --    -- wrap the line after 'n' characters
    --    line_wrap_len = 70,

    --    -- automatically indent the comment frame based on the line
    --    auto_indent = false,

    --    -- add comment above the current line
    --    add_comment_above = false,

    --  },
    --  python = {
    --    frame_width = 80
    --  }
    --}
  },
  config = function(_, opts)
    vim.api.nvim_set_keymap('n', '<leader>C', ":lua require('nvim-comment-frame').add_comment()<CR>", {})
    vim.api.nvim_set_keymap('n', '<leader>CC', ":lua require('nvim-comment-frame').add_multiline_comment()<CR>", {})
    require 'nvim-comment-frame'.setup(opts)
  end,
}
