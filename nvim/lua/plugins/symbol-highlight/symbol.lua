-- Symbol resolution — "which token is under the cursor?"
--
-- Algebraic shape:
--
--   at_cursor : () -> Symbol            where Symbol = string
--   at_cursor = from_treesitter ⊕ from_cword     (⊕ = first success wins)
--
-- Plain English: ask treesitter for the smallest named node at the cursor and
-- take its text whenever that node is an identifier-like token. Treesitter
-- knows each language's real token boundaries, so `--accent-color` (css),
-- `is_valid?` (ruby), `r#type` (rust) and `sym_lit` forms like `my.ns/sym`
-- (clojure) come back whole, where Vim's <cword> cuts them at the nearest
-- 'iskeyword' edge. When there is no parser for the buffer, or the cursor is
-- not sitting on an identifier, fall back to <cword> so the mapping is never a
-- silent no-op.

local M = {}

-- Grammars that do not spell the word "identifier" in their node type names.
-- The substring test below already covers identifier / type_identifier /
-- field_identifier / property_identifier / statement_identifier / ...
local IDENTIFIER_ALIASES = {
  attribute_name = true, -- html, xml
  class_name = true,     -- css
  constructor = true,    -- haskell
  id_name = true,        -- css
  key = true,            -- assorted config grammars
  name = true,           -- php, xml
  operator = true,       -- haskell
  plain_value = true,    -- css
  property_name = true,  -- css
  sym_lit = true,        -- clojure
  symbol = true,         -- scheme, lisp
  tag_name = true,       -- html, xml
  variable = true,       -- haskell
  variable_name = true,  -- bash
  word = true,           -- bash
}

---@param node TSNode
---@return boolean
local function is_identifier(node)
  local node_type = node:type()
  return node_type:find('identifier', 1, true) ~= nil or IDENTIFIER_ALIASES[node_type] == true
end

-- A token is a single run of non-blank text. Whitespace in the node text means
-- we grabbed a container node rather than a leaf, and a highlight pattern built
-- from that would be noise.
---@param text string?
---@return boolean
local function is_token(text)
  return type(text) == 'string' and #text > 0 and text:find('%s') == nil
end

---@return string?
local function from_treesitter()
  local parsed, node = pcall(vim.treesitter.get_node)

  if not parsed or not node or not is_identifier(node) then
    return nil
  end

  local extracted, text = pcall(vim.treesitter.get_node_text, node, 0)

  if not extracted or not is_token(text) then
    return nil
  end

  return text
end

---@return string
local function from_cword()
  return vim.fn.expand('<cword>')
end

---@return string
function M.at_cursor()
  return from_treesitter() or from_cword()
end

return M
