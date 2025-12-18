-- Open/reveal the current file in the OS file browser
local portable = require('config.portable')

local function open_in_file_browser()
  local file = vim.api.nvim_buf_get_name(0)
  if file == nil or file == "" then
    vim.notify("No file associated with the current buffer.", vim.log.levels.WARN)
    return
  end

  -- Normalize absolute paths
  local abs = vim.fn.fnamemodify(file, ":p")
  local sys = vim.loop.os_uname().sysname or ""
  local is_win = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 or sys:match("Windows")
  local is_mac = sys == "Darwin"

  -- Prefer selecting/revealing the file when the OS supports it
  if is_mac then
    -- macOS: Reveal in Finder
    local cmd = { "open", "-R", abs }
    if portable.has("open") then
      if vim.fn.has("nvim-0.10") == 1 and type(vim.system) == "function" then
        vim.system(cmd, { detach = true }, function() end)
      else
        vim.fn.jobstart(cmd, { detach = true })
      end
    else
      portable.notify_once("open_macos", "macOS 'open' command not found", vim.log.levels.WARN)
    end
    return
  elseif is_win then
    -- Windows: Select in Explorer
    local winpath = abs:gsub("/", "\\")
    local cmd = { "explorer", "/select,", winpath }
    if portable.has("explorer") then
      if vim.fn.has("nvim-0.10") == 1 and type(vim.system) == "function" then
        vim.system(cmd, { detach = true }, function() end)
      else
        vim.fn.jobstart(cmd, { detach = true })
      end
    else
      portable.notify_once("explorer_win", "Windows 'explorer' command not found", vim.log.levels.WARN)
    end
    return
  end

  -- Other platforms: open the containing directory in the default file manager.
  local dir = vim.fn.fnamemodify(abs, ":h")

  -- If available (Neovim 0.10+), this uses the platform's default opener.
  if vim.ui and type(vim.ui.open) == "function" then
    local ok, err = pcall(vim.ui.open, dir)
    if not ok then
      vim.notify("Failed to open directory: " .. tostring(err), vim.log.levels.ERROR)
    end
    return
  end

  -- Fallback to common CLIs if vim.ui.open is not available
  local opener_cmd
  if portable.has("xdg-open") then
    opener_cmd = { "xdg-open", dir }
  elseif portable.has("gio") then
    opener_cmd = { "gio", "open", dir }
  elseif portable.has("open") then
    -- Some *BSDs and environments have `open`
    opener_cmd = { "open", dir }
  else
    portable.notify_once("no_opener", "No suitable file opener found (xdg-open/gio/open).", vim.log.levels.WARN)
    return
  end

  if vim.fn.has("nvim-0.10") == 1 and type(vim.system) == "function" then
    vim.system(opener_cmd, { detach = true }, function() end)
  else
    vim.fn.jobstart(opener_cmd, { detach = true })
  end
end

-- Keymap: <leader><leader>f
-- Make sure you've set your mapleader, e.g. `vim.g.mapleader = " "`
vim.keymap.set("n", "<leader><leader>f", open_in_file_browser, {
  desc = "Open/reveal current file in the OS file browser",
  silent = true,
})
