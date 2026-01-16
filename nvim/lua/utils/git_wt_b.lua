-- Shared module for creating worktrees using the git wt-b alias
-- This is the single source of truth for worktree creation
local M = {}

-- Create a worktree using your git wt-b alias
-- on_complete: callback function called after successful creation with (worktree_path, git_root)
function M.create_worktree_wt_b(branch_name, base_branch, on_complete)
  base_branch = base_branch and base_branch ~= "" and base_branch or "origin/main"
  
  -- Get git root first
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end
  
  -- Use git wt-b alias directly - this is the single source of truth
  -- The alias handles: fetch, path creation, worktree creation
  local cmd = string.format('git wt-b "%s" "%s"', branch_name, base_branch)
  
  vim.notify("Creating worktree via git wt-b alias...", vim.log.levels.INFO)
  
  local stdout_data = {}
  local stderr_data = {}
  
  vim.fn.jobstart(cmd, {
    cwd = git_root,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data, _)
      if data then
        vim.list_extend(stdout_data, data)
      end
    end,
    on_stderr = function(_, data, _)
      if data then
        vim.list_extend(stderr_data, data)
      end
    end,
    on_exit = function(_, exit_code, _)
      if exit_code ~= 0 then
        local stderr_msg = table.concat(stderr_data, "\n")
        vim.notify(
          string.format("Failed to create worktree (exit %d):\n%s", exit_code, stderr_msg),
          vim.log.levels.ERROR
        )
        return
      end
      
      -- Parse the worktree path from the alias output
      -- The alias outputs the path, so extract it
      local stdout_msg = table.concat(stdout_data, "\n")
      local worktree_path = nil
      
      -- The git wt-b alias creates branches/<path>, extract it from output
      for line in stdout_msg:gmatch("[^\r\n]+") do
        local path_match = line:match("branches/([%w_%-/]+)")
        if path_match then
          worktree_path = "branches/" .. path_match
          break
        end
      end
      
      -- Fallback: compute path if we couldn't parse it (same logic as alias)
      if not worktree_path then
        local path = branch_name:gsub("/", "_")
        worktree_path = "branches/" .. path
      end
      
      vim.notify("Worktree created: " .. worktree_path, vim.log.levels.INFO)
      
      -- Wait for filesystem to settle before callback
      vim.defer_fn(function()
        local full_path = git_root .. "/" .. worktree_path
        if vim.fn.isdirectory(full_path) == 1 then
          if on_complete then
            on_complete(worktree_path, git_root)
          end
        else
          vim.notify(
            "Worktree created but directory not found: " .. full_path,
            vim.log.levels.WARN
          )
        end
      end, 150)  -- Slightly longer delay for reliability
    end,
  })
end

-- Interactive prompt for creating a worktree with your git wt-b alias
-- on_complete: optional callback called after successful creation with (worktree_path, git_root)
function M.prompt_and_create(on_complete)
  vim.ui.input({ prompt = "Branch name (e.g., ASDY-0000_scope_random-name): " }, function(branch_name)
    if not branch_name or branch_name == "" then
      return
    end

    vim.ui.input({ 
      prompt = "Base branch (default: origin/main): ",
      default = "origin/main"
    }, function(base_branch)
      M.create_worktree_wt_b(branch_name, base_branch, on_complete)
    end)
  end)
end

return M
