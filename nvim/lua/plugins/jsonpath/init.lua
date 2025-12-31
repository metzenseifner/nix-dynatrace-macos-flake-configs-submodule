return {
  "phelipetls/jsonpath.nvim",
  enable = true,
  dependencies = {
    "ojroques/nvim-osc52"
  },
  config = function(_, _)
    -- using :lua without trailing <CR> means it will be entered into the vim command line but will not exec until ENTER is pressed.
    vim.keymap.set('n', '<leader>jc', ":lua require'osc52'.copy(require'jsonpath'.get())",
      { desc = 'Copy json path to clipboard (JQ-like syntax).' })
    require 'jsonpath'
  end
}
