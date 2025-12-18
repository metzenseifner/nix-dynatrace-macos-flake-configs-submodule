-- https://www.youtube.com/watch?v=2KLFjhGjmbI
return {
  "ggandor/leap.nvim",
  config = function(_, _)
    require('leap')
    vim.keymap.set({ 'n', 'x', 'o' }, '<leader>l', function() require("leap").leap {} end,
      { desc = "Leap forwards. Use two char strokes to pinput cursor destination." })
    vim.keymap.set({ 'n', 'x', 'o' }, '<leader>L', function() require("leap").leap { backward = true } end,
      { desc = "Leap backwards. Use two char strokes to pinpoint cursor destination." })
    vim.keymap.set({ 'n', 'x', 'o' }, '<leader>gl',
      function()
        require('leap').leap {
          target_windows = require('leap.util').get_enterable_windows()
        }
      end
      , { desc = "Leap forwards across windows." })
  end
}
