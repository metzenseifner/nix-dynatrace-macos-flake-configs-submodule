-- Utility module for working with current working directory
-- Respects tab-local, window-local, and global cwd hierarchy

local M = {}

-- Get the most specific cwd (tab-local > window-local > global)
-- Returns the tab-local cwd if set, otherwise falls back to window-local, then global
function M.get()
  -- getcwd(-1, 0) gets the tab-local cwd for current tab
  -- getcwd(0, 0) gets the window-local cwd for current window
  -- getcwd() gets the global cwd
  local tab_cwd = vim.fn.getcwd(-1, 0)
  if tab_cwd and tab_cwd ~= "" and tab_cwd ~= vim.fn.getcwd() then
    return tab_cwd
  end

  local win_cwd = vim.fn.getcwd(0, 0)
  if win_cwd and win_cwd ~= "" and win_cwd ~= vim.fn.getcwd() then
    return win_cwd
  end

  return vim.loop.cwd() or vim.fn.getcwd()
end

-- Set tab-local cwd
function M.set_tab(path)
  vim.cmd('tcd ' .. vim.fn.fnameescape(path))
end

-- Set window-local cwd
function M.set_window(path)
  vim.cmd('lcd ' .. vim.fn.fnameescape(path))
end

-- Set global cwd
function M.set_global(path)
  vim.cmd('cd ' .. vim.fn.fnameescape(path))
end

-- Detect project root by leveraging LSP client's root_dir (single source of truth)
-- Falls back to git root, then parent directory
function M.detect_root(filepath, bufnr)
  if not filepath or filepath == "" then
    return nil
  end

  -- Normalize filepath
  filepath = vim.fn.fnamemodify(filepath, ":p")
  bufnr = bufnr or vim.fn.bufnr(filepath)

  -- First, try to get root_dir from active LSP clients for this buffer
  -- This is the single source of truth - uses the same logic as LSP server attachment
  if vim.api.nvim_buf_is_valid(bufnr) then
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    for _, client in ipairs(clients) do
      if client.config.root_dir then
        return client.config.root_dir
      end
    end
  end

  -- Fallback: try to find git root using lspconfig util
  local ok, lspconfig_util = pcall(require, "lspconfig.util")
  if ok then
    local git_root = lspconfig_util.find_git_ancestor(filepath)
    if git_root then
      return git_root
    end
  end

  -- Final fallback: parent directory
  return vim.fn.fnamemodify(filepath, ":h")
end

-- Smart CWD detection and setting based on current buffer
-- Uses tab-scoped cd (tcd) by default
-- Leverages LSP client's root_dir as the single source of truth
function M.detect_and_set(opts)
  opts = opts or {}
  local filepath = opts.filepath or vim.api.nvim_buf_get_name(0)
  local bufnr = opts.bufnr or vim.fn.bufnr(filepath)
  local scope = opts.scope or "tab" -- "tab", "window", or "global"

  local root = M.detect_root(filepath, bufnr)
  if not root then
    vim.notify("Could not detect project root for: " .. filepath, vim.log.levels.WARN)
    return
  end

  -- Set CWD based on scope
  if scope == "tab" then
    M.set_tab(root)
  elseif scope == "window" then
    M.set_window(root)
  elseif scope == "global" then
    M.set_global(root)
  end

  vim.notify("CWD changed to: " .. root, vim.log.levels.INFO)
  return root
end

return M
