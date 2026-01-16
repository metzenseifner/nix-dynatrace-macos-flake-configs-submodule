-- key bindings in telescope here here:
-- https://github.com/ThePrimeagen/git-worktree.nvim/blob/f247308e68dab9f1133759b05d944569ad054546/lua/telescope/_extensions/git_worktree.lua#L218-L221
return {
  -- replace with polarmutex/git-worktree.nvim fork
  "ThePrimeagen/git-worktree.nvim",
  commit = "94684a6e0ca6898d450b3b46c09b3fca1b3d591f",
  --commit = "f247308",
  -- branch = 'update-for-telescope-api', -- DISABLED: branch doesn't exist on remote
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
  config = function()
    local Worktree = require("git-worktree")

    -- op = Operations.Switch, Operations.Create, Operations.Delete
    -- metadata = table of useful values (structure dependent on op)
    --      Switch
    --          path = path you switched to
    --          prev_path = previous worktree path
    --      Create
    --          path = path where worktree created
    --          branch = branch name
    --          upstream = upstream remote name
    --      Delete
    --          path = path where worktree deleted

    Worktree.on_tree_change(function(op, metadata)
      if op == Worktree.Operations.Switch then
        print("Switched from " .. metadata.prev_path .. " to " .. metadata.path)
      end
      if op == Worktree.Operations.Create then
        vim.notify("Worktree created: " .. metadata.path, vim.log.levels.INFO)
      end
      if op == Worktree.Operations.Delete then
        require('notify').notify("Deleted " .. P(metadata.path))
      end
    end)

    -- Use shared wt-b module (single source of truth)
    local wt_b = require("utils.git_wt_b")
    
    -- Custom function to create worktree using git wt-b alias
    local function create_worktree_wt_b_style()
      wt_b.prompt_and_create(function(worktree_path, git_root)
        -- After creation completes, switch to the new worktree
        vim.defer_fn(function()
          Worktree.switch_worktree(worktree_path)
        end, 50)
      end)
    end

    -- Enhanced git worktree picker with Ctrl-n to create and auto-refresh
    local function show_worktrees_with_create()
      local actions = require("telescope.actions")
      
      require("telescope").extensions.git_worktree.git_worktrees({
        attach_mappings = function(prompt_bufnr, map)
          -- Add Ctrl-n to create new worktree from within picker
          map("i", "<C-n>", function()
            actions.close(prompt_bufnr)
            -- Use shared wt-b module with completion callback to reopen picker
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
          end)
          map("n", "<C-n>", function()
            actions.close(prompt_bufnr)
            -- Use shared wt-b module with completion callback to reopen picker
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
          end)
          
          return true
        end,
      })
    end

    ----------------------------------------------------------------------
    --                       Git Worktrees Keymap                       --
    ----------------------------------------------------------------------
    vim.keymap.set("n", "<leader>pgw", show_worktrees_with_create,
      { desc = "Pick Work Tree (Ctrl-n to create)" })
    vim.keymap.set("n", "<leader>pwt", show_worktrees_with_create,
      { desc = "Pick Work Tree (Ctrl-n to create)" })
    vim.keymap.set("n", "<leader>gwn", create_worktree_wt_b_style,
      { desc = "Create New Git Worktree (wt-b style)" })
    vim.keymap.set("n", "<leader>gwc", ":lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>",
      { desc = "Create New Git Worktree (default)" })

    Worktree.setup({
      change_directory_command = "cd",  -- default: "cd",
      update_on_change = true,          -- default: true,
      update_on_change_command = "e .", -- default: "e .",
      clearjumps_on_change = true,      -- default: true,
      autopush = false,                 -- default: false,
    })
  end
}
