local M = {}

-- Function to read a file
local function read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

-- Function to create text snippets
local function create_text_snippets(content)
  local snippets = {}
  for line in content:gmatch("[^\r\n]+") do
    table.insert(snippets, { trigger = line, text = line })
  end
  return snippets
end

-- Function to create snippets from YAML
local function create_yaml_snippets(content)
  local parser = require("yaml-to-json")
  local parsed = parser.parse_yaml_as_json(content)
  local snippets = {}

  local function traverse_yaml(node, prefix)
    prefix = prefix or ""
    if type(node) == "table" then
      for key, value in pairs(node) do
        traverse_yaml(value, prefix .. key .. ".")
      end
    else
      table.insert(snippets, { trigger = prefix, text = tostring(node) })
    end
  end

  traverse_yaml(parsed)
  return snippets
end

-- Function to create supplier snippets
local function create_supplier_snippets(supplier)
  return supplier()
end

-- Main function to transform file into snippets
function M.transform_file(path, input_type, supplier)
  local content = read_file(path)
  if not content then return nil end

  if input_type == "text" then
    return create_text_snippets(content)
  elseif input_type == "yaml" then
    return create_yaml_snippets(content)
  elseif input_type == "supplier" and supplier then
    return create_supplier_snippets(supplier)
  else
    return nil
  end
end

-- Plugin setup function
function M.setup(config)
  for _, source in ipairs(config.sources) do
    vim.notify("source-to-snippets: Reading source: ", source.name or source.path)
    local snippets = M.transform_file(source.path, source.input_type, source.supplier)
    -- register snippets with a snippet engine
    require("luasnip").add_snippets(source.snippet_filetype or "all", snippets)
  end
end

return M
-- To use this plugin with lazy.nvim, you can add it to your configuration like this:
--
-- require("lazy").setup({
--   {
--     "source-to-snippets.nvim",
--     config = function(_, _)
--       local conf = {
--         sources = {
--           {
--             name = "Dynatrace Links",
--             path = vim.fn.expand("~") .. "/.config/yaml-supplier/dynatrace_links.yaml",
--             input_type = "yaml"
--             snippet_filetype = "all"
--           },
--           {
--             name = "Team Members",
--             path = vim.fn.expand("~") .. "/.config/yaml-supplier/team_members.yaml",
--             input_type = "text"
--           }
--         }
--       }
--       require("source-to-snippets").setup(conf)
--     end
--   }
-- })
