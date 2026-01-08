return {
  "walkersumida/fusen.nvim",
  version = "*",
  event = "VimEnter",
  opts = {
    save_file = vim.fn.expand("$HOME") .. "/my_fusen_marks.json",
  }
}
