M = {}
M.cache = {}

M.private_fn_ranges = function(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "rust")
  if not ok or not parser then return {} end
  local root = parser:parse()[1]:root()
  local query = vim.treesitter.query.parse("rust", "(function_item) @fn")
  local ranges = {}
  for _, node in query:iter_captures(root, buf, 0, -1) do
    local is_pub = false
    for child in node:iter_children() do
      if child:type() == "visibility_modifier" then is_pub = true
        break
      end
    end
    if not is_pub then
      local srow, _, erow = node:range()
      ranges[#ranges + 1] = { srow + 1, erow + 1 } -- 1-indexed
    end
  end
  return ranges
end

M.configure_folds = function()
  function _G.rust_private_foldexpr()
    local buf = vim.api.nvim_get_current_buf()
    local tick = vim.b[buf].changedtick
    local c = M.cache[buf]
    if not c or c.tick ~= tick then
      c = { tick = tick, ranges = M.private_fn_ranges(buf) }
      M.cache[buf] = c
    end
    local lnum, level = vim.v.lnum, 0
    for _, r in ipairs(c.ranges) do
      if lnum >= r[1] and lnum <= r[2] then level = level + 1 end
    end
    return tostring(level)
  end

  vim.opt_local.foldmethod = "expr"
  vim.opt_local.foldexpr = "v:lua.rust_private_foldexpr()"
  vim.opt_local.foldlevel = 0 -- start with private fns folded
end
