# SmartTerm.nvim

A minimal, fast terminal toggle for Neovim. **93 lines of code, maximum functionality.**

## Features

✅ **Horizontal split at bottom** - Creates proper split, preserves your current buffer  
✅ **Fast O(1) caching** - No buffer iteration, direct cache lookup  
✅ **Toggle visibility** - Show/hide without killing the job  
✅ **Reuse terminals** - Keeps job alive when hidden  
✅ **Minimal code** - Only 93 lines, no bloat  
✅ **Bug-free** - Proper buffer handling for termopen  

## Usage

### Basic Setup

```lua
require('smartterm').setup()

-- Keybinding
vim.keymap.set({ 'n', 't' }, '<leader>T', require('smartterm').toggle)
```

### Configuration

```lua
require('smartterm').setup({
  height = 14,              -- height of horizontal split  
  start_in_insert = true,   -- enter insert mode when opening
})
```

### API

```lua
local smartterm = require('smartterm')

smartterm.toggle()  -- Toggle terminal visibility
smartterm.open()    -- Show terminal (create if needed) 
smartterm.close()   -- Hide terminal (keep job alive)
```

### Commands

- `:ToggleTerm` - Toggle terminal visibility

## How It Works

1. **Proper splits**: Uses `botright split` to create horizontal split at bottom
2. **Clean buffers**: Creates new empty buffer for termopen (avoids "unmodified buffer" errors)
3. **Preserves buffers**: Never replaces your current editing buffer
4. **Fast caching**: Stores terminal references for instant reuse
5. **Job persistence**: Terminal process stays alive when hidden

## Code Size

- **93 lines total** - Minimal, focused implementation
- **3 core functions** - `open()`, `close()`, `toggle()`  
- **2 helper functions** - `is_visible()`, `is_alive()`
- **No bloat** - Every line serves a purpose

## Why It's Better

❌ **Other solutions**: 200+ lines, complex state machines, slow buffer iteration  
✅ **SmartTerm**: 93 lines, simple cache, O(1) lookups, proper buffer handling

---

*Minimal terminal toggling, maximum efficiency.*