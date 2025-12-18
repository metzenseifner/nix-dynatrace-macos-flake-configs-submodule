-- Import luasnip functions
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

local function resolve_yq_bin()
  -- Use python-yq from nix flake via environment variable
  -- This allows installing both yq (python-yq) and yq-go without conflicts
  local python_yq = vim.env.PYTHON_YQ_BIN or os.getenv("PYTHON_YQ_BIN")
  if python_yq and vim.fn.executable(python_yq) == 1 then
    return python_yq
  end
  -- Fallback to PATH lookup
  return "yq"
end


-- TODO make this a lua package
local parse_yaml = function(config_path)
  local empty = {}
  assert(io.open(config_path, "r"))

  local yq_bin = resolve_yq_bin()
  -- python-yq syntax: yq <jq_filter> <file>
  local yq_cmd = string.format("%s . %s", yq_bin, config_path)

  --  vim.notify('Mike Farah not found, skipping loading dynatrace_links.yaml', vim.log.levels.ERROR)

  local ok, handle = pcall(io.popen, yq_cmd)
  
  if not ok or not handle then
    vim.notify("Failed to execute yq command: " .. yq_cmd, vim.log.levels.WARN)
    return empty
  end

  local output = handle:read("*a")
  handle:close()

 -- Check for common yq errors in output
  if output:match("parse error") or output:match("unknown command") or output:match("No such file") then
    vim.notify(
      string.format("yq command failed.\nCommand: %s\nOutput:\n%s", yq_cmd, output),
      vim.log.levels.ERROR
    )
    return nil
  end

  -- Decode YAML into JSON
  local ok, result = pcall(vim.json.decode, output) -- wrap with "protected call" for making it robust and verbose upon failure.
  if not ok then
    vim.notify(
      string.format("Failed to parse JSON from YAML file '%s'.\nCommand: %s\nRaw output:\n%s\nError: %s",
        config_path, yq_cmd, output, result),
      vim.log.levels.ERROR
    )
    return empty
  end
  return result
end

-- --
-- -- [[url][label]]
-- -- [label](url)
-- local create_url_snippet(in)
-- end

-- Top Function
local function parse_yaml_to_snippets(path)
  local snippets = {}
  local data = parse_yaml(path)

  local function create_url_snippet(name, url, description)
    return ls.snippet(name .. "-URL", {
      ls.text_node(url),
      ls.text_node("", ""),
      ls.text_node(description or ""),
    })
  end

  local extract_last_item = function(dot_chain)
    local items = {}
    for item in string.gmatch(dot_chain, "[^%.]+") do
      table.insert(items, item)
    end
    return items[#items]
  end

  local function create_markdown_link_snippet(name, url, description)
    return ls.snippet(name .. "-URL-markdown",
      fmt([[
        [<title>](<url>)
      ]], { title = t(extract_last_item(name)), url = t(url) }, { delimiters = "<>" })
    )
  end

  local function create_orgmode_link_snippet(name, url, description)
    return ls.snippet(name .. "-URL-orgmode",
      fmt([=[
        [[<url>][<title>]]
      ]=], { title = t(extract_last_item(name)), url = t(url) }, { delimiters = "<>" })
    )
  end

  -- local function traverse_table(tbl, prefix)
  --   for key, value in pairs(tbl) do
  --     if type(value) == "table" then
  --       if value.url then
  --         table.insert(snippets, create_snippet(prefix .. key, value.url, value.description))
  --       else
  --         traverse_table(value, prefix .. key .. ".")
  --       end
  --     end
  --   end
  -- end
  local function traverse_table(tbl, prefix)
    for key, value in pairs(tbl) do
      if type(value) == "table" then
        local new_prefix = prefix
        if type(key) ~= "number" then
          new_prefix = new_prefix .. key .. "."
        end
        if value.url then -- base case
          local snippet_name = new_prefix
          if value.name then
            snippet_name = snippet_name .. value.name
          end
          table.insert(snippets, create_url_snippet(snippet_name, value.url, value.description))
          table.insert(snippets, create_markdown_link_snippet(snippet_name, value.url, value.description))
          table.insert(snippets, create_orgmode_link_snippet(snippet_name, value.url, value.description))
        else -- recurse
          traverse_table(value, new_prefix)
        end
      end
    end
  end

  traverse_table(data, "")
  return snippets
end


-- Example usage
-- local yaml_content = [[
-- monaco:
--   - url: "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/configuration#deployment-manifest"
--     name: "monaco-deployment-manifest"
--   - url: "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/configuration/yaml-configuration#dynatrace-configuration-as-code-via-monaco"
--     name: "monaco-yaml"
--   - url: "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/guides/order-of-configurations"
--     name: "monaco-enforce-order-of-configuration-application"
--   - url: "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/guides/create-oauth-client#create-an-oauth-client"
--     name: "monaco-oauth-scopes-permissions"
--   - url: "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/configuration/special-configuration-types#settings-2-0-objects"
--     name: "monaco-settings-2.0-objects"
--   - url: "https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/guides/configuration-as-code-advanced-use-case"
--     name: "monaco-templates-templating"
--     description: "Dynatrace Monaco CLI projects contain both a config.yaml and JSON template file."
-- ]]

local dynatrace_links_snippets = parse_yaml_to_snippets(vim.fn.expand("~") ..
  "/.config/yaml-supplier/dynatrace_links.yaml")
local golang_links_snippets = parse_yaml_to_snippets(vim.fn.expand("~") .. "/.config/yaml-supplier/golang_links.yaml")
local result_array = {}
table.insert(result_array, dynatrace_links_snippets)
table.insert(result_array, golang_links_snippets)
-- recursive merge
local result = {}
--vim.tbl_deep_extend("force", result, dynatrace_links_snippets)
--vim.tbl_deep_extend("keep", result, golang_links_snippets)
return dynatrace_links_snippets
