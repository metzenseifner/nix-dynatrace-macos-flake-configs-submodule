-- Pandoc integration for format conversion
local M = {}

-- Convert org-mode content to Confluence storage format using pandoc
function M.orgmode_to_confluence(org_content)
  local confluence = require('confluence')
  local pandoc_cmd = confluence.config.pandoc.executable
  
  -- Create temporary files
  local temp_org = vim.fn.tempname() .. '.org'
  local temp_html = vim.fn.tempname() .. '.html'
  
  -- Write org content to temp file
  local org_file = io.open(temp_org, 'w')
  if not org_file then
    return nil
  end
  org_file:write(org_content)
  org_file:close()
  
  -- Convert org to HTML using pandoc
  local cmd = string.format("%s -f org -t html5 --wrap=none '%s' -o '%s'", 
    pandoc_cmd, temp_org, temp_html)
  
  local result = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Pandoc conversion failed: " .. result, vim.log.levels.ERROR)
    -- Clean up temp files
    os.remove(temp_org)
    os.remove(temp_html)
    return nil
  end
  
  -- Read HTML result
  local html_file = io.open(temp_html, 'r')
  if not html_file then
    os.remove(temp_org)
    os.remove(temp_html)
    return nil
  end
  
  local html_content = html_file:read('*a')
  html_file:close()
  
  -- Clean up temp files
  os.remove(temp_org)
  os.remove(temp_html)
  
  -- Convert HTML to Confluence storage format
  local storage_content = M.html_to_confluence_storage(html_content)
  
  return storage_content
end

-- Convert Confluence storage format to org-mode using pandoc
function M.confluence_to_orgmode(storage_content)
  local confluence = require('confluence')
  local pandoc_cmd = confluence.config.pandoc.executable
  
  -- Convert Confluence storage to clean HTML first
  local clean_html = M.confluence_storage_to_html(storage_content)
  
  -- Create temporary files
  local temp_html = vim.fn.tempname() .. '.html'
  local temp_org = vim.fn.tempname() .. '.org'
  
  -- Write HTML content to temp file
  local html_file = io.open(temp_html, 'w')
  if not html_file then
    return nil
  end
  html_file:write(clean_html)
  html_file:close()
  
  -- Convert HTML to org using pandoc
  local cmd = string.format("%s -f html -t org --wrap=none '%s' -o '%s'", 
    pandoc_cmd, temp_html, temp_org)
  
  local result = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Pandoc conversion failed: " .. result, vim.log.levels.ERROR)
    -- Clean up temp files
    os.remove(temp_html)
    os.remove(temp_org)
    return nil
  end
  
  -- Read org result
  local org_file = io.open(temp_org, 'r')
  if not org_file then
    os.remove(temp_html)
    os.remove(temp_org)
    return nil
  end
  
  local org_content = org_file:read('*a')
  org_file:close()
  
  -- Clean up temp files
  os.remove(temp_html)
  os.remove(temp_org)
  
  return org_content
end

-- Convert clean HTML to Confluence storage format
function M.html_to_confluence_storage(html_content)
  -- Confluence storage format is essentially HTML with some specific requirements
  -- Remove HTML doctype and html/body tags that pandoc adds
  local storage = html_content
  
  -- Remove doctype and html structure
  storage = storage:gsub('<!DOCTYPE[^>]*>', '')
  storage = storage:gsub('<html[^>]*>', '')
  storage = storage:gsub('</html>', '')
  storage = storage:gsub('<head>.-</head>', '')
  storage = storage:gsub('<body[^>]*>', '')
  storage = storage:gsub('</body>', '')
  
  -- Clean up whitespace
  storage = storage:gsub('^%s+', '')
  storage = storage:gsub('%s+$', '')
  
  return storage
end

-- Convert Confluence storage format to clean HTML for pandoc
function M.confluence_storage_to_html(storage_content)
  -- Confluence storage is mostly HTML already, just need to clean it up
  local html = storage_content
  
  -- Wrap in basic HTML structure for pandoc
  html = '<!DOCTYPE html><html><body>' .. html .. '</body></html>'
  
  return html
end

-- Check if pandoc is available and working
function M.check_pandoc()
  local confluence = require('confluence')
  local pandoc_cmd = confluence.config.pandoc.executable
  
  if vim.fn.executable(pandoc_cmd) ~= 1 then
    return false, "Pandoc executable not found: " .. pandoc_cmd
  end
  
  -- Test pandoc with a simple conversion
  local result = vim.fn.system(pandoc_cmd .. ' --version')
  if vim.v.shell_error ~= 0 then
    return false, "Pandoc not working: " .. result
  end
  
  return true, "Pandoc is available and working"
end

return M