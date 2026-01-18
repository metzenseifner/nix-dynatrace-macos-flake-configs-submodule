return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/char-highlight.nvim",
  event = "VeryLazy",
  config = function()
    local char_highlight = require('char-highlight')

    char_highlight.setup({
      -- Character-based matching (exact characters)
      char_sets = {
        nbsp = {
          chars = { "\u{00A0}", "\u{202F}", "\u{2007}" },
          highlight = "CharHighlightNBSP",
          color = { bg = "#ff6b6b", fg = "#ffffff" },
        },
        zero_width = {
          chars = { "\u{200B}", "\u{200C}", "\u{200D}", "\u{FEFF}" },
          highlight = "CharHighlightZeroWidth",
          color = { bg = "#ffd93d", fg = "#000000" },
        },
        reverse_char = {
          chars = { "\u{202E}" },
          highlight = "CharHighlightReverse",
          color = { bg = '#800080', fg = "#000000" }
        }
      },
      
      -- Pattern-based matching (with context rules)
      pattern_sets = {
        trailing_space = {
          pattern = "%s+",  -- One or more whitespace characters
          highlight = "CharHighlightTrailingSpace",
          color = { bg = "#e74c3c", fg = "#ffffff" },
          context = {
            line_end = true,  -- Only match at end of line
          },
        },
        -- Example: Multiple spaces (not at line start)
        -- multiple_spaces = {
        --   pattern = "  +",  -- Two or more spaces
        --   highlight = "CharHighlightMultiSpace",
        --   color = { bg = "#3498db", fg = "#ffffff" },
        --   context = {
        --     after_non_whitespace = true,  -- Only after non-whitespace
        --   },
        -- },
      },
    })
  end
}
