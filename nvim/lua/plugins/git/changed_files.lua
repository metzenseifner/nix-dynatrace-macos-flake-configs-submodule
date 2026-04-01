-- lua/plugins/git-keymaps.lua

local function git(cmd)
  vim.notify("git: " .. cmd, vim.log.levels.DEBUG)
  local result = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return result
end

local function git_first(cmd)
  local result = git(cmd)
  if not result or #result == 0 or result[1] == "" then
    return nil
  end
  return result[1]
end

local function detect_remote()
  return git_first("git remote") or "origin"
end

local function detect_default_branch(remote)
  local ref = git_first(
    "git symbolic-ref refs/remotes/" .. remote .. "/HEAD 2>/dev/null"
  )

  if ref then
    return ref:gsub("refs/remotes/" .. remote .. "/", "")
  end

  local candidates = { "main", "master", "develop", "trunk" }
  for _, name in ipairs(candidates) do
    local check = "git show-ref --verify --quiet refs/remotes/" .. remote .. "/" .. name
    vim.fn.system(check)
    if vim.v.shell_error == 0 then
      return name
    end
  end

  return nil
end

local function detect_merge_base(remote, branch)
  local ref = remote .. "/" .. branch
  return git_first("git merge-base HEAD " .. ref)
end

local function changed_files(base_ref)
  return git("git diff --name-only " .. base_ref .. " HEAD") or {}
end

local function open_picker(title, files)
  if #files == 0 then
    vim.notify("No changed files found", vim.log.levels.INFO)
    return
  end

  vim.notify("Found " .. #files .. " changed file(s)", vim.log.levels.INFO)

  require("telescope.pickers").new({}, {
    prompt_title = title,
    finder = require("telescope.finders").new_table({ results = files }),
    sorter = require("telescope.config").values.generic_sorter({}),
    previewer = require("telescope.config").values.file_previewer({}),
  }):find()
end

local function pick_changed_since_last_commit()
  open_picker(
    "Changed files since HEAD~1",
    changed_files("HEAD~1")
  )
end

local function pick_changed_since_merge_base()
  local remote = detect_remote()
  vim.notify("Detected remote: " .. remote, vim.log.levels.INFO)

  local branch = detect_default_branch(remote)
  if not branch then
    vim.notify("Could not detect default branch", vim.log.levels.ERROR)
    return
  end
  vim.notify("Detected default branch: " .. branch, vim.log.levels.INFO)

  local base = detect_merge_base(remote, branch)
  if not base then
    vim.notify("Could not determine merge base", vim.log.levels.ERROR)
    return
  end
  vim.notify("Merge base: " .. base:sub(1, 10), vim.log.levels.INFO)

  open_picker(
    "Changed files since " .. branch .. " (" .. base:sub(1, 10) .. ")",
    changed_files(base)
  )
end

return {
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    init = function()
      vim.keymap.set("n", "<leader>gh", pick_changed_since_last_commit, {
        desc = "Files changed since HEAD~1",
      })
      vim.keymap.set("n", "<leader>ghh", pick_changed_since_merge_base, {
        desc = "Files changed since merge base",
      })
    end,
  },
}
