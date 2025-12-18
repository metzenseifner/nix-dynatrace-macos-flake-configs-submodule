return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/smartterm.nvim",
  config = function(modname, opts)
    -- Require and (optionally) configure
    require('smartterm').setup({
      height = 14,       -- bottom split height
      start_in_insert = true -- jump to insert when opening
    })

    -- Keymaps: use the SAME binding in normal & terminal mode for a seamless toggle
    vim.keymap.set({ 'n', 't' }, '<leader>T', function()
      require('smartterm').toggle()
    end, { silent = true, desc = 'Toggle bottom terminal' })

    -- You can also use the command:
    -- :ToggleTerm
  end
}
