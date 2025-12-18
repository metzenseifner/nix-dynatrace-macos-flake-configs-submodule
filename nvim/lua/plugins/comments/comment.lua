return
{
  "numToStr/Comment.nvim",
  init = function()
  end,

  config = function(_, _)
    local conf = {

    }
    require 'Comment'.setup(conf)
    local ft = require('Comment.ft')
    ft.set('markdown', '> %s')
  end
}
