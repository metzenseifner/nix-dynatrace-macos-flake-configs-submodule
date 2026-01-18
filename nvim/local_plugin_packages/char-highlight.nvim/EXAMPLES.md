# Usage Examples for char-highlight.nvim

## Basic Configuration Examples

### Example 1: Trailing Whitespace Only

```lua
char_highlight.setup({
  pattern_sets = {
    trailing_space = {
      pattern = "%s+",
      highlight = "TrailingSpace",
      color = { bg = "#e74c3c", fg = "#ffffff" },
      context = { line_end = true },
    },
  },
})
```

### Example 2: NBSP in Yellow + Trailing Spaces

```lua
char_highlight.setup({
  char_sets = {
    nbsp = {
      chars = { "\u{00A0}" },
      highlight = "NBSPHighlight",
      color = { bg = "#ffff00", fg = "#000000" },  -- Yellow
    },
  },
  pattern_sets = {
    trailing_space = {
      pattern = "%s+",
      highlight = "TrailingSpace",
      color = { bg = "#e74c3c", fg = "#ffffff" },  -- Red
      context = { line_end = true },
    },
  },
})
```

### Example 3: Multiple Space Patterns

```lua
char_highlight.setup({
  pattern_sets = {
    -- Trailing spaces
    trailing_space = {
      pattern = "%s+",
      highlight = "TrailingSpace",
      color = { bg = "#e74c3c", fg = "#ffffff" },
      context = { line_end = true },
    },
    
    -- Multiple consecutive spaces (in the middle of text)
    multiple_spaces = {
      pattern = "  +",  -- Two or more spaces
      highlight = "MultiSpace",
      color = { bg = "#3498db", fg = "#ffffff", bold = true },
      context = { after_non_whitespace = true },
    },
    
    -- Leading spaces (indentation)
    leading_spaces = {
      pattern = "^ +",
      highlight = "LeadingSpace",
      color = { bg = "#9b59b6", fg = "#ffffff" },
      context = { line_start = true },
    },
  },
})
```

### Example 4: Comprehensive Invisible Characters

```lua
char_highlight.setup({
  char_sets = {
    -- Non-breakable spaces
    nbsp = {
      chars = { "\u{00A0}", "\u{202F}", "\u{2007}" },
      highlight = "NBSPHighlight",
      color = { bg = "#ff6b6b", fg = "#ffffff" },
    },
    
    -- Zero-width characters
    zero_width = {
      chars = { "\u{200B}", "\u{200C}", "\u{200D}", "\u{FEFF}" },
      highlight = "ZeroWidthHighlight",
      color = { bg = "#ffd93d", fg = "#000000" },
    },
    
    -- Tabs
    tabs = {
      chars = { "\t" },
      highlight = "TabHighlight",
      color = { bg = "#3498db", fg = "#ffffff" },
    },
    
    -- Right-to-left override (security concern)
    rtl_override = {
      chars = { "\u{202E}" },
      highlight = "RTLHighlight",
      color = { bg = "#800080", fg = "#ffffff" },
    },
  },
  
  pattern_sets = {
    trailing_space = {
      pattern = "%s+",
      highlight = "TrailingSpace",
      color = { bg = "#e74c3c", fg = "#ffffff" },
      context = { line_end = true },
    },
  },
})
```

## Runtime API Examples

### Add Pattern Dynamically

```lua
local ch = require('char-highlight')

-- Add a new pattern for highlighting TODO/FIXME
ch.add_pattern_set("todo_keywords", {
  pattern = "TODO%s*:",
  highlight = "TodoHighlight",
  color = { bg = "#f39c12", fg = "#000000", bold = true },
})
```

### Toggle Specific Patterns On/Off

```lua
local ch = require('char-highlight')

-- Disable trailing space highlighting
ch.remove_pattern_set("trailing_space")

-- Re-enable it
ch.add_pattern_set("trailing_space", {
  pattern = "%s+",
  highlight = "TrailingSpace",
  color = { bg = "#e74c3c", fg = "#ffffff" },
  context = { line_end = true },
})
```

### Conditional Configuration by Filetype

```lua
-- In your config
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local ch = require('char-highlight')
    -- Disable trailing space highlighting for markdown
    ch.remove_pattern_set("trailing_space")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "python", "javascript" },
  callback = function()
    local ch = require('char-highlight')
    -- Enable trailing space highlighting for code
    ch.add_pattern_set("trailing_space", {
      pattern = "%s+",
      highlight = "TrailingSpace",
      color = { bg = "#e74c3c", fg = "#ffffff" },
      context = { line_end = true },
    })
  end,
})
```

## Context Options Explained

### `line_end`
Matches only at the end of line (perfect for trailing whitespace):
```lua
pattern_sets = {
  trailing = {
    pattern = "%s+",
    context = { line_end = true },  -- Only matches: "text    \n"
  },
}
```

### `line_start`
Matches only at the beginning of line:
```lua
pattern_sets = {
  leading = {
    pattern = "^ +",
    context = { line_start = true },  -- Only matches: "   text"
  },
}
```

### `after_non_whitespace`
Matches only after non-whitespace content:
```lua
pattern_sets = {
  mid_spaces = {
    pattern = "  +",
    context = { after_non_whitespace = true },  -- Matches: "text  more" not "  text"
  },
}
```

### `word_boundary`
Matches only at word boundaries:
```lua
pattern_sets = {
  standalone = {
    pattern = "foo",
    context = { word_boundary = true },  -- Matches "foo bar" not "foobar"
  },
}
```

## Lua Pattern Quick Reference

- `%s` - Any whitespace character (space, tab, newline)
- `%s+` - One or more whitespace
- `%s*` - Zero or more whitespace
- `^ ` - Space at line start
- ` $` - Space at line end
- `  +` - Two or more consecutive spaces
- `[%s]+` - One or more whitespace (character class)
- `%S` - Any non-whitespace character

## Commands

- `:CharHighlightToggle` - Enable/disable all highlighting
- `:CharHighlightRefresh` - Manually refresh all buffers
