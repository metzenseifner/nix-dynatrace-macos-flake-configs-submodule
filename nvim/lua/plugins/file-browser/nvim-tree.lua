return {
  "nvim-tree/nvim-tree.lua",
  event = "VeryLazy",
  config = function(_, _)
    require("nvim-tree").setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })
  end
}
