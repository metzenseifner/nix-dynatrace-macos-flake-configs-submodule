local template = [[
vim.keymap.set('n', '<leader>gc', function()
  vim.ui.input({
    prompt = 'Git command: ',
    default = 'git ',  -- prefill text
  }, function(input)
    if input then
      vim.cmd('!' .. input)
      -- or use vim.fn.system(input) for silent execution
    end
  end)
end, { desc = 'Run git command' })
]]

return {
  s("vim.ui.input", fmt(template, {}, { delimiters = "[]" })),
}
