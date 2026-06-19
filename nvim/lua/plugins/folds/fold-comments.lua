return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/fold-comments.nvim",
  config = function()
    require('fold-comments').setup({
      keymap = "<leader>zc",
      keep_paragraphs = false,             -- fold blank lines
    })
  end
}
