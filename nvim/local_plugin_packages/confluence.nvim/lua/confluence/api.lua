-- Confluence API client
local M = {}

local http = require('confluence.http')

-- Get base API URL
local function get_api_url(endpoint)
  local confluence = require('confluence')
  return confluence.config.base_url .. "/wiki/rest/api/" .. endpoint
end

-- Get page content by ID
function M.get_page_content(page_id, callback)
  local url = get_api_url("content/" .. page_id .. "?expand=body.storage,version")
  
  http.get(url, function(response, err)
    if err then
      callback(nil, nil, err)
      return
    end
    
    if not response or not response.body or not response.body.storage then
      callback(nil, nil, "Invalid response format")
      return
    end
    
    local content = response.body.storage.value
    local version = response.version and response.version.number or 1
    
    callback(content, version, nil)
  end)
end

-- Update page content
function M.update_page_content(page_id, content, version, callback)
  local url = get_api_url("content/" .. page_id .. "?status=current&expand=body.storage")
  
  -- First get current page info to preserve title and space
  M.get_page_info(page_id, function(page_info, err)
    if err then
      callback(false, err)
      return
    end
    
    local update_data = {
      type = "page",
      title = page_info.title,
      version = { number = version },
      body = {
        storage = {
          value = content,
          representation = "storage"
        }
      }
    }
    
    http.put(url, update_data, function(response, err)
      if err then
        callback(false, err)
        return
      end
      
      callback(true, nil)
    end)
  end)
end

-- Get basic page info (title, space, etc.)
function M.get_page_info(page_id, callback)
  local url = get_api_url("content/" .. page_id .. "?expand=space,version")
  
  http.get(url, function(response, err)
    if err then
      callback(nil, err)
      return
    end
    
    if not response then
      callback(nil, "Invalid response")
      return
    end
    
    local page_info = {
      id = response.id,
      title = response.title,
      space = response.space and response.space.key or "Unknown",
      version = response.version and response.version.number or 1
    }
    
    callback(page_info, nil)
  end)
end

-- Search pages by title (optional utility function)
function M.search_pages(query, callback)
  local encoded_query = vim.fn.shellescape(query)
  local url = get_api_url("content/search?cql=title~" .. encoded_query .. "&expand=space,version")
  
  http.get(url, function(response, err)
    if err then
      callback(nil, err)
      return
    end
    
    local results = {}
    if response and response.results then
      for _, result in ipairs(response.results) do
        table.insert(results, {
          id = result.id,
          title = result.title,
          space = result.space and result.space.key or "Unknown",
          url = result._links and result._links.webui or ""
        })
      end
    end
    
    callback(results, nil)
  end)
end

return M