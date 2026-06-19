local function gen_date_snippets()
  local snippets = {}
  -- Take advantage of the English phrases that the date executable can parse
  local target_dates = {
    "today",
    "tomorrow",
    "next monday",
    "next tuesday",
    "next wednesday",
    "next thursday",
    "next friday",
    "next week",
    "next month",
  }
  for _, target_date in pairs(target_dates) do
    table.insert(
      snippets,
      s(target_date:gsub(" ", "_"), {
        f(function(args, snip, user_arg_1)
          -- Try safe date command if available
          local cmd_result = vim.system({ 'date', '--date', target_date, '+%F' }, { text = true }):wait()
          if cmd_result.code == 0 then
            return vim.trim(cmd_result.stdout)
          else
            vim.notify('date failed, falling back to os.date(): ' .. cmd_result.stderr, vim.log.levels.ERROR)
          end

          -- Fallback to basic Lua os.date
          return os.date("%Y-%m-%d")
        end, {}),
      })
    )
  end

  return snippets
end
return gen_date_snippets()
