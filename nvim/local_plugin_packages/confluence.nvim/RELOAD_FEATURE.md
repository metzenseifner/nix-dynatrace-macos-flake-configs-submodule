# Confluence.nvim - Reload Feature

## ✨ **New Feature**: `:e!` Reload Support

Confluence buffers now support reloading the latest version from the server using the standard Neovim `:e!` command.

## 🔄 **How It Works**

### Standard Neovim Commands
```vim
:e!               " Reload latest version from Confluence server
:w                " Save changes to Confluence server
```

### Plugin Commands  
```vim
:ConfluenceReload " Explicit reload command
:ConfluenceSave   " Explicit save command
```

### Buffer-local Keymaps
```vim
<leader>cr        " Reload from server
<leader>cs        " Save to server
<leader>cq        " Close buffer
```

## 🎯 **Use Cases**

### Collaborative Editing
```vim
" You're editing a page
:ConfluenceOpen https://...

" Someone else makes changes on the web
" You want to see their changes
:e!               " Gets latest version

" You make more changes
" Save your updates
:w
```

### Conflict Resolution
```vim
" Your save fails due to version conflict
" Reload to see latest changes
:e!

" Merge your changes manually
" Save again
:w
```

### Fresh Start
```vim
" You made experimental changes
" Want to start over with server version
:e!               " Discards local changes, loads server version
```

## 🔧 **Technical Implementation**

### Buffer-specific Autocmd
```lua
-- Only applies to Confluence buffers
vim.api.nvim_create_autocmd("BufReadCmd", {
  buffer = buf,  -- Specific buffer only
  callback = function()
    require('confluence').reload()
  end,
})
```

### Reload Process
1. **Fetch latest content** from Confluence API
2. **Convert format** from HTML storage to readable
3. **Replace buffer content** with fresh data
4. **Update version** in cache
5. **Mark as unmodified** (no unsaved changes)

## ✅ **Version Management**

### Automatic Version Tracking
- **On load**: Gets current version from server
- **On save**: Increments version number
- **On reload**: Updates to latest server version
- **Version conflicts**: Detected automatically

### Version Information
```vim
" Reload shows current version
:e!
" Output: Page reloaded successfully (version 42)
```

## 🛡️ **Safety Features**

### Unsaved Changes Warning
- Neovim's standard `:e!` behavior applies
- Warns about unsaved changes before reload
- Use `:e!` to force reload (discards changes)

### Error Handling
- **Network errors**: Clear error messages
- **Permission errors**: Helpful feedback  
- **Version conflicts**: Graceful handling

## 📋 **Comparison with Standard Files**

| Action | Normal Files | Confluence Buffers |
|--------|-------------|-------------------|
| `:w` | Save to disk | Save to Confluence API |
| `:e!` | Reload from disk | Reload from Confluence API |
| `<C-o>` | Jump back | Works normally |
| `:q!` | Quit without save | Quit without save |

## 🎯 **Workflow Examples**

### Daily Editing
```vim
:ConfluenceOpen <url>     " Open page
" Edit content normally
:w                        " Save to Confluence
```

### Collaborative Sessions
```vim
:ConfluenceOpen <url>     " Open shared page
" Edit your section
:w                        " Save your changes
:e!                       " Check for others' changes
" Continue editing
:w                        " Save again
```

### Emergency Reload
```vim
" Something went wrong with local content
:e!                       " Fresh start from server
```

---

*Seamless reload functionality for collaborative Confluence editing!*