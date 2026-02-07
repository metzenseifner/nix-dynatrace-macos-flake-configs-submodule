-- Utility to extract and manage Go build tags dynamically
local M = {}

-- Extract build tags from a file
function M.extract_tags_from_file(filepath)
  local tags = {}
  local file = io.open(filepath, "r")
  if not file then return tags end
  
  -- Read first 10 lines to find build tags
  for i = 1, 10 do
    local line = file:read("*line")
    if not line then break end
    
    -- Match //go:build directives
    local build_directive = line:match("^//go:build%s+(.+)$")
    if build_directive then
      -- Extract tag names (basic parsing, ignores complex logic)
      for tag in build_directive:gmatch("[%w_]+") do
        if tag ~= "build" and not tags[tag] then
          tags[tag] = true
        end
      end
    end
    
    -- Stop at package declaration
    if line:match("^package%s") then
      break
    end
  end
  
  file:close()
  
  -- Convert to array
  local result = {}
  for tag, _ in pairs(tags) do
    table.insert(result, tag)
  end
  return result
end

-- Extract build tags from current buffer
function M.get_tags_from_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
  local tags = {}
  
  for _, line in ipairs(lines) do
    local build_directive = line:match("^//go:build%s+(.+)$")
    if build_directive then
      for tag in build_directive:gmatch("[%w_]+") do
        if tag ~= "build" and not tags[tag] then
          tags[tag] = true
        end
      end
    end
    
    -- Stop at package declaration
    if line:match("^package%s") then
      break
    end
  end
  
  local result = {}
  for tag, _ in pairs(tags) do
    table.insert(result, tag)
  end
  return result
end

-- Format tags for gopls buildFlags
function M.format_build_flags(tags)
  if #tags == 0 then
    return nil
  end
  return { "-tags=" .. table.concat(tags, ",") }
end

return M
