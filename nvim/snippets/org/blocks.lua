-- Org blocks nearly all share the `#+begin_X … #+end_X` shape, so a single
-- higher-order constructor covers them. Adding a block is genuinely one line:

local ls = require("luasnip")
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local factory = require("block_factory")

-- Higher-order constructor for the BEGIN/END family. The factory wraps these
-- in `#+begin_`/`#+end_`, so a head only describes what follows the opener.
-- opts.arg = true gives the opener an inline argument (e.g. src language).
local function org_block(name, opts)
  opts = opts or {}
  return function()
    if opts.arg then
      return sn(nil, fmt(name .. " {arg}", { arg = i(1, opts.arg_default or "") }))
    end
    return t(name)
  end
end

local blocks = {
  { label = "src",     head = org_block("src", { arg = true }) },
  { label = "quote",   head = org_block("quote") },
  { label = "example", head = org_block("example") },
  { label = "verse",   head = org_block("verse") },
  { label = "center",  head = org_block("center") },
}

return { factory.block_snippets("block", blocks) }


-- -- lua/luasnip-orgblocks.lua
-- local ls = require("luasnip")
-- local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node
-- local rep = require("luasnip.extras").rep
--
-- ---Create a snippet that surrounds visual selection with an Org block.
-- ---@param blocks string[]  -- e.g. { "SRC", "QUOTE", "EXAMPLE", "CENTER", "VERSE", "EXPORT" }
-- ---@param opts table|nil   -- optional: opts.snip_meta to override trig/name/dscr if you want
-- local function make_org_block_surround(blocks, opts)
--   opts = opts or {}
--   local choices = {}
--   for _, b in ipairs(blocks) do
--     -- Use insert-nodes as choices so we can `rep(1)` later.
--     table.insert(choices, i(nil, b))
--   end
--
--   return s(
--     vim.tbl_extend("force", {
--       trig = "ob",
--       name = "org-block-surround",
--       dscr = "Wrap selection in #+BEGIN_/#+END_ block",
--     }, opts.snip_meta or {}),
--     {
--       t("#+BEGIN_"), c(1, choices), t({ "", }),
--       -- Insert the visual selection (or an empty line if none was selected).
--       f(function(_, snip)
--         local sel = snip.env.TM_SELECTED_TEXT
--         if not sel or #sel == 0 then
--           return { "" }
--         end
--         return sel -- table of lines
--       end, {}),
--       t({ "", "#+END_" }), rep(1), t({ "", }),
--     }
--   )
-- end
--
-- /143   block.lua
--
--
--
-- return {
--   make_org_block_surround = make_org_block_surround,
-- }
