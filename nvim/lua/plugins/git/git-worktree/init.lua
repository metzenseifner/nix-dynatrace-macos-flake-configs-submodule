-- key bindings in telescope here here:
-- https://github.com/ThePrimeagen/git-worktree.nvim/blob/f247308e68dab9f1133759b05d944569ad054546/lua/telescope/_extensions/git_worktree.lua#L218-L221
return {
  -- replace with polarmutex/git-worktree.nvim fork
  "ThePrimeagen/git-worktree.nvim",
  --commit = "94684a6e0ca6898d450b3b46c09b3fca1b3d591f",
  --commit = "f247308",
  branch = 'update-for-telescope-api',
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
      if op == Worktree.Operations.Delete then
        require('notify').notify("Deleted " .. P(metadata.path))
      end
    end)

    return {
      change_directory_command = "cd",  -- default: "cd",
      update_on_change = true,          -- default: true,
      update_on_change_command = "e .", -- default: "e .",
      clearjumps_on_change = true,      -- default: true,
      autopush = false,                 -- default: false,
    }
  end
}
