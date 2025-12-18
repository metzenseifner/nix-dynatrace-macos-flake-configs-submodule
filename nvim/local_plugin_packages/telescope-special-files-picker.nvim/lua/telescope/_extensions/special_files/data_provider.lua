-- Data Provider 
local M = {}

-- Supplies a table full of data suitable for a telescope finder
-- @return table<SpecialFile>: A table containing special files
M.provider = function(config)
  config.
  --@type table<SpecialFile>
  local files = {}

  -- Creates internal representation of SpecialFile from a path.
  local pathToSpecialFile = function()
  end

  -- Iterate all paths and populate finder data table
  for _, special_file in pairs(srcs) do
    local something = ?
    table.insert(files, something)
  end

  local find_command = "find . -maxdepth 1 -type f"

  --- One shot job
  ---@param command_list string[]: Command list to execute.
  ---@param opts table: stuff
  --         @key entry_maker function Optional: function(line: string) => table
  --         @key cwd string
  -- finders.new_oneshot_job(command_list, opts)

end


return M
