return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {},

  config = function()
    vim.keymap.set("n", "<leader>z", function()
      require("which-key").show({ keys = "z" })
    end, { desc = "Show fold commands" })
  end
}
