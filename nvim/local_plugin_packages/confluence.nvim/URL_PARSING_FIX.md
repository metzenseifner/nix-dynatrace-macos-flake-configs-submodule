# URL Parsing Fix

## 🐛 **Issue**: Command not recognizing URL

**Problem**: When running `:Confluence open <URL>`, the plugin was showing "Please provide a Confluence URL" even when a URL was provided.

**Root Cause**: The command handler wasn't properly parsing the URL from the command arguments.

## 🔧 **Fix Applied**

### Simplified Command Handler
```lua
-- Before: Complex argument parsing that failed with URLs
function M.command_handler(args)
  -- Complex parsing that split URLs incorrectly
end

-- After: Simple, robust URL handling
function M.command_handler(args)
  if subcommand == "open" then
    local rest_args = {}
    for i = 2, #args.fargs do
      table.insert(rest_args, args.fargs[i])
    end
    
    local url = table.concat(rest_args, " ") -- Join URL parts
    local format = "confluence"
    
    if url:match("--as=orgmode") then
      format = "orgmode"
      url = url:gsub("%s*--as=orgmode%s*", "")
    end
    
    M.open_page(url, format) -- Direct function call
  end
end
```

### New Direct Function
```lua
-- Clean, direct function for opening pages
function M.open_page(url, format)
  -- Handles URL and format directly
  -- No complex argument parsing needed
end
```

## ✅ **Now Working**

**Commands that now work:**
```vim
:Confluence open https://dt-rnd.atlassian.net/wiki/spaces/~712020a30e03943f474896bf2d9bf8a1a2b23a/pages/1587184001/Experiments+with+confluence.nvim

:Confluence open --as=orgmode https://dt-rnd.atlassian.net/wiki/spaces/~712020a30e03943f474896bf2d9bf8a1a2b23a/pages/1587184001/Experiments+with+confluence.nvim
```

**Keymaps (recommended):**
```vim
<leader>co   " Prompts for URL, opens in confluence format
<leader>cO   " Prompts for URL, opens in org-mode format
```

## 🎯 **Recommended Usage**

**Use keymaps for easier input:**
```vim
" Press <leader>co
" Type or paste: https://dt-rnd.atlassian.net/wiki/spaces/~712020a30e03943f474896bf2d9bf8a1a2b23a/pages/1587184001/Experiments+with+confluence.nvim
" Press Enter
```

**Or use commands directly:**
```vim
" Just paste the URL after 'open'
:Confluence open https://your-url-here
```

## 🔧 **Updated Keymaps**

Your configuration now uses the direct function calls:
```lua
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
```

---

*URL parsing is now robust and handles long Confluence URLs correctly!*