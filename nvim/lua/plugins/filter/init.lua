return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/filter.nvim",
  event = "VeryLazy",
  config = function()
    local filter = require 'filter'
    -- Whole buffer: sort
    --- filter.map_buffer("<leader>s", "sort", {
    ---   desc = "Sort entire buffer",
    ---   on_success =
    ---   function(ctx)
    ---     local n = ctx.new_lines and #ctx.new_lines or 0
    ---     vim.notify(("Filtered via '%s' (%d lines updated)"):format(ctx.cmd, n))
    ---   end
    --- })
    -- Pretty-print entire buffer
    filter.map_buffer('<leader>jp', [[:%!jq .<CR>]], { desc = 'Pretty-print JSON buffer' })
    -- Minify entire buffer (compact)
    filter.map_buffer('<leader>jm', [[:%!jq -c .<CR>]], { desc = 'Minify JSON buffer' })
    -- Sort keys in entire buffer
    filter.map_buffer('<leader>js', [[:%!jq -S .<CR>]], { desc = 'Sort JSON keys buffer' })

    -- Pretty-print selection
    filter.map_visual('<leader>jp', [[:'<,'>!jq .<CR>]], { desc = 'Pretty-print JSON selection' })
    -- Minify selection
    filter.map_visual('<leader>jm', [[:'<,'>!jq -c .<CR>]], { desc = 'Minify JSON selection' })
    -- Sort keys in selection
    filter.map_visual('<leader>js', [[:'<,'>!jq -S .<CR>]], { desc = 'Sort JSON keys selection' })

    -- Expand a JSON string value -> object/array (select including quotes, e.g., va")
    filter.map_visual('<leader>je', [[:'<,'>!jq -R 'fromjson'<CR>]],
      { desc = 'Expand JSON string value to real JSON' })

    -- Collapse an object/array -> escaped JSON string value (select the object/array)
    filter.map_visual('<leader>jc', [[:'<,'>!jq -c . | jq -R @json<CR>]],
      { desc = 'Collapse JSON back into an escaped string value' })
  end
}
