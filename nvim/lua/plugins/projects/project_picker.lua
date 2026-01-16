return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/project_picker.nvim",
  dependencies = { "vim-telescope/telescope.nvim" },
  config = function()
    require("project_picker").setup({
      sources = {
        -- dynatrace_projects = {
        --   roots = { "/Users/jonathan.komar/devel/dynatrace_bitbucket/15_TEAM_CARE_PROJECTS/*" },
        -- },
        ["dynatrace_bitbucket/*"] = "/Users/jonathan.komar/devel/dynatrace_bitbucket/*"
        -- add more sources here if you like
        -- monorepo = { roots = { "/path/to/monorepo/branches/*" } },
      },
      -- Optional: customize what happens when you pick a project
      -- on_select = function(path)
      --   vim.cmd('cd ' .. vim.fn.fnameescape(path))
      --   require('telescope.builtin').find_files({ cwd = path })
      -- end
      on_select = function(path)
        vim.cmd('cd ' .. vim.fn.fnameescape(path))
        
        local has_worktrees = function(project_path)
          local normalized_path = project_path:gsub('/$', '')
          local git_dir = normalized_path .. '/.git'
          local worktree_dir = git_dir .. '/worktrees'
          
          if vim.fn.isdirectory(worktree_dir) == 1 then
            local worktrees = vim.fn.readdir(worktree_dir)
            local valid_worktrees = vim.tbl_filter(function(name)
              return not vim.startswith(name, '.')
            end, worktrees)
            return #valid_worktrees > 0
          end
          return false
        end
        
        if has_worktrees(path) then
          local ok, telescope = pcall(require, 'telescope')
          if ok then
            local ext_ok = pcall(function()
              telescope.load_extension('git_worktree')
            end)
            if ext_ok then
              local actions = require("telescope.actions")
              local wt_b = require("utils.git_wt_b")
              local Worktree = require("git-worktree")
              
              -- Show worktrees with Ctrl-n to create new
              local function show_worktrees_with_create()
                telescope.extensions.git_worktree.git_worktrees({
                  attach_mappings = function(prompt_bufnr, map)
                    local function create_worktree_inline()
                      actions.close(prompt_bufnr)
                      -- Use shared wt-b module with completion callback
                      wt_b.prompt_and_create(function(worktree_path, git_root)
                        vim.defer_fn(function()
                          -- Switch to the new worktree
                          Worktree.switch_worktree(worktree_path)
                          -- Auto-refresh picker after switching
                          vim.defer_fn(function()
                            show_worktrees_with_create()
                          end, 200)
                        end, 50)
                      end)
                    end
                    
                    map("i", "<C-n>", create_worktree_inline)
                    map("n", "<C-n>", create_worktree_inline)
                    return true
                  end,
                })
              end
              
              show_worktrees_with_create()
              return
            end
          end
        end
        
        local ok_builtin, telescope_builtin = pcall(require, 'telescope.builtin')
        if ok_builtin then
          telescope_builtin.find_files({ cwd = path })
        end
      end
    })

    -- Load the Telescope extension (enables :Telescope project_picker ...)
    require("telescope").load_extension("project_picker")

    -- Keymaps (aggregate vs per-source)
    vim.keymap.set("n", "<leader>pp", function()
      require("telescope").extensions.project_picker.projects()
    end, { desc = "Pick project (all sources)" })

    -- vim.keymap.set("n", "<leader>ps", function()
    --   require("telescope").extensions.project_picker.sources()
    -- end, { desc = "Pick source, then project" })

    -- -- Or jump directly to a specific source
    -- vim.keymap.set("n", "<leader>pd", function()
    --   require("telescope").extensions.project_picker.source({ name = "dynatrace_projects" })
    -- end, { desc = "Pick project from dynatrace_projects" })
  end,
}
