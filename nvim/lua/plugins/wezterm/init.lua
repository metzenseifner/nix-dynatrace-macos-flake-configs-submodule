return {
  'willothy/wezterm.nvim',
  lazy = true,
  event = "VeryLazy",
  config = function()
    local wezterm_path = vim.fn.exepath("wezterm")

    ---- Only setup if wezterm exists
    if wezterm_path ~= "" then
      require('wezterm').setup({
        path = wezterm_path
      })
    else
      vim.notify("Wezterm executable not found, skipping loading wezterm plugin.", vim.log.levels.WARN)
    end
  end
}
