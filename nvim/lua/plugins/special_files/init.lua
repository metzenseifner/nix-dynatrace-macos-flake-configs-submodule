return {
  --dir = "~/devel/special_files.nvim",
  "metzenseifner/special_files.nvim",
  event = "VeryLazy",
  config = function()
    require 'special'.setup({
      files = {
        base_dir = vim.fn.stdpath("data") .. "/jonathans_special_files",
      }
    })
  end
}
