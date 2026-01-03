return
{
  --{ import = "plugins.treesitter.treesitter-custom-queries" },
  {
    "nvim-treesitter/nvim-treesitter",
    enable = true,
    --lock = true,
    --tag = 'v0.9.2',
    --branch = "main",-- check build status at https://github.com/nvim-treesitter/nvim-treesitter/branches
    -- indentation module could influence indentexpr; verbose set indentexpr?
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      --{ "nvim-treesitter/nvim-tree-docs" },
    },
    event = 'BufRead',
    build = ':TSUpdate',
    config = function()
      -- Modern nvim-treesitter (v1.0+) works automatically when parsers are installed
      -- No setup() call needed - highlighting, indentation, etc. work out of the box
      -- Just install parsers with :TSInstall <language>
      
      -- The old APIs are removed:
      -- - nvim-treesitter.configs (removed)
      -- - require('nvim-treesitter.parsers').get_parser_configs() (removed)
      -- - Manual parser configuration (no longer needed)
      
      -- Modern treesitter automatically handles:
      -- ✓ TSX/JSX files (via typescript and tsx parsers)
      -- ✓ Syntax highlighting
      -- ✓ Indentation
      -- ✓ Folding
      -- ✓ Incremental selection
      
      -- To install parsers: :TSInstall javascript typescript tsx python lua
      -- To update parsers: :TSUpdate
      -- To check status: :TSInstallInfo
    end,
    -- build = "TSUpdate",
    -- {'do': ':TSUpdate'}
    -- see :TSInstallInfo
  },
  --{
  --  "nvim-treesitter/nvim-treesitter-textobjects",
  --  dependencies = {
  --    { 'nvim-treesitter/nvim-treesitter' }-- should load after treesitter
  --  },
  --  config = function(_, opts)
  --    require 'nvim-treesitter.configs'.setup {
  --      textobjects = {
  --        select = {
  --          enable = true,

  --          -- Automatically jump forward to textobj, similar to targets.vim
  --          lookahead = true,

  --          keymaps = {
  --            -- You can use the capture groups defined in textobjects.scm
  --            ["af"] = "@function.outer",
  --            ["if"] = "@function.inner",
  --            ["ac"] = "@class.outer",
  --            -- You can optionally set descriptions to the mappings (used in the desc parameter of
  --            -- nvim_buf_set_keymap) which plugins like which-key display
  --            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
  --            -- You can also use captures from other query groups like `locals.scm`
  --            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
  --          },
  --          -- You can choose the select mode (default is charwise 'v')
  --          --
  --          -- Can also be a function which gets passed a table with the keys
  --          -- * query_string: eg '@function.inner'
  --          -- * method: eg 'v' or 'o'
  --          -- and should return the mode ('v', 'V', or '<c-v>') or a table
  --          -- mapping query_strings to modes.
  --          selection_modes = {
  --            ['@parameter.outer'] = 'v', -- charwise
  --            ['@function.outer'] = 'V',  -- linewise
  --            ['@class.outer'] = '<c-v>', -- blockwise
  --          },
  --          -- If you set this to `true` (default is `false`) then any textobject is
  --          -- extended to include preceding or succeeding whitespace. Succeeding
  --          -- whitespace has priority in order to act similarly to eg the built-in
  --          -- `ap`.
  --          --
  --          -- Can also be a function which gets passed a table with the keys
  --          -- * query_string: eg '@function.inner'
  --          -- * selection_mode: eg 'v'
  --          -- and should return true of false
  --          include_surrounding_whitespace = true,
  --        },
  --      },
  --    }
  --  end
  --}
}
