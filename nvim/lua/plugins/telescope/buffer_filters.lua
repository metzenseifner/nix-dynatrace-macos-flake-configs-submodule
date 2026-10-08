return {
  event = "VeryLazy",
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/buffer_filters.nvim",
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require('buffer_filters').setup()
    vim.api.nvim_create_user_command("BufferFilter", function()
      require('buffer_filters').show_picker()
    end, {})

    -- Optional: Create keybinding
    vim.keymap.set("n", "<leader>paf", function()
      require('buffer_filters').show_picker()
    end, { desc = "[Pick A Filter] Buffer Filters" })
  end

}
