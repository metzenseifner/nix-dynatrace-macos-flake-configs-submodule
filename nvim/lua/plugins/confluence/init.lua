-- Confluence.nvim - Edit Confluence pages directly in Neovim
return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/confluence.nvim",
  config = function()
    require('confluence').setup({
      base_url = "https://dt-rnd.atlassian.net",
      auth = {
        email = "jonathan.komar@dynatrace.com",
        token_supplier = function()
          -- Use gopass to get Confluence API token
          local handle = io.popen("gopass show -o dt/jira/dt-rnd.atlassian.net")
          if not handle then
            error("Failed to execute gopass command")
          end
          local token = handle:read("*l")
          handle:close()
          return token and token:gsub("%s+", "") or nil
        end,
      },
      buffer_options = {
        filetype = "confluence",
        wrap = true,
        spell = true,
      },
      pandoc = {
        enabled = true,         -- Enable pandoc conversions
        executable = "pandoc", -- Pandoc executable path
      }
    })
    
    -- Additional keymaps for the new API
    vim.keymap.set('n', '<leader>co', function()
      local url = vim.fn.input('Confluence URL: ')
      if url and url ~= '' then
        require('confluence').open_page(url, 'confluence')
      end
    end, { desc = 'Open Confluence page' })
    
    vim.keymap.set('n', '<leader>cO', function()
      local url = vim.fn.input('Confluence URL (org-mode): ')
      if url and url ~= '' then
        require('confluence').open_page(url, 'orgmode')
      end
    end, { desc = 'Open Confluence page as org-mode' })
  end
}
