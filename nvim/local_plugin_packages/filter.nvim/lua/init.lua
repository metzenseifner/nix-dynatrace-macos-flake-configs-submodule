-- Usage Examples
-- local filter = require("filter")
-- 
-- -- Whole buffer examples
-- filter.map_buffer("<leader>s", "sort", { desc = "Sort entire buffer" })
-- filter.map_buffer("<leader>fmt", "fmt -w 80", { desc = "Wrap text at 80 columns" })
-- 
-- -- Visual selection examples
-- filter.map_visual("<leader>jq", "jq .", { desc = "Pretty-print JSON via jq" })
-- filter.map_visual("<leader>sed", [[sed 's/foo/bar/g']], { desc = "Replace foo->bar via sed" })
--
--
--local filter = require("filter")
--
-- local function my_error_handler(ctx)
--   -- You get ctx: {scope, cmd, buf, input, stdout, stderr, exit_code, range?}
--   vim.notify(
--     ("Oops! '%s' failed (exit %d)."):format(ctx.cmd, ctx.exit_code),
--     vim.log.levels.ERROR
--   )
-- end
-- 
-- local function my_success_handler(ctx)
--   -- Example: info toast with how many lines were written
--   local n = ctx.new_lines and #ctx.new_lines or 0
--   vim.notify(("Filtered via '%s' (%d lines updated)"):format(ctx.cmd, n))
-- end
-- 
-- -- Whole buffer: sort
-- filter.map_buffer("<leader>s", "sort", {
--   desc = "Sort entire buffer",
--   on_error = my_error_handler,
--   on_success = my_success_handler,
-- })
-- 
-- -- Visual: pretty-print JSON via jq
-- filter.map_visual("<leader>jq", "jq .", {
--   desc = "Pretty-print selection via jq",
--   on_error = function(ctx)
--     vim.notify("jq failed – is your selection valid JSON?", vim.log.levels.ERROR)
--   end,
-- })
--
--
--
-- lua/filter.lua
local M = {}

-- Normalize newlines (handles \r\n and \r)
local function normalize_newlines(s)
  s = s:gsub("\r\n", "\n")
  s = s:gsub("\r", "\n")
  return s
end

-- Split output into buffer-ready lines and drop trailing empty line
local function to_lines(s)
  s = normalize_newlines(s)
  local lines = vim.split(s, "\n", { plain = true })
  if #lines > 0 and lines[#lines] == "" then
    table.remove(lines, #lines)
  end
  return lines
end

-- Default runner (sync). You can override via M.set_runner().
local function default_runner(cmd, input)
  local stdout = vim.fn.system(cmd, input or "")
  local code = vim.v.shell_error
  return {
    ok = (code == 0),
    stdout = stdout,
    stderr = nil,     -- not available via system(); keep for uniform ctx
    exit_code = code,
  }
end

M._runner = default_runner
function M.set_runner(runner)
  -- runner(cmd, input) -> { ok=bool, stdout=string, stderr=string|nil, exit_code=int }
  M._runner = runner or default_runner
end

local function safe_call(handler, ctx)
  if type(handler) ~= "function" then return end
  local ok, err = pcall(handler, ctx)
  if not ok then
    vim.notify(("Error handler threw: %s"):format(err), vim.log.levels.ERROR)
  end
end

local function ensure_opts(opts)
  opts = opts or {}
  if opts.on_error == nil then
    opts.on_error = function(ctx)
      local msg = ("Command failed: %s\nExit code: %d\n%s")
        :format(ctx.cmd, ctx.exit_code or -1, ctx.stderr or ctx.stdout or "")
      vim.notify(msg, vim.log.levels.ERROR)
    end
  end
  -- opts.on_success is optional
  return opts
end

-- Filter entire buffer through external command
function M.filter_buffer(cmd, opts)
  opts = ensure_opts(opts)
  local buf = (opts and opts.buf) or 0

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local input = table.concat(lines, "\n")

  local res = M._runner(cmd, input)
  local ctx = {
    scope = "buffer",
    cmd = cmd,
    buf = buf,
    input = input,
    stdout = res.stdout,
    stderr = res.stderr,
    exit_code = res.exit_code,
  }

  if not res.ok then
    safe_call(opts.on_error, ctx)
    return false, res.stdout
  end

  local new_lines = to_lines(res.stdout)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)

  ctx.new_lines = new_lines
  safe_call(opts.on_success, ctx)

  return true, res.stdout
end

-- Filter current visual selection through external command
function M.filter_visual(cmd, opts)
  opts = ensure_opts(opts)
  local buf = (opts and opts.buf) or 0

  local srow, scol = unpack(vim.api.nvim_buf_get_mark(buf, "<"))
  local erow, ecol = unpack(vim.api.nvim_buf_get_mark(buf, ">"))
  local mode = vim.fn.visualmode() -- "v" charwise, "V" linewise, or block-wise

  srow = srow - 1
  erow = erow - 1

  local input
  local replace_fn
  local range_ctx

  if mode == "V" then
    -- Linewise selection
    local sel_lines = vim.api.nvim_buf_get_lines(buf, srow, erow + 1, false)
    input = table.concat(sel_lines, "\n")
    replace_fn = function(new_lines)
      vim.api.nvim_buf_set_lines(buf, srow, erow + 1, false, new_lines)
    end
    range_ctx = { srow = srow, erow = erow, linewise = true }
  else
    -- Charwise (treat block-wise simply as charwise)
    local sel_text = vim.api.nvim_buf_get_text(buf, srow, scol, erow, ecol, {})
    input = table.concat(sel_text, "\n")
    replace_fn = function(new_lines)
      vim.api.nvim_buf_set_text(buf, srow, scol, erow, ecol, new_lines)
    end
    range_ctx = { srow = srow, scol = scol, erow = erow, ecol = ecol, linewise = false }
  end

  local res = M._runner(cmd, input)
  local ctx = {
    scope = "visual",
    cmd = cmd,
    buf = buf,
    input = input,
    stdout = res.stdout,
    stderr = res.stderr,
    exit_code = res.exit_code,
    range = range_ctx,
  }

  if not res.ok then
    safe_call(opts.on_error, ctx)
    return false, res.stdout
  end

  local new_lines = to_lines(res.stdout)
  replace_fn(new_lines)

  ctx.new_lines = new_lines
  safe_call(opts.on_success, ctx)

  return true, res.stdout
end

-- Convenience mappers
function M.map_buffer(lhs, cmd, opts)
  opts = opts or {}
  local desc = opts.desc or ("Filter buffer through: " .. cmd)
  vim.keymap.set("n", lhs, function() M.filter_buffer(cmd, opts) end, { desc = desc })
end

function M.map_visual(lhs, cmd, opts)
  opts = opts or {}
  local desc = opts.desc or ("Filter selection through: " .. cmd)
  vim.keymap.set("x", lhs, function() M.filter_visual(cmd, opts) end, { desc = desc })
end

