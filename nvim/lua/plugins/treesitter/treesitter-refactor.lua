-- nvim-treesitter-refactor must be loaded AFTER nvim-treesitter
-- Loading it as a dependency causes "module 'nvim-treesitter.query' not found" errors
return {
  "nvim-treesitter/nvim-treesitter-refactor",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  event = "VeryLazy",
  config = function()
    -- Only configure if nvim-treesitter is available
    local has_treesitter, ts_configs = pcall(require, "nvim-treesitter.configs")
    if not has_treesitter then
      vim.notify("nvim-treesitter not available, skipping treesitter-refactor config", vim.log.levels.WARN)
      return
    end

    -- The plugin file will call init() automatically via plugin/nvim-treesitter-refactor.vim
    -- but we need to ensure treesitter is loaded first
  end,
}
