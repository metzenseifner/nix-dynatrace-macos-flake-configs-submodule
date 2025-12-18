return {
  "metzenseifner/komar-utilities.nvim",
  event = "VeryLazy",
  config = function()
    require("komar-utilities").setup({})
  end,
}
