return {
  'willothy/wezterm.nvim',
  lazy = true,
  event = "VeryLazy",
  config = function()
    local wezterm_path = '/Applications/WezTerm.app/Contents/MacOS/wezterm'
    
    -- Only setup if wezterm exists
    if vim.fn.executable(wezterm_path) == 1 then
      require('wezterm').setup({
        path = wezterm_path
      })
    end
  end
}
