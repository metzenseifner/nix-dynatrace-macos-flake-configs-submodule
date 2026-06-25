-- Single source of truth for the active Rust LSP backend.
--
-- Algebraic shape:
--   Backend := "rust_analyzer" | "rustaceanvim"
--   current : () -> Backend          -- marker file > $NVIM_RUST_BACKEND > default
--   set     : Backend -> Bool        -- writes marker file (IO)
--   toggle  : () -> Maybe Backend
--   suppresses_lspconfig : ServerName -> Bool
--
-- Plain English: both backends spawn a rust-analyzer client, so running
-- them together attaches duplicate clients to every Rust buffer. They
-- are mutually exclusive and two consumers must agree on which one wins:
--
--   1. the Nix-LSP loader (plugins/lsp/nvim-lspconfig.lua) skips its
--      rust_analyzer registration when suppresses_lspconfig() is true.
--   2. the rustaceanvim lazy spec (plugins/rust/rustaceanvim.lua) is
--      `enabled` only when current() == "rustaceanvim".
--
-- The choice is read once at startup. Switching writes a marker file and
-- requires a Neovim restart — a clean startup each way is reliable,
-- whereas hot-swapping live LSP clients is fragile. The marker file is
-- per-machine (under stdpath("data")), so it overrides a per-host
-- default optionally provided via $NVIM_RUST_BACKEND.

local M = {}

M.backends = {
  rust_analyzer = "rust_analyzer",
  rustaceanvim = "rustaceanvim",
}

M.default = M.backends.rust_analyzer

local function marker_path()
  return vim.fn.stdpath("data") .. "/rust_backend"
end

local function is_valid(name)
  return name ~= nil and M.backends[name] ~= nil
end

local function read_marker()
  local fd = io.open(marker_path(), "r")
  if not fd then return nil end
  local line = fd:read("*l")
  fd:close()
  if line then line = line:gsub("%s+", "") end
  if line == "" then return nil end
  return line
end

-- current : () -> Backend. Resolution order: marker file, then
-- environment, then the compiled-in default. Invalid values at any layer
-- are ignored so a stale marker or typo can never wedge the editor.
function M.current()
  local from_file = read_marker()
  if is_valid(from_file) then return from_file end
  local from_env = vim.env.NVIM_RUST_BACKEND
  if is_valid(from_env) then return from_env end
  return M.default
end

function M.set(name)
  if not is_valid(name) then
    vim.notify("rust_backend: unknown backend '" .. tostring(name) .. "'", vim.log.levels.ERROR)
    return false
  end
  local fd, err = io.open(marker_path(), "w")
  if not fd then
    vim.notify("rust_backend: cannot write marker: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  fd:write(name .. "\n")
  fd:close()
  return true
end

local function other(name)
  if name == M.backends.rustaceanvim then return M.backends.rust_analyzer end
  return M.backends.rustaceanvim
end

function M.toggle()
  local target = other(M.current())
  if M.set(target) then return target end
  return nil
end

-- True when `server_name` is the lspconfig-managed rust-analyzer and an
-- alternative backend currently owns rust-analyzer instead. The loader
-- calls this to decide whether to register the server.
function M.suppresses_lspconfig(server_name)
  return server_name == "rust_analyzer" and M.current() ~= M.backends.rust_analyzer
end

local function notify_restart(target)
  vim.notify(
    "Rust backend -> " .. target .. ". Restart Neovim to apply.",
    vim.log.levels.WARN
  )
end

if not vim.g.__rust_backend_command then
  vim.g.__rust_backend_command = true
  vim.api.nvim_create_user_command("RustBackend", function(opts)
    local arg = opts.args
    if arg == nil or arg == "" then
      vim.notify(
        "Rust backend (active): " .. M.current()
        .. "\nUse :RustBackend rust_analyzer | rustaceanvim | toggle",
        vim.log.levels.INFO
      )
      return
    end
    local target = arg == "toggle" and other(M.current()) or arg
    if M.set(target) then notify_restart(target) end
  end, {
    nargs = "?",
    complete = function()
      return { M.backends.rust_analyzer, M.backends.rustaceanvim, "toggle" }
    end,
    desc = "Show or set the active Rust LSP backend (restart to apply)",
  })
end

return M
