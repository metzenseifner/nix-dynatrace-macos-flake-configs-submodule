# Confluence.nvim - Subcommand API & Org-mode Support

## 🚀 **New Subcommand API**

The plugin now uses a modern subcommand system instead of separate commands.

### Before (Old API)
```vim
:ConfluenceOpen <URL>
:ConfluenceSave
:ConfluenceReload
:ConfluenceSetup
```

### After (New API)
```vim
:Confluence open <URL>
:Confluence save
:Confluence reload  
:Confluence setup
```

## 📋 **Format Support**

### Default Confluence Format
```vim
:Confluence open https://example.com/wiki/pages/123/Page
" Opens in confluence format with HTML ↔ readable conversion
```

### Org-mode Format (NEW!)
```vim
:Confluence open --as=orgmode https://example.com/wiki/pages/123/Page
" Opens in org-mode format with pandoc conversion
```

## 🔧 **Configuration**

### Enable Pandoc Support
```lua
require('confluence').setup({
  -- ... existing config ...
  pandoc = {
    enabled = true,          -- Enable pandoc conversions
    executable = "pandoc",   -- Pandoc executable path
  }
})
```

### Keymaps for Both Formats
```lua
-- Confluence format
vim.keymap.set('n', '<leader>co', function()
  local url = vim.fn.input('Confluence URL: ')
  if url and url ~= '' then
    vim.cmd('Confluence open ' .. url)
  end
end, { desc = 'Open Confluence page' })

-- Org-mode format
vim.keymap.set('n', '<leader>cO', function()
  local url = vim.fn.input('Confluence URL (org-mode): ')
  if url and url ~= '' then
    vim.cmd('Confluence open --as=orgmode ' .. url)
  end
end, { desc = 'Open Confluence page as org-mode' })
```

## 🎯 **Format Comparison**

| Feature | Confluence Format | Org-mode Format |
|---------|------------------|-----------------|
| **Requirements** | None | pandoc executable |
| **Filetype** | `confluence` | `org` |
| **Syntax** | Basic markdown-like | Full org-mode |
| **Conversion** | HTML ↔ readable | HTML ↔ org via pandoc |
| **Best for** | Quick edits | Complex documents |
| **Performance** | Fast | Slower (pandoc overhead) |

## 📝 **Example Workflows**

### Quick Edit (Confluence Format)
```vim
:Confluence open https://dt-rnd.atlassian.net/wiki/pages/123/Quick-Notes
" Edit with simple formatting
:w                     " Save back to Confluence
```

### Complex Document (Org-mode Format)  
```vim
:Confluence open --as=orgmode https://dt-rnd.atlassian.net/wiki/pages/456/Project-Plan
" Edit with full org-mode features:
" - TODO items: * TODO Task name
" - Tables: | Column 1 | Column 2 |
" - Code blocks: #+begin_src language
" - Headers: * Level 1, ** Level 2
:w                     " Converts back to HTML and saves
```

### Collaborative Editing
```vim
:Confluence open --as=orgmode https://example.com/wiki/pages/789/Meeting-Notes
" Someone else edits via web interface
:e!                    " Reload latest version
" Continue editing in org-mode
:w                     " Save your changes
```

## 🔄 **Conversion Flow**

### Confluence → Org-mode (Opening)
```
1. Fetch HTML from Confluence API
2. Clean HTML for pandoc compatibility  
3. pandoc: HTML → org-mode
4. Display in Neovim with org filetype
```

### Org-mode → Confluence (Saving)
```
1. Get org-mode content from buffer
2. pandoc: org-mode → HTML
3. Convert HTML to Confluence storage format
4. Send to Confluence API
```

## 🛠️ **Troubleshooting**

### Pandoc Not Found
```vim
:Confluence setup
" Check if pandoc is available
```

### Conversion Errors
```vim
" Test pandoc manually:
:!pandoc --version
:!echo "* Test" | pandoc -f org -t html
```

### Format Detection
```vim
" Check current page format:
:lua print(vim.inspect(require('confluence')._get_page_data(0)))
```

## 🎯 **Migration Guide**

### Update Commands
```vim
" Old → New
:ConfluenceOpen <URL>     →  :Confluence open <URL>
:ConfluenceSave           →  :Confluence save  
:ConfluenceReload         →  :Confluence reload
:ConfluenceSetup          →  :Confluence setup
```

### Update Keymaps
```lua
-- Old
vim.keymap.set('n', '<leader>co', function()
  require('confluence').open(url)
end)

-- New
vim.keymap.set('n', '<leader>co', function()
  vim.cmd('Confluence open ' .. url)
end)
```

---

*Extensible API with powerful format support for any Confluence editing workflow!*