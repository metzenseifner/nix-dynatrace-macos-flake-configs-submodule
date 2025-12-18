return {
  "glacambre/firenvim",
  enabled = true,

  -- Lazy load firenvim
  -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
  lazy = not vim.g.started_by_firenvim, --delay loading when global var is not set (firenvim sets this when started from browser)
  module = false,
  build = function()
    vim.fn["firenvim#install"](0)
  end
}
