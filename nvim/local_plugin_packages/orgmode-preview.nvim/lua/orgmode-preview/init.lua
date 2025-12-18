local M = {}

local config = {
  css_file = nil,
  auto_refresh = true,
}

M.setup = function(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("force", config, opts)
  
  if vim.fn.executable("pandoc") == 0 then
    vim.notify("pandoc not found. orgmode-preview requires pandoc to work.", vim.log.levels.WARN)
    return
  end
end

M.preview = function()
  if vim.fn.executable("pandoc") == 0 then
    vim.notify("pandoc not found. Please install pandoc to preview org files.", vim.log.levels.WARN)
    return
  end

  vim.cmd('write')
  
  local css = config.css_file or vim.fn.expand(vim.fn.stdpath('config') .. '/local_plugin_packages/orgmode-preview.nvim/latex.css')
  local infile = vim.fn.expand('%:p')
  local outfile = vim.fn.expand('%:r') .. '.html'
  
  if vim.fn.filereadable(css) == 0 then
    vim.notify("CSS file not found: " .. css, vim.log.levels.WARN)
    return
  end

  vim.fn.jobstart({ 'pandoc', '-s', '--from=org', '--to=html', '-c', css, infile, '-o', outfile }, {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.notify("pandoc conversion failed with exit code: " .. exit_code, vim.log.levels.ERROR)
        return
      end
      
      local open_cmd
      if vim.fn.has('mac') == 1 then
        open_cmd = { 'open', outfile }
      elseif vim.fn.has('win32') == 1 then
        open_cmd = { 'cmd', '/c', 'start', '', outfile }
      else
        open_cmd = { 'xdg-open', outfile }
      end
      
      vim.fn.jobstart(open_cmd, { detach = true })
      vim.notify("Org file preview opened: " .. outfile, vim.log.levels.INFO)
    end,
    on_stderr = function(_, data)
      if data and #data > 0 and data[1] ~= "" then
        vim.notify("pandoc stderr: " .. table.concat(data, "\n"), vim.log.levels.WARN)
      end
    end
  })
end

return M
