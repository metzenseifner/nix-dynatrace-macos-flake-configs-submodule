-- Bullet Journal styled dates in the future
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
      s("due_" .. target_date:gsub(" ", "_"), {
        t "# ", -- useful for Markdown
        f(function(args, snip, user_arg_1)
          -- Try safe date command if available
          local portable_ok, portable = pcall(require, 'config.portable')
          if portable_ok then
            local result = portable.safe_date_cmd('%F %a', 'date_snippet')
            if result ~= "" then
              return result
            end
          end
          
          -- Fallback to basic Lua os.date
          return os.date("%Y-%m-%d %a")
        end, {}),
      })
    )
  end

  return snippets
end

local function gen_sprint_snippets()
  local base_sprint_date = '2022-03-24 00:02:00 CET'
  local base_sprint = 264

  -- Overwrite base_sprint_date with equivalent in seconds
  base_sprint_date = vim.fn.trim(vim.fn.system([[date -d ']] .. base_sprint_date .. [[' +%s]]))
  local now_date = vim.fn.trim(vim.fn.system([[date -d 'now' +%s]]))

  local weeks_since_base = days(now_date - base_sprint_date) % 7

  local function is_even(value)
    return value % 2 == 0
  end

  if (is_even(weeks_since_base % 2)) then
    -- This week started a sprint, so take this week's Thursday as start date
    local current_sprint_start_date = vim.fn.trim(vim.fn.system([[date -d 'this thursdays' +%s]]))
  else
    -- This week is mid-sprint so take previous week's Thursday as start date
    local current_sprint_start_date = vim.fn.trim(vim.fn.system([[date -d 'last thursday' +%s]]))
  end

  local current_sprint = 0


  -- (sprint_base) - (now)
  local current_sprint_seconds = vim.fn.trim(vim.fn.system([[]]))

  local next_thursday_in_seconds = vim.fn.trim(vim.fn.system([[date -d 'next thursday' +%s]]))

  -- If next Thursday's week number since the sprint base is odd, then it is mid-sprint. else it is upcoming sprint.

  local snippets = {}
  local target_dates = {

  }
end

return gen_date_snippets()
