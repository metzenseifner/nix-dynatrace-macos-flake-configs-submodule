-- Symbol highlighting — pin a symbol to a colour, see every occurrence of it.
--
-- Engine: AT-AT/hlwords.nvim. It registers one highlight group per configured
-- colour and drives per-window matchadd() against a Very Nomagic (\V) pattern,
-- so a pin survives buffer switches and window splits.
--
-- Composition:
--
--   symbol.at_cursor : () -> Symbol          treesitter decides token boundaries
--   pinboard.toggle  : Symbol -> ()          pin ⊕ unpin, tracked
--   pinboard.toggle_visibility : () -> ()    hide all ⊕ show all, colours kept
--   palette.colors   : List ColorSpec        length = how many pins fit at once
--
-- Plain English: hlwords on its own highlights whatever <cword> happens to
-- return and can only clear highlights, not park them. The three sibling
-- modules add the two pieces this workflow needs — treesitter-accurate symbol
-- extraction, and a hide/show toggle that remembers which colour each symbol
-- had.
--
-- Keys:
--   <C-h>       (n) toggle the symbol under the cursor
--   <C-h>       (x) toggle the visual selection
--   <leader>hh      hide every pin / bring them all back, same colours
--   <leader>hd      drop the pinboard entirely
--
-- Note: matches are pattern-based and window-scoped, so a pinned symbol also
-- lights up in other buffers where the same text occurs.

local palette = require('plugins.symbol-highlight.palette')

local function pinboard()
  return require('plugins.symbol-highlight.pinboard')
end

local function toggle_symbol_under_cursor()
  pinboard().toggle(require('plugins.symbol-highlight.symbol').at_cursor())
end

-- hlwords' own extractor is the only thing that reads a visual selection with
-- the escaping its patterns expect, so we borrow it and route the result
-- through the pinboard to keep the hide/show list authoritative.
local function toggle_visual_selection()
  pinboard().toggle(require('hlwords.letters').retrieve())
end

return {
  'AT-AT/hlwords.nvim',

  keys = {
    {
      '<C-h>',
      toggle_symbol_under_cursor,
      mode = 'n',
      desc = 'Symbol highlight: toggle a colour on the symbol under the cursor',
    },
    {
      '<C-h>',
      toggle_visual_selection,
      mode = 'x',
      desc = 'Symbol highlight: toggle a colour on the selection',
    },
    {
      '<leader>hh',
      function() pinboard().toggle_visibility() end,
      mode = 'n',
      desc = 'Symbol highlight: hide all pinned symbols / bring them back',
    },
    {
      '<leader>hd',
      function() pinboard().drop_all() end,
      mode = 'n',
      desc = 'Symbol highlight: drop all pinned symbols',
    },
  },

  opts = {
    colors = palette.colors,
    -- Deterministic slot assignment: the first free colour, never a random one,
    -- so pins come out in palette order.
    random = false,
    -- Overridden per word by the pinboard; see uses_keyword_characters there.
    strict_word = true,
    highlight_priority = 10,
  },

  config = function(_, opts)
    require('hlwords').setup(opts)
    palette.keep_across_colorscheme()
  end,
}
