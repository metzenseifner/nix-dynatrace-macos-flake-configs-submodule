-- Pinboard — the set of symbols currently wearing a colour, plus the
-- "hide everything / bring everything back" toggle that hlwords.nvim lacks.
--
-- Algebraic shape:
--
--   Pin      = { word : Symbol, pattern : Pattern, group : HighlightGroup }
--   pinboard = (List Pin, Visibility)      where Visibility = Shown | Hidden
--
--   toggle           : Symbol -> ()   -- pin ⊕ unpin
--   conceal          : () -> ()       -- Shown  -> Hidden, List Pin retained
--   reveal           : () -> ()       -- Hidden -> Shown,  same colour per pin
--   toggle_visibility: () -> ()       -- conceal ⊕ reveal
--   drop_all         : () -> ()       -- (List Pin, _) -> ([], Shown)
--
-- Plain English: hlwords.nvim owns the colours and the per-window matches, but
-- it only knows "on" and "off" — clearing a highlight forgets it. We keep each
-- pin's pattern together with the highlight group it was assigned, so hiding is
-- a plain `clear()` and showing again is re-recording those exact pairs. A
-- symbol therefore keeps its colour across any number of hide/show cycles, even
-- if pins were added and removed out of order in between.
--
-- Every mutation goes through this module: it is the authority on what is
-- pinned, so calling require('hlwords') directly would desynchronise it.

local M = {}

---@class Pin
---@field word string
---@field pattern string
---@field group string

---@type Pin[]
local pins = {}

---@type boolean
local hidden = false

-- / Pattern construction
-- -------------------------------------------------------------------------------------------------

-- \< and \> anchor only against 'iskeyword' characters, so they silently fail
-- to match tokens like `--accent-color` or `is_valid?` — exactly the tokens
-- treesitter is good at handing us whole. Word boundaries are therefore worth
-- asking for precisely when the token is made of keyword characters and would
-- otherwise light up inside longer words.
---@param word string
---@return boolean
local function uses_keyword_characters(word)
  return word:match('^[%w_]+$') ~= nil
end

-- hlwords reads `strict_word` from its own config at pattern-build time and
-- offers no per-call override, so we lend it the right answer for this word and
-- hand the option back afterwards.
---@param word string
---@param action fun(): any
---@return any
local function under_boundaries(word, action)
  local config = require('hlwords.config')
  local previous = config.options.strict_word

  config.options.strict_word = uses_keyword_characters(word)
  local ok, result = pcall(action)
  config.options.strict_word = previous

  if not ok then
    error(result, 0)
  end

  return result
end

---@param word string
---@return string
local function pattern_for(word)
  return under_boundaries(word, function()
    return require('hlwords.letters').to_pattern(word)
  end)
end

---@param word string
local function delegate_toggle(word)
  under_boundaries(word, function()
    require('hlwords').toggle(word)
  end)
end

-- The colour hlwords just handed this pattern, or nil when every colour was
-- already in use and the pin did not take.
---@param pattern string
---@return string?
local function assigned_group(pattern)
  local records = require('hlwords.highlight').record_of(pattern)
  return records[1] and records[1].hl_group or nil
end

-- / Pins
-- -------------------------------------------------------------------------------------------------

---@param pattern string
---@return integer?
local function index_of(pattern)
  for position, pin in ipairs(pins) do
    if pin.pattern == pattern then
      return position
    end
  end

  return nil
end

---@param word string
function M.toggle(word)
  if type(word) ~= 'string' or #word == 0 then
    return
  end

  -- Pinning something invisible would look like a broken keymap.
  M.reveal()

  local pattern = pattern_for(word)
  local position = index_of(pattern)

  delegate_toggle(word)

  if position then
    table.remove(pins, position)
    return
  end

  local group = assigned_group(pattern)

  if group then
    table.insert(pins, { word = word, pattern = pattern, group = group })
  end
end

-- / Visibility
-- -------------------------------------------------------------------------------------------------

function M.conceal()
  if hidden or #pins == 0 then
    return
  end

  require('hlwords').clear()
  hidden = true
end

function M.reveal()
  if not hidden then
    return
  end

  hidden = false

  local highlight = require('hlwords.highlight')

  for _, pin in ipairs(pins) do
    highlight.record(pin.group, pin.pattern)
  end

  highlight.propagate()
end

function M.toggle_visibility()
  if #pins == 0 then
    vim.notify('No symbols pinned.', vim.log.levels.INFO)
    return
  end

  if hidden then
    M.reveal()
  else
    M.conceal()
  end
end

function M.drop_all()
  require('hlwords').clear()
  pins = {}
  hidden = false
end

-- / Inspection
-- -------------------------------------------------------------------------------------------------

---@return string[]
function M.words()
  return vim.tbl_map(function(pin)
    return pin.word
  end, pins)
end

return M
