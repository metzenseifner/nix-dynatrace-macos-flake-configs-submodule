return {
  dir = vim.fn.stdpath("config") .. "/local_plugin_packages/treesitter-custom-queries.nvim",
  dev = false,
  config = function()
    require("treesitter-custom-queries")
    vim.keymap.set("n", "<leader>qf", function() require("treesitter-custom-queries").query_todo() end,
      { desc = "Todos to quickfix list" })
  end
}
