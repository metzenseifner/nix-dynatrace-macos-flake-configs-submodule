function requirePath(path) 
  local portable = require('config.portable')
  local files = portable.safe_popen('find ./lua/' .. path .. ' -type f', 'r', 'custom_module_loader')

  if not files then
    vim.notify('Failed to find modules in path: ' .. path, vim.log.levels.WARN)
    return
  end

  for file in files:lines() do
    local req_file = file:gmatch('(' .. path .. '%/.+)%.lua$')()[1]
    if req_file then
      req_file = req_file:gsub('/', '.')
      local status_ok, _ = pcall(require, req_file)

      if status_ok then
        vim.notify('Loaded ' .. req_file)
      else
        vim.notify('Failed loading ' .. req_file, vim.log.levels.ERROR)
      end
    end
  end
  files:close()
end
--local files = io.popen('find "$HOME"/.config/nvim/lua/custom_modules' .. path .. ' -type f', 'r')

--print(files)
