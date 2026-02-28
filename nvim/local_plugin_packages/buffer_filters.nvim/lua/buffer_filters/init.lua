-- ~/.config/nvim/lua/buffer-filters.lua
local M = {}

M.setup = function()
  -- for compatibility
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

M.filters = {
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
}

local function get_buffer_content()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return table.concat(lines, "\n")
end

function M.apply_filter(filter_command)
  local content = get_buffer_content()
  local result = vim.fn.system(filter_command, content)

  if vim.v.shell_error ~= 0 then
    vim.notify("Filter error: " .. result, vim.log.levels.ERROR)
    return
  end

  local result_lines = vim.split(result, "\n", { plain = true })

  if result_lines[#result_lines] == "" then
    table.remove(result_lines)
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, result_lines)
  vim.notify("Filter applied: " .. filter_command, vim.log.levels.INFO)
end

-- Function to edit filter in command line
function M.edit_filter_in_cmdline(filter_command)
  -- Set the command in the command line with cursor at the end
  vim.fn.feedkeys(":%!" .. filter_command, "n")
end

local function create_filter_previewer(original_content)
  return previewers.new_buffer_previewer({
    title = "Filter Preview (Live)",
    define_preview = function(self, entry, status)
      local filter = entry.value

      -- Run the filter command with the captured original content
      local result = vim.fn.system(filter.command, original_content)
      local shell_error = vim.v.shell_error  -- Capture immediately after system call

      -- Prepare preview content
      local preview_lines = {}

      -- Header section with command
      table.insert(preview_lines, "╔════════════════════════════════════════════════════════════")
      table.insert(preview_lines, "║ COMMAND TO EXECUTE:")
      table.insert(preview_lines, "╠════════════════════════════════════════════════════════════")
      table.insert(preview_lines, "║ :%!" .. filter.command)
      table.insert(preview_lines, "╠════════════════════════════════════════════════════════════")
      table.insert(preview_lines, "║ DESCRIPTION:")
      table.insert(preview_lines, "╠════════════════════════════════════════════════════════════")
      table.insert(preview_lines, "║ " .. filter.description)
      table.insert(preview_lines, "╠════════════════════════════════════════════════════════════")
      table.insert(preview_lines, "║ ACTIONS:")
      table.insert(preview_lines, "╠════════════════════════════════════════════════════════════")
      table.insert(preview_lines, "║ <CR>    : Apply filter to buffer")
      table.insert(preview_lines, "║ <C-e>   : Edit command in command line")
      table.insert(preview_lines, "║ <C-y>   : Yank command to clipboard")
      table.insert(preview_lines, "║ ?       : Show help")
      table.insert(preview_lines, "╚════════════════════════════════════════════════════════════")
      table.insert(preview_lines, "")
      table.insert(preview_lines, "▼ PREVIEW OUTPUT ▼")
      table.insert(preview_lines, "")

      if shell_error ~= 0 then
        -- Show error
        table.insert(preview_lines, "❌ ERROR:")
        table.insert(preview_lines, "")
        local error_lines = vim.split(result, "\n", { plain = true })
        for _, line in ipairs(error_lines) do
          table.insert(preview_lines, "  " .. line)
        end
      else
        -- Show result with line numbers
        local result_lines = vim.split(result, "\n", { plain = true })
        local num_lines = #result_lines

        -- Add summary
        table.insert(preview_lines, "✓ Success - " .. num_lines .. " lines")
        table.insert(preview_lines, "")

        -- Add first 100 lines of output
        local max_preview_lines = 100
        for i, line in ipairs(result_lines) do
          if i > max_preview_lines then
            table.insert(preview_lines, "")
            table.insert(preview_lines, "... (" .. (num_lines - max_preview_lines) .. " more lines)")
            break
          end
          table.insert(preview_lines, string.format("%4d │ %s", i, line))
        end
      end

      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)

      -- Set filetype to get some highlighting
      vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "text")

      -- Add highlighting
      local ns_id = vim.api.nvim_create_namespace("buffer_filters_preview")
      vim.api.nvim_buf_clear_namespace(self.state.bufnr, ns_id, 0, -1)

      -- Highlight header lines
      for i = 0, 14 do
        vim.api.nvim_buf_add_highlight(self.state.bufnr, ns_id, "Comment", i, 0, -1)
      end

      -- Highlight command line
      vim.api.nvim_buf_add_highlight(self.state.bufnr, ns_id, "String", 3, 0, -1)

      -- Highlight section title
      vim.api.nvim_buf_add_highlight(self.state.bufnr, ns_id, "Title", 16, 0, -1)

      -- Highlight error or success
      if shell_error ~= 0 then
        vim.api.nvim_buf_add_highlight(self.state.bufnr, ns_id, "ErrorMsg", 19, 0, -1)
      else
        vim.api.nvim_buf_add_highlight(self.state.bufnr, ns_id, "String", 19, 0, -1)
      end
    end,
  })
end

function M.show_picker()
  -- Capture the original buffer number and content before opening picker
  local original_bufnr = vim.api.nvim_get_current_buf()
  local original_lines = vim.api.nvim_buf_get_lines(original_bufnr, 0, -1, false)
  local original_content = table.concat(original_lines, "\n")
  
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
      results = M.filters,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name .. " " .. entry.description .. " " .. entry.command,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = create_filter_previewer(original_content),
    attach_mappings = function(prompt_bufnr, map)
      -- Default action: Apply filter to original buffer
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        
        -- Switch back to original buffer and apply filter
        vim.api.nvim_set_current_buf(original_bufnr)
        M.apply_filter(selection.value.command)
      end)

      -- Ctrl-e: Edit in command line
      map("i", "<C-e>", function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        M.edit_filter_in_cmdline(selection.value.command)
      end)

      map("n", "<C-e>", function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        M.edit_filter_in_cmdline(selection.value.command)
      end)

      -- Ctrl-y: Yank command to clipboard
      map("i", "<C-y>", function()
        local selection = action_state.get_selected_entry()
        vim.fn.setreg("+", ":%!" .. selection.value.command)
        vim.notify("Command copied to clipboard: :%!" .. selection.value.command, vim.log.levels.INFO)
      end)

      map("n", "<C-y>", function()
        local selection = action_state.get_selected_entry()
        vim.fn.setreg("+", ":%!" .. selection.value.command)
        vim.notify("Command copied to clipboard: :%!" .. selection.value.command, vim.log.levels.INFO)
      end)

      -- Show help
      map("i", "?", function()
        vim.notify([[
Buffer Filters Help:

<CR>    - Apply filter to current buffer
<C-e>   - Edit command in command line (for quick modifications)
<C-y>   - Yank command to clipboard
<C-c>   - Cancel/Close picker
?       - Show this help

The preview shows:
1. The exact command that will be executed
2. Description of what the filter does
3. Live preview of the output
4. Line count and error messages if any
        ]], vim.log.levels.INFO)
      end)

      map("n", "?", function()
        vim.notify([[
Buffer Filters Help:

<CR>    - Apply filter to current buffer
<C-e>   - Edit command in command line (for quick modifications)
<C-y>   - Yank command to clipboard
<C-c>   - Cancel/Close picker
?       - Show this help

The preview shows:
1. The exact command that will be executed
2. Description of what the filter does
3. Live preview of the output
4. Line count and error messages if any
        ]], vim.log.levels.INFO)
      end)

      return true
    end,
  }):find()
end

-- Function to add custom filters at runtime
function M.add_filter(name, command, description, ft)
  table.insert(M.filters, {
    name = name,
    command = command,
    description = description or "Custom filter",
    ft = ft or "text",
  })
end

return M
