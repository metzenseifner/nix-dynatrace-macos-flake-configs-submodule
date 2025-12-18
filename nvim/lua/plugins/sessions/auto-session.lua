return {
  "rmagatti/auto-session",

    init = function()
      vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
      -- enable saving the state of plugins in the session
      vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
      vim.opt.sessionoptions:append("localoptions") -- make sure filetype and highlighting work correctly after a session is restored.
    end,
  config = function(mod, ops)
    require('auto-session').setup({
      bypass_save_filetypes = { "setup" }, -- or whatever dashboard you use
      suppressed_dirs = { "~/", "~/Projects/", "~/Downloads/", "/", "~/.config/**/*", "~/.local/**/*"},
    })
  end
}
