local M = {}

M.config = {
  char_sets = {},
  pattern_sets = {},
  enabled = true,
  update_events = { "TextChanged", "TextChangedI", "BufEnter", "WinScrolled" },
}

local ns_id = nil

local function setup_highlights()
  for _, set in pairs(M.config.char_sets) do
    local hl_opts = {}
    if set.color.bg then hl_opts.bg = set.color.bg end
    if set.color.fg then hl_opts.fg = set.color.fg end
    if set.color.bold then hl_opts.bold = true end
    if set.color.italic then hl_opts.italic = true end
    if set.color.underline then hl_opts.underline = true end
    
    vim.api.nvim_set_hl(0, set.highlight, hl_opts)
  end
  
  for _, set in pairs(M.config.pattern_sets) do
    local hl_opts = {}
    if set.color.bg then hl_opts.bg = set.color.bg end
    if set.color.fg then hl_opts.fg = set.color.fg end
    if set.color.bold then hl_opts.bold = true end
    if set.color.italic then hl_opts.italic = true end
    if set.color.underline then hl_opts.underline = true end
    
    vim.api.nvim_set_hl(0, set.highlight, hl_opts)
  end
end

local function check_context(line, match_start, match_end, context)
  if not context then return true end
  
  if context.line_start and match_start ~= 1 then
    return false
  end
  
  if context.line_end then
    local trimmed_end = #line:match("^(.-)%s*$")
    if match_end < trimmed_end then
      return false
    end
  end
  
  if context.after_non_whitespace then
    local before = line:sub(1, match_start - 1)
    if not before:match("%S") then
      return false
    end
  end
  
  if context.word_boundary then
    local before_char = match_start > 1 and line:sub(match_start - 1, match_start - 1) or ""
    local after_char = match_end < #line and line:sub(match_end + 1, match_end + 1) or ""
    
    local is_word_char = function(c)
      return c:match("[%w_]") ~= nil
    end
    
    if (before_char ~= "" and is_word_char(before_char)) or 
       (after_char ~= "" and is_word_char(after_char)) then
      return false
    end
  end
  
  return true
end

local function highlight_buffer(bufnr)
  if not M.config.enabled then return end
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  
  -- Handle character sets (exact character matching)
  for _, set in pairs(M.config.char_sets) do
    for line_idx, line in ipairs(lines) do
      for _, char in ipairs(set.chars) do
        local col = 1
        while true do
          local start_pos = line:find(char, col, true)
          if not start_pos then break end
          
          local end_pos = start_pos + #char - 1
          
          if check_context(line, start_pos, end_pos, set.context) then
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_idx - 1, start_pos - 1, {
              end_col = end_pos,
              hl_group = set.highlight,
              priority = set.priority or 200,
            })
          end
          
          col = end_pos + 1
        end
      end
    end
  end
  
  -- Handle pattern sets (lua pattern matching)
  for _, set in pairs(M.config.pattern_sets) do
    for line_idx, line in ipairs(lines) do
      local col = 1
      while col <= #line do
        local start_pos, end_pos = line:find(set.pattern, col)
        if not start_pos then break end
        
        if check_context(line, start_pos, end_pos, set.context) then
          vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_idx - 1, start_pos - 1, {
            end_col = end_pos,
            hl_group = set.highlight,
            priority = set.priority or 200,
          })
        end
        
        col = end_pos + 1
      end
    end
  end
end

local function setup_autocmds()
  local group = vim.api.nvim_create_augroup("CharHighlight", { clear = true })
  
  vim.api.nvim_create_autocmd(M.config.update_events, {
    group = group,
    callback = function(args)
      highlight_buffer(args.buf)
    end,
  })
  
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      setup_highlights()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          highlight_buffer(bufnr)
        end
      end
    end,
  })
end

function M.add_char_set(name, config)
  M.config.char_sets[name] = config
  setup_highlights()
  
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      highlight_buffer(bufnr)
    end
  end
end

function M.remove_char_set(name)
  M.config.char_sets[name] = nil
  
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      highlight_buffer(bufnr)
    end
  end
end

function M.add_pattern_set(name, config)
  M.config.pattern_sets[name] = config
  setup_highlights()
  
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      highlight_buffer(bufnr)
    end
  end
end

function M.remove_pattern_set(name)
  M.config.pattern_sets[name] = nil
  
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      highlight_buffer(bufnr)
    end
  end
end

function M.toggle()
  M.config.enabled = not M.config.enabled
  
  if M.config.enabled then
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        highlight_buffer(bufnr)
      end
    end
    vim.notify("CharHighlight: Enabled", vim.log.levels.INFO)
  else
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
      end
    end
    vim.notify("CharHighlight: Disabled", vim.log.levels.INFO)
  end
end

function M.setup(user_config)
  if user_config then
    M.config = vim.tbl_deep_extend("force", M.config, user_config)
  end
  
  ns_id = vim.api.nvim_create_namespace("char_highlight")
  
  setup_highlights()
  setup_autocmds()
  
  vim.schedule(function()
    highlight_buffer(vim.api.nvim_get_current_buf())
  end)
  
  vim.api.nvim_create_user_command("CharHighlightToggle", function()
    M.toggle()
  end, { desc = "Toggle character highlighting" })
  
  vim.api.nvim_create_user_command("CharHighlightRefresh", function()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        highlight_buffer(bufnr)
      end
    end
    vim.notify("CharHighlight: Refreshed", vim.log.levels.INFO)
  end, { desc = "Refresh character highlighting" })
end

return M
