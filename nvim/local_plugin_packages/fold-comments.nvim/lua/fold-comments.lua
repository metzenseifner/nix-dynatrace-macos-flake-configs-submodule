-- comment_folds.lua
-- Fold all comment lines in any language, driven by Treesitter captures.
--
-- Install: put this file at  ~/.config/nvim/lua/comment_folds.lua
-- Enable:  require("comment_folds").setup()           -- default <leader>fc
--          require("comment_folds").setup({           -- or customize
--            keymap = "<leader>cf",
--            keep_paragraphs = true,                   -- fold blank lines
--          })                                          --   between comments too
--
-- Use:     :ToggleCommentFolds  (or your keymap) to fold/unfold comments.
--          Toggling off restores whatever fold settings you had before.

local M = {}

-- Treesitter parses on demand, so no highlighter needs to be active. We ask the
-- syntax tree for the node at the first non-blank char and check its type. This
-- works without an active highlighter (get_captures_at_pos does not), and node
-- types like "line_comment", "block_comment", "comment", "doc_comment" all
-- contain "comment".
local function line_is_comment(lnum)
  local line = vim.fn.getline(lnum)
  local first = line:find("%S")
  if not first then
    return false -- blank line
  end

  local ok, parser = pcall(vim.treesitter.get_parser, 0)
  if not ok or not parser then
    return false -- no parser for this buffer
  end
  -- get_node returns nil against a stale/unparsed tree, so force a parse first.
  -- parse() is incremental, so repeated calls across lines are cheap.
  parser:parse()

  local node = vim.treesitter.get_node({ bufnr = 0, pos = { lnum - 1, first - 1 } })
  if not node then
    return false
  end

  return node:type():find("comment", 1, true) ~= nil
end

-- foldexpr entry point. Returns "1" for comment lines, "0" otherwise.
-- Contiguous comment lines collapse into a single fold.
function M.foldexpr()
  local lnum = vim.v.lnum
  if vim.fn.getline(lnum):match("^%s*$") then
    -- Blank line: either break the fold, or inherit the previous line's
    -- level ("=") so multi-paragraph comment blocks stay together.
    return M.keep_paragraphs and "=" or "0"
  end
  return line_is_comment(lnum) and "1" or "0"
end

-- A closed comment fold renders as one screen line. Returning an empty string
-- (combined with a space fold fillchar, set in toggle) makes that line blank, so
-- folded comments effectively vanish instead of showing a "+-- N lines" summary.
function M.foldtext()
  return ""
end

-- Toggle comment folding for the current window, preserving prior fold state.
function M.toggle()
  if vim.w.comment_folds_on then
    vim.wo.foldmethod = vim.w.cf_saved_method or "manual"
    vim.wo.foldexpr = vim.w.cf_saved_expr or "0"
    vim.wo.foldtext = vim.w.cf_saved_foldtext or ""
    vim.wo.foldminlines = vim.w.cf_saved_minlines or 1
    vim.wo.fillchars = vim.w.cf_saved_fillchars or ""
    vim.w.comment_folds_on = false
    vim.cmd("normal! zR") -- open everything
  else
    vim.w.cf_saved_method = vim.wo.foldmethod
    vim.w.cf_saved_expr = vim.wo.foldexpr
    vim.w.cf_saved_foldtext = vim.wo.foldtext
    vim.w.cf_saved_minlines = vim.wo.foldminlines
    vim.w.cf_saved_fillchars = vim.wo.fillchars
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.require'fold-comments'.foldexpr()"
    vim.wo.foldtext = "v:lua.require'fold-comments'.foldtext()"
    vim.wo.foldminlines = 0 -- so even single-line comments collapse
    vim.opt_local.fillchars:append({ fold = " " }) -- blank out the folded line
    vim.w.comment_folds_on = true
    vim.cmd("normal! zM") -- close all comment folds
  end
end

function M.setup(opts)
  opts = opts or {}
  M.keep_paragraphs = opts.keep_paragraphs or false

  vim.api.nvim_create_user_command("ToggleCommentFolds", M.toggle, {
    desc = "Toggle folding of comment lines",
  })

  local key = opts.keymap == nil and "<leader>fc" or opts.keymap
  if key then
    vim.keymap.set("n", key, M.toggle, { desc = "Toggle comment folds" })
  end
end

return M
