-- LSP provider provenance audit.
--
-- Algebraic shape:
--   audit : LspClient -> Maybe Warning
--   audit(c) = Warning(c) iff resolve(c.cmd[0]) ∉ /nix/store/...
--
-- Plain English: on every LspAttach, take the server's executable
-- (cmd[1]), resolve it via $PATH, and if the resolved location does NOT
-- live in /nix/store/, emit a warning suggesting the user add the
-- package to modules/neovim/flake.nix.
--
-- Rationale: Mason is intentionally retained as a fallback for tools we
-- have not declared in Nix yet (see plugins/lsp/mason.lua). When that
-- fallback fires we want it surfaced loudly, so Nix stays the default
-- and Mason stays the exception.
--
-- The check is purely about the resolved path's prefix — it does not
-- consult the Nix-managed LSP set in modules/neovim/lsps/. That makes
-- the audit truthful even if the on-disk set and the actual provider
-- temporarily drift (e.g. a stale binary is still resolving from
-- ~/.local/share/nvim/mason/ after a Nix package was added).

local M = {}

local NIX_STORE_PREFIX = "/nix/store/"
local MASON_PATH_FRAGMENT = "/mason/"

local function classify(exe)
  if exe == "" or exe == nil then
    return "unresolved"
  end
  if exe:sub(1, #NIX_STORE_PREFIX) == NIX_STORE_PREFIX then
    return "nix"
  end
  if exe:find(MASON_PATH_FRAGMENT, 1, true) then
    return "mason"
  end
  return "other"
end

-- Memoize so a noisy buffer with many attaches only warns once per server.
local already_warned = {}

local function audit(client)
  if not client or client.name == "null-ls" or client.name == "none-ls" then
    return
  end
  if already_warned[client.name] then
    return
  end

  local cmd = client.config and client.config.cmd
  local exe_name
  if type(cmd) == "table" and type(cmd[1]) == "string" then
    exe_name = cmd[1]
  else
    -- Some servers configure cmd as a function; we can't statically
    -- introspect those, so skip silently rather than warn incorrectly.
    return
  end

  local resolved = vim.fn.exepath(exe_name)
  local kind = classify(resolved)

  if kind == "nix" then
    return -- canonical case, nothing to do
  end

  already_warned[client.name] = true

  local origin_msg
  if kind == "mason" then
    origin_msg = "Mason fallback at:\n  " .. resolved
  elseif kind == "other" then
    origin_msg = "Non-Nix system path:\n  " .. resolved
  else
    origin_msg = "Unresolved binary: " .. tostring(exe_name)
  end

  vim.notify(
    string.format(
      "LSP '%s' is not provided by Nix.\n%s\n\n" ..
      "Suggestion: add a sibling pair under\n" ..
      "  modules/neovim/lsps/%s.{nix,lua}\n" ..
      "(the .nix declares the package, the .lua holds lspconfig\n" ..
      "settings). The loader picks it up automatically and Mason will\n" ..
      "stop managing this server.",
      client.name, origin_msg, client.name
    ),
    vim.log.levels.WARN,
    { title = "LSP provenance" }
  )
end

function M.setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("NixLspProvenance", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      audit(client)
    end,
  })

  -- Manual command to re-run the audit across all currently attached
  -- clients (resets the per-server "already warned" memo first).
  vim.api.nvim_create_user_command("LspProvenanceAudit", function()
    already_warned = {}
    local clients = vim.lsp.get_clients and vim.lsp.get_clients() or vim.lsp.get_active_clients()
    for _, client in ipairs(clients) do
      audit(client)
    end
  end, { desc = "Re-check whether attached LSP servers come from /nix/store" })
end

return M
