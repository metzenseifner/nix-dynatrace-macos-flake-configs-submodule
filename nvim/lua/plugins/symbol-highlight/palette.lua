-- Palette — the colours a pinned symbol can wear, and keeping them alive.
--
-- Algebraic shape:
--
--   colors  : List ColorSpec      -- index i ⟶ highlight group "Hlwords0000i"
--   repaint : () -> ()            -- List ColorSpec -> nvim highlight groups
--
-- The length of `colors` *is* the capacity: hlwords.nvim defines one highlight
-- group per entry and hands out the first free one, so five entries means five
-- symbols can be pinned simultaneously and the sixth attempt reports
-- "No more highlights in stock."
--
-- Plain English: `:colorscheme` clears every highlight group, including the
-- ones hlwords.nvim defined during setup, which would silently blank out every
-- pinned symbol while its matches stay registered. hlwords' own re-definition
-- path (highlight.define) would fix the colours but also re-registers its
-- records, dropping the pins along the way — so we re-apply only the colours.

local M = {}

-- Bright backgrounds with a near-black foreground so a pin stays legible under
-- both light and dark colorschemes.
---@type table[]
M.colors = {
  { fg = '#101010', bg = '#7fdbff', bold = true }, -- 1: cyan
  { fg = '#101010', bg = '#ff8ce0', bold = true }, -- 2: pink
  { fg = '#101010', bg = '#ffd75f', bold = true }, -- 3: amber
  { fg = '#101010', bg = '#87ff87', bold = true }, -- 4: green
  { fg = '#101010', bg = '#ffa07a', bold = true }, -- 5: salmon
}

-- Mirrors hlwords.highlight.define(): <plugin_name> .. "%05d" over the colour
-- index. Resolved lazily so this module stays requireable before hlwords loads.
---@param index integer
---@return string
local function group_name(index)
  return require('hlwords.config').plugin_name .. string.format('%05d', index)
end

function M.repaint()
  for index, color in ipairs(M.colors) do
    vim.api.nvim_set_hl(0, group_name(index), color)
  end
end

function M.keep_across_colorscheme()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('SymbolHighlightPalette', { clear = true }),
    desc = 'Re-apply pinned-symbol colours, which :colorscheme clears.',
    callback = M.repaint,
  })
end

return M
