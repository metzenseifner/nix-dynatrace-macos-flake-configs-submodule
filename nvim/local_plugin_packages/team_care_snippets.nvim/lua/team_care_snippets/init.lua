local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

local M = {}

local function load_team_yaml()
  local yaml_path = vim.fn.expand("~/.config/yaml-supplier/team_care.yml")
  
  if vim.fn.filereadable(yaml_path) ~= 1 then
    vim.notify("Team care YAML file not found: " .. yaml_path, vim.log.levels.WARN)
    return nil
  end
  
  if vim.fn.executable("yq") ~= 1 then
    vim.notify("yq not found. Install yq for YAML parsing", vim.log.levels.WARN)
    return nil
  end
  
  local yq_cmd = string.format("yq . %s --output-format json", yaml_path)
  local ok, handle = pcall(io.popen, yq_cmd)
  if not ok or not handle then
    vim.notify("Failed to run yq command", vim.log.levels.WARN)
    return nil
  end
  
  local result_json = handle:read("*a")
  handle:close()
  
  if result_json == "" or result_json:match("parse error") then
    vim.notify("Failed to parse YAML file: " .. yaml_path, vim.log.levels.WARN)
    return nil
  end
  
  local ok, config = pcall(vim.json.decode, result_json)
  if not ok then
    vim.notify("Failed to decode JSON from YAML: " .. tostring(config), vim.log.levels.WARN)
    return nil
  end
  
  return config
end

local function create_member_snippet(member)
  local name = member.name
  local trigger = name:gsub("%s+", "-"):lower()
  
  local roles = member.roles or {}
  local special = member.special_engagements or {}
  
  local role_text = ""
  if #roles > 0 then
    role_text = " (" .. table.concat(roles, ", ") .. ")"
  end
  
  local special_text = ""
  if #special > 0 then
    special_text = " (" .. table.concat(special, ", ") .. ")"
  end
  
  local choices = {
    t(name),
  }
  
  if #roles > 0 then
    table.insert(choices, t(name .. role_text))
  end
  
  if #special > 0 then
    table.insert(choices, t(name .. special_text))
  end
  
  if #roles > 0 and #special > 0 then
    table.insert(choices, t(name .. role_text .. special_text))
  end
  
  if #choices == 1 then
    return s(trigger, { t(name) })
  else
    return s(trigger, { 
      f(function() 
        vim.api.nvim_echo({{" <C-n>: next | <C-b>: prev | <C-f>: confirm & next node", "MoreMsg"}}, false, {})
        return ""
      end),
      c(1, choices)
    })
  end
end

M.setup = function(opts)
  local config = load_team_yaml()
  
  if not config or not config.team_members then
    vim.notify("No team members found in YAML config", vim.log.levels.WARN)
    return
  end
  
  local snippets = {}
  for _, member in ipairs(config.team_members) do
    table.insert(snippets, create_member_snippet(member))
  end
  
  ls.add_snippets("all", snippets)
  
  vim.notify(string.format("Loaded %d team care snippets", #snippets), vim.log.levels.INFO)
end

return M
