-- Returns a snippet_node wrapped around an insertNode whose initial
-- text value is set to the current date in the desired format.
local date_input = function(args, snip, old_state, fmt)
  local fmt = fmt or "%Y-%m-%d"
  return sn(nil, i(1, os.date(fmt)))
end

local LF = function() return t({ '', '' }) end

local function gen_plain_text_title_snippets()
  local function make_line(
      args,
      parent,
      user_args
  )
    vim.schedule_wrap(function() P(args) end)
    --local title = args[1][1]
    --local str_len = vim.fn.strlen(title)
    local line_width = 80
    --local LF() = "\010"
    local char = "-"
    if user_args == "single" then
      char = "-"
    elseif user_args == "double" then
      char = "="
    elseif user_args == "underscore" then
      char = "_"
    end
    local underline = string.rep(char, line_width)
    return underline
  end

  local snippets = {}
  table.insert(snippets,
    s("title", {
      f(make_line, {}, { user_args = { "single" } }),
      LF(),
      t '* ', i(1, "title"),
      LF(),
      f(function() return string.format("[%s]", require 'date_utils'.timestamp_orgmode()) end, { 1 }, {}),
      LF(),
      f(make_line, {}, { user_args = { "single" } }),
      LF(),
      t('  - '), i(0),
      LF(),
      f(make_line, {}, { user_args = { "single" } }),
    }
    )
  )
  return snippets
end

return gen_plain_text_title_snippets()
