return {
  {
    { dir = "~/devel/print.nvim" },
    { "tpope/vim-unimpaired" },
    { "tpope/vim-dispatch" },
    { "radenling/vim-dispatch-neovim" },
    { "wfxr/minimap.vim" },            -- Orientation in file
    { "norcalli/nvim-colorizer.lua" }, -- for quick color selection like in hex
    { "ojroques/nvim-osc52" },
    --{ "DanilaMihailov/beacon.nvim" }, -- cursor jump animation
    { "junegunn/gv.vim" }, -- browser commit history
    -- { -- TODO Useful, but screws up JSON, MD, if not disabled properly
    --   "Yggdroot/indentLine",
    --   -- will no longer see quotation marks in their JSON files and markdown files.
    --   -- " See https://github.com/Yggdroot/indentLine/commit/7753505f3c500ec88d11e9373d05250f49c1d900
    --   -- fix using postupdate hook
    --   -- cmd = 'let g:indentLine_enabled = 0 | let g:indentLine_setConceal=0 | let g:vim_json_conceal=0 | let g:markdown_syntax_conceal=0' -- | let g:indentLine_fileType = ["yaml"]
    -- },                       -- adds vertical lines along indentations but screws up JSON by removing quotes
    { "mbbill/undotree" },
    {
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup()
      end,
    },
    --{ "ray-x/lsp_signature.nvim" }, -- kicks in when lsp code completion not supported for buffer
    {
      "folke/todo-comments.nvim",
      dependencies = "nvim-lua/plenary.nvim",
    },
    {
      "RishabhRD/lspactions",
      dependencies = { "nvim-lua/plenary.nvim", "nvim-lua/popup.nvim" },
    },
    {
      "lewis6991/hover.nvim",
      config = function()
        require("hover").setup({
          init = function()
            -- Require providers
            require("hover.providers.lsp")
            -- require('hover.providers.gh')
            -- require('hover.providers.gh_user')
            -- require('hover.providers.jira')
            -- require('hover.providers.man')
            -- require('hover.providers.dictionary')
          end,
          preview_opts = {
            border = nil,
          },
          -- Whether the contents of a currently open hover window should be moved
          -- to a :h preview-window when pressing the hover keymap.
          preview_window = false,
          title = true,
        })
      end,
    },
    --{
    --  "microsoft/vscode-js-debug",
    --  opt = true,
    --  build = "npm install --legacy-peer-deps && npm build compile"
    --}
    {
      "s1n7ax/nvim-window-picker",
      config = function()
        require("window-picker").setup()
      end,
    },
    {
      "folke/trouble.nvim",
      dependencies = "nvim-tree/nvim-web-devicons",
      config = function()
        require("trouble").setup({})
      end,
    },
    {
      "chentoast/marks.nvim",
      config = function()
        require("marks").setup({
          -- whether to map keybinds or not. default true
          default_mappings = true,
          -- which builtin marks to show. default {}
          builtin_marks = { ".", "<", ">", "^" },
          -- whether movements cycle back to the beginning/end of buffer. default true
          cyclic = true,
          -- whether the shada file is updated after modifying uppercase marks. default false
          force_write_shada = false,
          -- how often (in ms) to redraw signs/recompute mark positions.
          -- higher values will have better performance but may cause visual lag,
          -- while lower values may cause performance penalties. default 150.
          refresh_interval = 250,
          -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
          -- marks, and bookmarks.
          -- can be either a table with all/none of the keys, or a single number, in which case
          -- the priority applies to all marks.
          -- default 10.
          sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
          -- disables mark tracking for specific filetypes. default {}
          excluded_filetypes = {},
          -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
          -- sign/virttext. Bookmarks can be used to group together positions and quickly move
          -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
          -- default virt_text is "".
          bookmark_0 = {
            sign = "⚑",
            virt_text = "hello world",
            -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
            -- defaults to false.
            annotate = false,
          },
          mappings = {
            set_next = "m,",
            next = "m]",
            preview = "m:",
            set_bookmark0 = "m0",
            prev = false -- pass false to disable only this default mapping
          },
        })
      end,
    },
    {
      "nvim-telescope/telescope-file-browser.nvim",
      dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    },
    --{ 'dundalek/lazy-lsp.nvim', dependencies = { 'neovim/nvim-lspconfig' }},
    { "aaron-p1/virt-notes.nvim" },
    --{
    --  "cuducos/yaml.nvim.git",
    --  ft = { "yaml" }, -- optional to activate based on filetype
    --  dependencies = {
    --    "nvim-treesitter/nvim-treesitter",
    --    "nvim-telescope/telescope.nvim", -- optional
    --  },
    --}
  },
}
