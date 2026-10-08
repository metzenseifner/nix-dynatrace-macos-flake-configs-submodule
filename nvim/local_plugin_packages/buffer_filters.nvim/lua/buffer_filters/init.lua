-- buffer_filters.nvim
-- A Telescope picker for running filters over the current buffer.
--
-- A filter is any table that turns the buffer's lines into new lines. There are
-- two kinds:
--
--   shell : has a `command` string. The buffer is piped through it on standard
--           input, and standard output replaces the buffer.
--   lua   : has an `apply` function. It receives a copy of the buffer's lines as
--           a table and returns either a table of lines or a single string.
--
-- Both kinds share the same live preview and the same apply path.
local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

-------------------------------------------------------------------------------
-- Built-in filters
--------------------------------------------------------------------------------

local default_filters = {
  {
    name = "JQ: Flatten records with ::",
    command = "jq -r '.records[] | [.[]] | join(\"::\")'",
    description = "Extracts records and flattens to :: separated lines",
    ft = "text",
  },
  {
    name = "JQ: Extract IDs",
    command = "jq -r '.[] | .id'",
    description = "Extract only the id field from each object",
    ft = "text",
  },
  {
    name = "JQ: Pretty print",
    command = "jq .",
    description = "Format JSON with indentation",
    ft = "json",
  },
  {
    name = "JQ: Compact output",
    command = "jq -c .",
    description = "Compact JSON (one line per object)",
    ft = "json",
  },
  {
    name = "JQ: Extract keys",
    command = "jq -r 'keys[]'",
    description = "List all keys in the JSON object",
    ft = "text",
  },
  {
    name = "JQ: Flatten all fields with ::",
    command = "jq -r '.[] | [.[]] | join(\"::\")'",
    description = "Flatten each object's values to :: separated format",
    ft = "text",
  },
  {
    name = "JQ: To CSV",
    command = "jq -r '.[] | [.[]] | @csv'",
    description = "Convert to CSV format",
    ft = "csv",
  },
  {
    name = "JQ: To TSV",
    command = "jq -r '.[] | [.[]] | @tsv'",
    description = "Convert to TSV format",
    ft = "tsv",
  },
  {
    name = "JQ: Extract timestamps",
    command = "jq -r '.[] | .timestamp'",
    description = "Extract only timestamp fields",
    ft = "text",
  },
  {
    name = "JQ: Count items",
    command = "jq 'length'",
    description = "Count number of items in array/object",
    ft = "text",
  },
  {
    name = "JQ: Select by field value",
    command = "jq '.[] | select(.status == \"active\")'",
    description = "Filter objects by field value (example: status)",
    ft = "json",
  },
  {
    name = "JQ: Group by field",
    command = "jq 'group_by(.deployment.release_environment)'",
    description = "Group objects by a specific field",
    ft = "json",
  },
  {
    name = "YQ: Flatten with ::",
    command = "yq -r '.[] | [.[]] | join(\"::\")'",
    description = "YQ version of flatten with ::",
    ft = "text",
  },
  {
    name = "YQ: Pretty print",
    command = "yq .",
    description = "Format YAML/JSON with yq",
    ft = "yaml",
  },
  {
    name = "Text: Trim trailing whitespace",
    description = "Removes spaces and tabs at the end of every line",
    apply = function(lines)
      local trimmed = {}
      for index, line in ipairs(lines) do
        trimmed[index] = line:gsub("%s+$", "")
      end
      return trimmed
    end,
  },
}

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

M.filters = {}

-- Turns a user-supplied table into the internal shape, or returns nil plus a
-- message explaining what is wrong with it.
local function normalize_filter(filter)
  if type(filter) ~= "table" then
    return nil, "a filter must be a table, got " .. type(filter)
  end

  if type(filter.name) ~= "string" or filter.name == "" then
    return nil, "a filter must have a non-empty name"
  end

  local kind
  if type(filter.command) == "string" then
    kind = "shell"
  elseif type(filter.apply) == "function" then
    kind = "lua"
  else
    return nil, string.format(
      "filter %q must have either a command string or an apply function",
      filter.name
    )
  end

  return {
    name = filter.name,
    description = filter.description or "Custom filter",
    ft = filter.ft or "text",
    command = filter.command,
    apply = filter.apply,
    kind = kind,
  }
end

-- Registers a filter. Accepts either the table form:
--
--   add_filter({ name = "...", apply = function(lines) ... end })
--
-- or the older positional form kept for backward compatibility:
--
--   add_filter(name, command, description, ft)
function M.add_filter(filter_or_name, command, description, ft)
  local candidate = filter_or_name

  if type(filter_or_name) == "string" then
    candidate = {
      name = filter_or_name,
      command = command,
      description = description,
      ft = ft,
    }
  end

  local normalized, err = normalize_filter(candidate)
  if not normalized then
    vim.notify("buffer_filters: " .. err, vim.log.levels.ERROR)
    return false
  end

  table.insert(M.filters, normalized)
  return true
end

-- Registers the built-in filters plus anything the user passes in.
--
--   require("buffer_filters").setup({
--     use_defaults = true,       -- set to false to keep only your own filters
--     filters = { ... },
--   })
function M.setup(opts)
  opts = opts or {}

  M.filters = {}

  if opts.use_defaults ~= false then
    for _, filter in ipairs(default_filters) do
      M.add_filter(filter)
    end
  end

  for _, filter in ipairs(opts.filters or {}) do
    M.add_filter(filter)
  end
end

-- Register the defaults immediately so the picker still works if setup is never
-- called. Calling setup afterwards replaces this list rather than appending.
M.setup()

--------------------------------------------------------------------------------
-- Running filters
--------------------------------------------------------------------------------

-- Runs a filter over a table of lines and returns the resulting lines, or nil
-- plus an error message. This never touches a buffer, which is what lets the
-- previewer and the apply path share it.
local function run_filter(filter, lines)
  if filter.kind == "lua" then
    local ok, result = pcall(filter.apply, vim.deepcopy(lines))

    if not ok then
      return nil, tostring(result)
    end

    if type(result) == "string" then
      result = vim.split(result, "\n", { plain = true })
    end

    if type(result) ~= "table" then
      return nil, "the apply function must return a table of lines or a string"
    end

    return result
  end

  local output = vim.fn.system(filter.command, table.concat(lines, "\n"))
  local shell_error = vim.v.shell_error

  if shell_error ~= 0 then
    return nil, output
  end

  local result = vim.split(output, "\n", { plain = true })
  if result[#result] == "" then
    table.remove(result)
  end

  return result
end

-- Applies a filter to the current buffer. Accepts a filter table, or a bare
-- command string for backward compatibility.
function M.apply_filter(filter)
  if type(filter) == "string" then
    filter = { name = filter, command = filter, kind = "shell", description = "" }
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cursor = vim.api.nvim_win_get_cursor(0)

  local result, err = run_filter(filter, lines)

  if not result then
    vim.notify("Filter error: " .. err, vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result)

  -- Put the cursor back, clamped to the new number of lines.
  local last_line = vim.api.nvim_buf_line_count(bufnr)
  pcall(vim.api.nvim_win_set_cursor, 0, { math.min(cursor[1], last_line), cursor[2] })

  vim.notify("Filter applied: " .. filter.name, vim.log.levels.INFO)
end

-- Only meaningful for shell filters, since a Lua function has no command line
-- representation.
function M.edit_filter_in_cmdline(filter)
  if filter.kind ~= "shell" then
    vim.notify(
      "This filter is a Lua function, so there is no command to edit",
      vim.log.levels.WARN
    )
    return
  end

  vim.fn.feedkeys(":%!" .. filter.command, "n")
end

local function command_label(filter)
  if filter.kind == "shell" then
    return ":%!" .. filter.command
  end
  return "<lua function>"
end

--------------------------------------------------------------------------------
-- Previewer
--------------------------------------------------------------------------------

local function create_filter_previewer(original_lines)
  return previewers.new_buffer_previewer({
    title = "Filter Preview (Live)",
    define_preview = function(self, entry, _)
      local filter = entry.value
      local result, err = run_filter(filter, original_lines)

      local preview_lines = {}
      local highlights = {}

      local function add(line, group)
        table.insert(preview_lines, line)
        if group then
          table.insert(highlights, { group = group, line = #preview_lines - 1 })
        end
      end

      local rule = "╠════════════════════════════════════════════════════════════"

      add("╔════════════════════════════════════════════════════════════", "Comment")
      add("║ COMMAND TO EXECUTE:", "Comment")
      add(rule, "Comment")
      add("║ " .. command_label(filter), "String")
      add(rule, "Comment")
      add("║ DESCRIPTION:", "Comment")
      add(rule, "Comment")
      add("║ " .. filter.description, "Comment")
      add(rule, "Comment")
      add("║ ACTIONS:", "Comment")
      add(rule, "Comment")
      add("║ <CR>    : Apply filter to buffer", "Comment")
      add("║ <C-e>   : Edit command in command line (shell filters only)", "Comment")
      add("║ <C-y>   : Yank command to clipboard (shell filters only)", "Comment")
      add("║ ?       : Show help", "Comment")
      add("╚════════════════════════════════════════════════════════════", "Comment")
      add("")
      add("▼ PREVIEW OUTPUT ▼", "Title")
      add("")

      if not result then
        add("❌ ERROR:", "ErrorMsg")
        add("")
        for _, line in ipairs(vim.split(err, "\n", { plain = true })) do
          add("  " .. line)
        end
      else
        local num_lines = #result
        add("✓ Success - " .. num_lines .. " lines", "String")
        add("")

        local max_preview_lines = 100
        for i, line in ipairs(result) do
          if i > max_preview_lines then
            add("")
            add("... (" .. (num_lines - max_preview_lines) .. " more lines)")
            break
          end
          add(string.format("%4d │ %s", i, line))
        end
      end

      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
      vim.bo[self.state.bufnr].filetype = "text"

      local ns_id = vim.api.nvim_create_namespace("buffer_filters_preview")
      vim.api.nvim_buf_clear_namespace(self.state.bufnr, ns_id, 0, -1)

      for _, hl in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(self.state.bufnr, ns_id, hl.group, hl.line, 0, -1)
      end
    end,
  })
end

--------------------------------------------------------------------------------
-- Picker
--------------------------------------------------------------------------------

local help_text = [[
Buffer Filters Help:

<CR>    - Apply filter to current buffer
<C-e>   - Edit command in command line (shell filters only)
<C-y>   - Yank command to clipboard (shell filters only)
<C-c>   - Cancel/Close picker
?       - Show this help

The preview shows:
1. The exact command or function that will be run
2. Description of what the filter does
3. Live preview of the output
4. Line count and error messages if any
]]

function M.show_picker(opts)
  opts = opts or {}

  local original_bufnr = vim.api.nvim_get_current_buf()
  local original_lines = vim.api.nvim_buf_get_lines(original_bufnr, 0, -1, false)

  -- Optionally show only the filters that suit this buffer's filetype.
  local available = M.filters
  if opts.match_filetype then
    local buffer_ft = vim.bo[original_bufnr].filetype
    available = vim.tbl_filter(function(filter)
      return filter.ft == buffer_ft or filter.ft == "text"
    end, M.filters)
  end

  if #available == 0 then
    vim.notify("buffer_filters: no filters registered", vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = "🔍 Buffer Filters (Type to search)",
    results_title = "Available Filters",
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.95,
      height = 0.90,
      preview_width = 0.65,
    },
    finder = finders.new_table({
      results = available,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name .. " " .. entry.description .. " " .. (entry.command or "lua"),
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = create_filter_previewer(original_lines),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        vim.api.nvim_set_current_buf(original_bufnr)
        M.apply_filter(selection.value)
      end)

      local function edit_in_cmdline()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        M.edit_filter_in_cmdline(selection.value)
      end

      local function yank_command()
        local selection = action_state.get_selected_entry()
        local filter = selection.value

        if filter.kind ~= "shell" then
          vim.notify("This filter is a Lua function, so there is nothing to yank", vim.log.levels.WARN)
          return
        end

        vim.fn.setreg("+", ":%!" .. filter.command)
        vim.notify("Command copied to clipboard: :%!" .. filter.command, vim.log.levels.INFO)
      end

      local function show_help()
        vim.notify(help_text, vim.log.levels.INFO)
      end

      for _, mode in ipairs({ "i", "n" }) do
        map(mode, "<C-e>", edit_in_cmdline)
        map(mode, "<C-y>", yank_command)
        map(mode, "?", show_help)
      end

      return true
    end,
  }):find()
end

return M
