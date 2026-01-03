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
    build = { ':TSUpdate', function()
      vim.notify(
        "nvim-treesitter has been changed. You might need to restart in a new shell.")
    end }, -- sometimes requires new terminal
    config = function()
      -- require('nvim-treesitter.configs').setup({
      --   highlight = {
      --       enable = true,
      --       -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      --       -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      --       -- Using this option may slow down your editor, and you may see some duplicate highlights.
      --       -- Instead of true it can also be a list of languages
      --       additional_vim_regex_highlighting = false,
      --     },
      --   incremental_selection = {
      --       enable = true,
      --       keymaps = {
      --         init_selection = "gnn",
      --         node_incremental = "grn",
      --         scope_incremental = "grc",
      --         node_decremental = "grm",
      --       },
      --     },
      --   indent = {
      --       enable = true
      --   }
      -- })
      --vim.api.nvim_set_hl(0, "@foo.bar", { link = "Identifier" })

      -- nvim-treesitter v1.0+ has a simpler API
      -- Setup is now optional - only needed for custom install_dir
      -- Use :TSInstall <language> to install parsers manually
      -- The old ensure_installed, highlight, indent configs are no longer supported in setup()
      
      -- Optional: uncomment if you need a custom install directory
      -- require('nvim-treesitter').setup({
      --   install_dir = vim.fn.stdpath('data') .. '/site'
      -- })
      
      -- Note: Treesitter highlighting, indentation, etc. now work automatically
      -- when parsers are installed. No setup configuration needed.
      
      -- Commented out legacy context_commentstring config
      -- context_commentstring = {
      --   -- nvim-JoosepAlviste/nvim-ts-context-commentstring
      --   enable = true, -- gcc for line comment,
      --   config = {
      --     -- language refers to the treesitter language, not the filetype or the file extension.
      --     javascript = {
      --       __default = "// %s",
      --       jsx_element = "{/* %s */}",
      --       jsx_fragment = "{/* %s */}",
      --       jsx_attribute = "// %s",
      --       comment = "// %s",
      --     },
      --     typescript = { __default = "// %s", __multiline = "/* %s */" },
      --   },
      -- },
      -- tree_docs = { enable = true },
      
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.tsx.filetype_to_parsername = { "javascript", "typescript", "tsx", "ts" }
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
