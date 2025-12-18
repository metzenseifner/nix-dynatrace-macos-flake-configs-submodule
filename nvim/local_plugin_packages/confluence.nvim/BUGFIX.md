# Confluence.nvim - Write Command Fix

## 🐛 **Bug**: Normal Files Couldn't Save

**Issue**: After installing Confluence.nvim, `:w` stopped working for normal files.

**Root Cause**: The plugin was creating a global `BufWriteCmd` autocmd that intercepted ALL write commands, not just Confluence buffers.

## 🔧 **Fix Applied**

### Before (Problematic):
```lua
-- This intercepted ALL buffers
vim.api.nvim_create_autocmd("BufWriteCmd", {
  pattern = "*",  -- Applied to all files!
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if page_cache[buf] then
      M.save()  -- Confluence save
    -- No else clause - normal files couldn't save!
    end
  end,
})
```

### After (Fixed):
```lua
-- Only applied to specific Confluence buffers
vim.api.nvim_create_autocmd("BufWriteCmd", {
  buffer = buf,  -- Specific buffer only!
  callback = function()
    require('confluence').save()
  end,
})
```

## ✅ **Result**

**Normal Files:**
- ✅ `:w` works normally for all regular files
- ✅ No interference from Confluence plugin
- ✅ Standard Neovim behavior preserved

**Confluence Buffers:**
- ✅ `:w` saves to Confluence API
- ✅ Buffer-specific autocmd only
- ✅ Proper format conversion applied

## 🧪 **Verified Working**

```bash
# Test normal file saving
echo "test" > /tmp/test.txt
nvim /tmp/test.txt
# :w works normally ✅

# Test Confluence functionality  
nvim
# :ConfluenceOpen <URL> creates buffer with custom :w behavior ✅
```

## 📋 **Key Learning**

**Buffer-specific autocmds** are safer than global patterns when you want to modify core Neovim behavior like `:w`:

```lua
-- ❌ Global (affects all buffers)
vim.api.nvim_create_autocmd("BufWriteCmd", { pattern = "*", ... })

-- ✅ Buffer-specific (affects only target buffer)  
vim.api.nvim_create_autocmd("BufWriteCmd", { buffer = buf, ... })
```

---

*Write commands now work correctly for both normal files and Confluence pages!*