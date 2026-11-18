return {
  "undont/differ.nvim",
  build = "make go-build",
  config = function()
    require("differ").setup()
  end,
}
