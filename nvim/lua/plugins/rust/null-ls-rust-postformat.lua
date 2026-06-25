-- Custom post-format pass for Rust, applied via none-ls (null-ls).
--
-- Purpose
--   rustfmt (driven by rust_analyzer) treats the token stream inside attribute
--   macros such as `#[tracing::instrument(...)]` as opaque and will not reflow
--   it. There is no stable rustfmt knob for this. This source gives you a
--   pure-Lua hook that runs as a FORMATTING source so you can post-process the
--   buffer text yourself after rustfmt has run.
--
-- Algebraic shape
--   transform : List Line -> List Line          -- your pure edit, defaults to id
--   fn        : Params -> List Edit              -- {} when transform is the identity (true no-op)
--
-- Plain English
--   `transform` takes the current buffer lines and returns the lines you want.
--   By default it returns them unchanged, so this source is a no-op: it emits no
--   edits and never touches your file. Replace the body of `transform` to make
--   it do something (an example trailing-blank-line trim is included below).
--
-- Ordering caveat
--   none-ls runs its own FORMATTING sources in registration order, but the
--   relative order against rust_analyzer's rustfmt inside a single
--   `vim.lsp.buf.format` call is not guaranteed by none-ls alone. The trailing
--   blank-line trim below is order-independent (rustfmt never re-adds trailing
--   blanks), so it is safe regardless. If you extend `transform` into something
--   that IS order-sensitive, format with rust_analyzer first, e.g.:
--     vim.lsp.buf.format({ name = "rust_analyzer" })
--     vim.lsp.buf.format({ name = "null-ls" })

local null_ls = require("null-ls")

---Extension point: pure function from buffer lines to buffer lines.
---Identity by default => no edits are produced (genuine no-op).
---@param lines string[]
---@return string[]
local function transform(lines)
  -- ----------------------------------------------------------------------
  -- EXAMPLE (commented): remove trailing empty lines at end of file.
  -- rustfmt already enforces a single final newline, so this is harmless
  -- and idempotent. Uncomment to enable.
  --
  -- local last = #lines
  -- while last > 1 and lines[last]:match("^%s*$") do
  --   last = last - 1
  -- end
  -- if last < #lines then
  --   local trimmed = {}
  --   for i = 1, last do
  --     trimmed[i] = lines[i]
  --   end
  --   return trimmed
  -- end
  -- ----------------------------------------------------------------------

  return lines
end

---@param a string[]
---@param b string[]
---@return boolean
local function lines_equal(a, b)
  if #a ~= #b then
    return false
  end
  for i = 1, #a do
    if a[i] ~= b[i] then
      return false
    end
  end
  return true
end

return {
  name = "rust_postformat",
  method = null_ls.methods.FORMATTING,
  filetypes = { "rust" },
  generator = {
    fn = function(params)
      local input = params.content -- List Line (buffer split on newlines, no trailing entry)
      local output = transform(vim.deepcopy(input))

      -- True no-op: emit zero edits when nothing changed.
      if lines_equal(input, output) then
        return {}
      end

      -- Whole-buffer replacement. (1,1) .. (#input+1, 1) covers the entire
      -- document including its final newline boundary.
      return {
        {
          row = 1,
          col = 1,
          end_row = #input + 1,
          end_col = 1,
          text = table.concat(output, "\n"),
        },
      }
    end,
  },
}
