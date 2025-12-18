return {
  { "nvim-telescope/telescope-file-browser.nvim", event = "VeryLazy" },
  { import = "plugins.file-browser.ranger" },
  -- hope to migrate fully to telescope-file-browser someday
  { import = "plugins.file-browser.neotree" },
  { import = "plugins.file-browser.nvim-tree" }
  --{ import = "plugins.file-browser/chadtree" },
}
