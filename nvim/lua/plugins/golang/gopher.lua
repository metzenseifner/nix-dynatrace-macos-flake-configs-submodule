return
{
  "olexsmir/gopher.nvim", -- the main goal of this plugin is to add go tooling support in Neovim.
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  ft = "go",

  ---@type gopher.Config
  opts = {
    commands = {
      go = "go",
      gomodifytags = "gomodifytags",
      gotests = "gotests",
      impl = "impl",
      iferr = "iferr",
      dlv = "dlv",
    },
    gotests = {
      -- gotests doesn't have template named "default" so this plugin uses "default" to set the default template
      template = "default",
      -- path to a directory containing custom test code templates
      template_dir = nil,
      -- switch table tests from using slice to map (with test name for the key)
      -- works only with gotests installed from develop branch
      named = false,
    },
    gotag = {
      transform = "snakecase",
    },
  },

  config = function(plugin, opts)
    require("gopher").setup(opts)
  end,

  -- (optional) will update plugin's deps on every update
  build = function() -- called on install or update
    vim.cmd [[silent! GoInstallDeps]]
    -- vim.cmd.GoInstallDeps()
  end,
}
