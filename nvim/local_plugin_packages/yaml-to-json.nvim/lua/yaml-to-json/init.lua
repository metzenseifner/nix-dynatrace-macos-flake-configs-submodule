M = {}

M.parse_yaml_as_json = function(config_path)
  assert(io.open(config_path, "r"))
  
  if vim.fn.executable("yq") ~= 1 then
    vim.notify("yq command not found. Install yq to use YAML to JSON conversion.", vim.log.levels.WARN)
    return {}
  end
  
  local ok, handle = pcall(io.popen, string.format("yq . %s --output-format json", config_path))
  if not ok then
    vim.notify("Failed to execute yq command", vim.log.levels.ERROR)
    return {}
  end
  
  local output = handle:read("*a")
  handle:close()
  
  local ok_decode, result = pcall(vim.json.decode, output)
  if not ok_decode then
    vim.notify("Failed to decode JSON from yq output", vim.log.levels.ERROR)
    return {}
  end
  
  return result
end

M.setup = function(config)
   if vim.fn.executable("yq") ~= 1 then
     vim.notify(string.format("Could not find yq binary on the PATH: %s", os.getenv("PATH")), vim.log.levels.WARN)
   end
end

return M
