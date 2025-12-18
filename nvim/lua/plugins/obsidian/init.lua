-- lazy.nvim plugin spec
return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  event = "VeryLazy",
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/Obsidian Vault",
      },
      -- add more vaults if needed
    },
    -- Optional quality-of-life:
    notes_subdir = "Notes",         -- or ""
    daily_notes = { folder = "Daily" },
    completion = { nvim_cmp = true },
    disable_frontmatter = false,
    prefer_obsidian_links = true,   -- [[Wiki Links]] instead of markdown links
    follow_url_func = function(url) vim.fn.jobstart({"open", url}) end, -- macOS. Use xdg-open on Linux, start on Windows
  },
}
