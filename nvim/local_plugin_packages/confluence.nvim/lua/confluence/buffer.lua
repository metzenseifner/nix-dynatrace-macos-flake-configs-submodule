-- Buffer management for Confluence pages
local M = {}

-- Convert Confluence storage format to more readable format
function M.storage_to_readable(content)
  -- Basic HTML to text conversion for better editing experience
  local readable = content
  
  -- Convert common HTML tags to more readable format
  readable = readable:gsub("<p>", "")
  readable = readable:gsub("</p>", "\n\n")
  readable = readable:gsub("<br/>", "\n")
  readable = readable:gsub("<br>", "\n")
  readable = readable:gsub("<strong>(.-)</strong>", "**%1**")
  readable = readable:gsub("<em>(.-)</em>", "*%1*")
  readable = readable:gsub("<code>(.-)</code>", "`%1`")
  
  -- Handle headings
  readable = readable:gsub("<h1>(.-)</h1>", "# %1\n")
  readable = readable:gsub("<h2>(.-)</h2>", "## %1\n") 
  readable = readable:gsub("<h3>(.-)</h3>", "### %1\n")
  readable = readable:gsub("<h4>(.-)</h4>", "#### %1\n")
  
  -- Handle lists
  readable = readable:gsub("<ul>", "")
  readable = readable:gsub("</ul>", "\n")
  readable = readable:gsub("<li>(.-)</li>", "- %1\n")
  
  -- Clean up excessive newlines
  readable = readable:gsub("\n\n\n+", "\n\n")
  readable = readable:gsub("^\n+", "")
  readable = readable:gsub("\n+$", "")
  
  return readable
end

-- Convert readable format back to Confluence storage format
function M.readable_to_storage(content)
  local storage = content
  
  -- Convert markdown-like formatting back to HTML
  storage = storage:gsub("\n\n", "</p><p>")
  storage = storage:gsub("^(.)", "<p>%1")
  storage = storage:gsub("(.)$", "%1</p>")
  
  -- Handle headings
  storage = storage:gsub("<p># (.-)</p>", "<h1>%1</h1>")
  storage = storage:gsub("<p>## (.-)</p>", "<h2>%1</h2>")
  storage = storage:gsub("<p>### (.-)</p>", "<h3>%1</h3>")
  storage = storage:gsub("<p>#### (.-)</p>", "<h4>%1</h4>")
  
  -- Handle formatting
  storage = storage:gsub("%*%*(.-)%*%*", "<strong>%1</strong>")
  storage = storage:gsub("%*(.-)%*", "<em>%1</em>")
  storage = storage:gsub("`(.-)`", "<code>%1</code>")
  
  -- Handle lists
  storage = storage:gsub("<p>%- (.-)</p>", "<li>%1</li>")
  storage = storage:gsub("(<li>.-</li>)", "<ul>%1</ul>")
  
  -- Clean up empty paragraphs
  storage = storage:gsub("<p></p>", "")
  
  return storage
end

-- Create a new buffer for Confluence page
function M.create_confluence_buffer(page_info, content, version, format)
  format = format or "confluence" -- default format
  
  -- Create new buffer
  local buf = vim.api.nvim_create_buf(false, false)
  
  -- Convert content based on format
  local readable_content
  if format == "orgmode" then
    local pandoc = require('confluence.pandoc')
    readable_content = pandoc.confluence_to_orgmode(content)
    if not readable_content then
      vim.notify("Error converting to org-mode format", vim.log.levels.ERROR)
      return nil
    end
  else
    -- Default confluence format
    readable_content = M.storage_to_readable(content)
  end
  
  local lines = vim.split(readable_content, "\n")
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Set buffer name
  local format_suffix = format == "orgmode" and " [org]" or ""
  local buf_name = string.format("[Confluence] %s%s", page_info.title, format_suffix)
  vim.api.nvim_buf_set_name(buf, buf_name)
  
  -- Configure buffer options based on format
  local confluence = require('confluence')
  if format == "orgmode" then
    vim.bo[buf].filetype = "org"
  else
    vim.bo[buf].filetype = confluence.config.buffer_options.filetype
  end
  
  vim.bo[buf].buftype = "acwrite"  -- Custom write command
  vim.wo.wrap = confluence.config.buffer_options.wrap
  vim.wo.spell = confluence.config.buffer_options.spell
  
  -- Register page data
  local page_data = {
    page_id = page_info.page_id,
    title = page_info.title,
    space = page_info.space,
    version = version,
    format = format,
    original_content = content  -- Keep original for comparison
  }
  
  confluence._register_page(buf, page_data)
  
  -- Open buffer in current window
  vim.api.nvim_win_set_buf(0, buf)
  
  -- Add buffer-local keymaps
  local opts = { buffer = buf, silent = true }
  vim.keymap.set('n', '<leader>cs', function()
    require('confluence').save()
  end, vim.tbl_extend('force', opts, { desc = 'Save Confluence page' }))
  
  vim.keymap.set('n', '<leader>cq', function()
    vim.cmd('bdelete')
  end, vim.tbl_extend('force', opts, { desc = 'Close Confluence page' }))
  
  vim.keymap.set('n', '<leader>cr', function()
    require('confluence').reload()
  end, vim.tbl_extend('force', opts, { desc = 'Reload Confluence page from server' }))
  
  -- Set up auto-save functionality ONLY for this buffer
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      require('confluence').save()
    end,
  })
  
  -- Handle :e! (reload) for this buffer
  vim.api.nvim_create_autocmd("BufReadCmd", {
    buffer = buf,
    callback = function()
      require('confluence').reload()
    end,
  })
  
  -- Convert content back to storage format before saving (removed duplicate)
  -- This is now handled in the main save function
  
  return buf
end

-- Get current buffer's Confluence page data
function M.get_page_data(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local confluence = require('confluence')
  return confluence._get_page_data and confluence._get_page_data(buf)
end

return M