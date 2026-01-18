# char-highlight.nvim

Extensible Neovim plugin to highlight specific character patterns with configurable colors and context rules.

## Features

- 🎨 Map character sets to custom highlight colors
- 🔍 Support for both exact characters and Lua patterns
- 📍 Context-aware matching (line start/end, word boundaries, etc.)
- ⚡ Real-time updates as you type
- 🛠️ Extensible API - add/remove sets dynamically
- 🎯 High priority highlights over syntax highlighting

## Configuration

Edit `lua/plugins/char-highlight.lua`:

### Character-Based Matching

```lua
char_highlight.setup({
  char_sets = {
    -- Yellow highlight for non-breakable spaces
    nbsp = {
      chars = { "\u{00A0}" },
      highlight = "CharHighlightNBSP",
      color = { bg = "#ffff00", fg = "#000000" },
    },
    -- Tabs
    tabs = {
      chars = { "\t" },
      highlight = "CharHighlightTab",
      color = { bg = "#3498db", fg = "#ffffff" },
    },
  },
})
```

### Pattern-Based Matching with Context

```lua
char_highlight.setup({
  pattern_sets = {
    -- Trailing spaces at end of line
    trailing_space = {
      pattern = "%s+",
      highlight = "TrailingSpace",
      color = { bg = "#e74c3c", fg = "#ffffff" },
      context = {
        line_end = true,  -- Only match at end of line
      },
    },
    
    -- Multiple consecutive spaces (not at line start)
    multiple_spaces = {
      pattern = "  +",  -- Two or more spaces
      highlight = "MultiSpace",
      color = { bg = "#3498db", fg = "#ffffff" },
      context = {
        after_non_whitespace = true,
      },
    },
    
    -- Leading spaces at start of line
    leading_spaces = {
      pattern = "^ +",
      highlight = "LeadingSpace",
      color = { bg = "#9b59b6", fg = "#ffffff" },
      context = {
        line_start = true,
      },
    },
  },
})
```

## Character Examples

- `\u{00A0}` - Non-breakable space (NBSP)
- `\u{202F}` - Narrow non-breakable space
- `\u{2007}` - Figure space
- `\u{200B}` - Zero-width space
- `\u{200C}` - Zero-width non-joiner
- `\u{200D}` - Zero-width joiner
- `\u{FEFF}` - Zero-width no-break space (BOM)
- `\t` - Tab character

## Context Options

Context rules control **where** patterns match:

- `line_start` - Match only at the beginning of line
- `line_end` - Match only at the end of line (excluding trailing whitespace)
- `after_non_whitespace` - Match only after a non-whitespace character
- `word_boundary` - Match only at word boundaries
- `priority` - Set highlight priority (default: 200)

## Pattern Syntax

Uses Lua patterns (not regex):
- `%s` - Any whitespace character
- `%s+` - One or more whitespace
- `  +` - Two or more spaces (literal)
- `^ +` - Spaces at line start
- `[%s]+$` - Whitespace at line end
- See [Lua patterns](https://www.lua.org/manual/5.1/manual.html#5.4.1) for full syntax

## Dynamic API

```lua
local char_highlight = require('char-highlight')

-- Add character set
char_highlight.add_char_set("my_chars", {
  chars = { "•", "·", "‧" },
  highlight = "MyHighlight",
  color = { bg = "#2ecc71", fg = "#ffffff" },
})

-- Add pattern set
char_highlight.add_pattern_set("my_pattern", {
  pattern = "%s+",
  highlight = "MyPatternHighlight",
  color = { bg = "#e67e22", fg = "#ffffff" },
  context = { line_end = true },
})

-- Remove sets
char_highlight.remove_char_set("my_chars")
char_highlight.remove_pattern_set("my_pattern")
```

## Commands

- `:CharHighlightToggle` - Enable/disable highlighting
- `:CharHighlightRefresh` - Refresh all buffers

## Color Options

- `bg` - Background color (hex)
- `fg` - Foreground/text color (hex)
- `bold` - Bold text (boolean)
- `italic` - Italic text (boolean)
- `underline` - Underlined text (boolean)
