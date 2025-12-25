return {
  "EvWilson/spelunk.nvim",
  dependencies = {
    'nvim-telescope/telescope.nvim',  -- Optional: for enhanced fuzzy search capabilities
    'nvim-treesitter/nvim-treesitter', -- Optional: for showing grammar context
    'nvim-lualine/lualine.nvim',      -- Optional: for statusline display integration
  },
  config = function()
    require('spelunk').setup({
      enable_persist = true
    })
  end
}
