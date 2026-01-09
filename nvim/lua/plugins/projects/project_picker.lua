return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/project_picker.nvim",
  dependencies = { "vim-telescope/telescope.nvim" },
  config = function()
    require("project_picker").setup({
      sources = {
        dynatrace_projects = {
          roots = { "/Users/jonathan.komar/devel/dynatrace_bitbucket/15_TEAM_CARE_PROJECTS/*" },
        },
        -- add more sources here if you like
        -- monorepo = { roots = { "/path/to/monorepo/branches/*" } },
      },
      -- Optional: customize what happens when you pick a project
      -- on_select = function(path)
      --   vim.cmd('cd ' .. vim.fn.fnameescape(path))
      --   require('telescope.builtin').find_files({ cwd = path })
      -- end
      on_select = function(path)
        local ok_tb, tb = pcall(require, 'telescope.builtin')
        vim.cmd('cd ' .. vim.fn.fnameescape(path))
        if ok_tb then
          tb.find_files({ cwd = path })
        else
          vim.cmd('edit ' .. vim.fn.fnameescape(path))
        end
      end
    })

    -- Load the Telescope extension (enables :Telescope project_picker ...)
    require("telescope").load_extension("project_picker")

    -- Keymaps (aggregate vs per-source)
    vim.keymap.set("n", "<leader>pp", function()
      require("telescope").extensions.project_picker.projects()
    end, { desc = "Pick project (all sources)" })

    vim.keymap.set("n", "<leader>ps", function()
      require("telescope").extensions.project_picker.sources()
    end, { desc = "Pick source, then project" })

    -- Or jump directly to a specific source
    vim.keymap.set("n", "<leader>pd", function()
      require("telescope").extensions.project_picker.source({ name = "dynatrace_projects" })
    end, { desc = "Pick project from dynatrace_projects" })
  end,
}
