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
  config = function()
    -- Only setup if vault directory exists
    local vault_path = vim.fn.expand("~/Documents/Obsidian Vault")

    if vim.fn.isdirectory(vault_path) == 0 then
      -- Don't setup if vault doesn't exist - plugin is optional
      vim.notify(
        "Obsidian vault not found at " .. vault_path .. ". Plugin disabled. Create vault to enable.",
        vim.log.levels.INFO
      )
      return
    end

    require("obsidian").setup({
      picker = {
        -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
        name = "telescope.nvim",
        -- Optional, configure key mappings for the picker. These are the defaults.
        -- Not all pickers support all mappings.
        note_mappings = {
          -- Create a new note from your query.
          new = "<C-x>",
          -- Insert a link to the selected note.
          insert_link = "<C-l>",
        },
        tag_mappings = {
          -- Add tag(s) to current note.
          tag_note = "<C-x>",
          -- Insert a tag at the current location.
          insert_tag = "<C-l>",
        },
      },
      workspaces = {
        {
          name = "personal",
          path = vault_path,
        },
      },
      notes_subdir = "Notes",
      daily_notes = { folder = "Daily" },
      completion = { nvim_cmp = true },
      disable_frontmatter = false,
      prefer_obsidian_links = true,
      follow_url_func = function(url)
        -- Cross-platform URL opening
        local cmd
        if vim.fn.has("mac") == 1 then
          cmd = { "open", url }
        elseif vim.fn.has("unix") == 1 then
          cmd = { "xdg-open", url }
        elseif vim.fn.has("win32") == 1 then
          cmd = { "cmd", "/c", "start", url }
        end
        if cmd then
          vim.fn.jobstart(cmd)
        end
      end,
    })
  end,
}
