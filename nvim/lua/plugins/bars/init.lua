local utils = {}

utils.renderString = function(value, conf)
  -- setup default args
  default_conf = { format = 'text' }
  if conf == nil then conf = default_conf end
  -- end setup default args

  if (conf.format == 'text') then return value end
  if (conf.format == 'hex') then
    bytes = {}
    for i = 1, #value do
      char = string.sub(value, i, i)
      table.insert(bytes, string.format("0x" .. "%02x", string.byte(char)))
    end
    return table.concat(bytes, " ")
  end
end

utils.multibyteCharUnderCursor = function()
  return utils.renderString(vim.fn.strcharpart(vim.fn.strpart(vim.fn.getline('.'), vim.fn.col('.') - 1), 0, 1),
    { format = 'hex' })
end

c = utils

return
{
  --{ import = "plugins.bars.tabby" },
  { import = "plugins.bars.lualine" },
  --{ import = "plugins.bars.bufferline" }
}
