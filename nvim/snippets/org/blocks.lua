-- lua/luasnip-orgblocks.lua
local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node
local rep = require("luasnip.extras").rep

---Create a snippet that surrounds visual selection with an Org block.
---@param blocks string[]  -- e.g. { "SRC", "QUOTE", "EXAMPLE", "CENTER", "VERSE", "EXPORT" }
---@param opts table|nil   -- optional: opts.snip_meta to override trig/name/dscr if you want
local function make_org_block_surround(blocks, opts)
  opts = opts or {}
  local choices = {}
  for _, b in ipairs(blocks) do
    -- Use insert-nodes as choices so we can `rep(1)` later.
    table.insert(choices, i(nil, b))
  end

  return s(
    vim.tbl_extend("force", {
      trig = "ob",
      name = "org-block-surround",
      dscr = "Wrap selection in #+BEGIN_/#+END_ block",
    }, opts.snip_meta or {}),
    {
      t("#+BEGIN_"), c(1, choices), t({ "", }),
      -- Insert the visual selection (or an empty line if none was selected).
      f(function(_, snip)
        local sel = snip.env.TM_SELECTED_TEXT
        if not sel or #sel == 0 then
          return { "" }
        end
        return sel -- table of lines
      end, {}),
      t({ "", "#+END_" }), rep(1), t({ "", }),
    }
  )
end

return {
  make_org_block_surround = make_org_block_surround,
}

