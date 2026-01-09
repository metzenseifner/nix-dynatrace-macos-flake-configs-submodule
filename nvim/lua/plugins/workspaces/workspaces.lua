local workspaces_dir = vim.fn.stdpath("data") .. "/workspaces"
return {
  {
    "natecraddock/workspaces.nvim",
    dependencies = {
      "stevearc/oil.nvim",
    },
    config = function()
      -- :h workspaces-usage
      local conf = {
        -- path to a file to store workspaces data in
        -- on a unix system this would be ~/.local/share/nvim/workspaces
        path = workspaces_dir,
        -- to change directory for all of nvim (:cd) or only for the current window (:lcd)
        -- if you are unsure, you likely want this to be true.
        global_cd = true,
        -- sort the list of workspaces by name after loading from the workspaces path.
        sort = true,
        -- sort by recent use rather than by name. requires sort to be true
        mru_sort = true,
        -- enable info-level notifications after adding or removing a workspace
        notify_info = true,
        -- lists of hooks to run after specific actions
        -- hooks can be a lua function or a vim command (string)
        -- lua hooks take a name, a path, and an optional state table
        -- if only one hook is needed, the list may be omitted
        hooks = {
          add = {},
          remove = {},
          rename = {},
          open_pre = function(name, path)
          end,
          open = function()
            vim.schedule_wrap(function() vim.notify('New Working Dir: ' .. vim.fn.getcwd()) end)
            --vim.cmd('tabnew')
            --require('neo-tree').show(nil, nil, { dir = vim.fn.getcwd() })



            --require 'telescope.builtin'.find_files()

            --vim.schedule_wrap(require'telescope.builtin'.find_files({hidden=true}, require'telescope.themes'.get_dropdown({previewer=false})))
            --vim.schedule_wrap(function()vim.cmd("stopinsert")end)
            --"lua require'telescope.builtin'.find_files()", -- causes neo-tree to crash (nui)
            --function()
            --  require("sessions").load(nil, {silent=true})
            --end,
            -- vim.cmd() allows for :Ex mode commands
          end,
        }
      }
      require("workspaces").setup(conf)
      vim.keymap.set('n', '<leader>twc', function() require 'oil'.open_float(workspaces_dir) end,
        { desc = "Open workspaces dir in Oil (tree workspaces config)" })
      vim.keymap.set("n", "<leader>pw", "<cmd>Telescope workspaces<cr>", { desc = "Open workspaces in Telesope." })
    end
  }
}
