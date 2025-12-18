return {
  {
    "coffebar/neovim-project",
    disable = true,
    event = "VeryLazy",
    priority = 10000,
    config = function()
      local conf = {
        projects = { -- define project roots
          "~/devel/dynatrace_bitbucket/15_TEAM_CARE_PROJECTS/*",
          "~/devel/dynatrace_bitbucket/05_BUILD_SYSTEM/*"
        },
        -- Path to store history and sessions
        picker = { -- define picker impl
          type = "telescope",
          --opts = {}
        },
        session_manager_opts = {
          autosave_last_session = true,
          autosave_only_in_session = true,
          autosave_ignore_not_normal = false,
          autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
            'gitcommit',
            'gitrebase',
            "toggleterm",
            "qf",
          },
          sessions_dir = require('plenary.path'):new(vim.fn.stdpath('data'), '/session_manager/sessions'), -- The directory where the session files will be saved.
          --session_filename_to_dir = session_filename_to_dir,                       -- Function that replaces symbols into separators and colons to transform filename into a session directory.
          --autoload_mode = "Disabled",                                                     -- Define what to do when Neovim is started without arguments. See "Autoload mode" section below. Could interfer with startup packages.
          autosave_ignore_dirs = {
            vim.fn.expand("~"), -- don't create a session for $HOME/
            "/tmp",
          },
        },
        -- Path to store history and sessions
        datapath = vim.fn.stdpath("data"), -- adds extra /neovim-project path segment,
        last_session_on_startup = false,
        -- Dashboard mode prevent session autoload on startup
        dashboard_mode = true, -- necessary for startup plugins like startup.nvim
        -- Timeout in milliseconds before trigger FileType autocmd after session load
        -- to make sure lsp servers are attached to the current buffer.
        -- Set to 0 to disable triggering FileType autocmd
        filetype_autocmd_timeout = 200,
        -- Keymap to delete project from history in Telescope picker
        forget_project_keys = {
          -- insert mode: Ctrl+d
          i = "<C-d>",
          -- normal mode: d
          n = "d"
        },
      }
      require("neovim-project").setup(conf)
      vim.keymap.set("n", "<leader>pp", ":NeovimProjectDiscover<CR>", { desc = "Pick a project." })
      vim.keymap.set("n", "<leader>pph", ":NeovimProjectHistory<CR>", { desc = "Pick a project from history." })
    end,

    init = function()
      -- enable saving the state of plugins in the session
      vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
    end,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      -- optional picker
      { "nvim-telescope/telescope.nvim" },
      -- optional picker
      { import = "plugins.sessions.neovim-session-manager" },
    },
  },
}
