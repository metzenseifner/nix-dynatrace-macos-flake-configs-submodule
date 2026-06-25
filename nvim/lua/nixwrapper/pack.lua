-- Discovery of plugins delivered by the Nix wrapper's pack tree.
--
-- The wlib (BirdeeHub/nix-wrapper-modules) Neovim wrapper installs every
-- plugin listed in `settings.specs.<name>.data` (see
-- modules/neovim/flake.nix) as a pack plugin:
--
--   pack/<vendor>/start/<name>/                  -- plugin source
--
-- lazy.nvim aggressively normalises &runtimepath during startup and will
-- (a) clone its own copy of a plugin unless its spec sets `dir =` to the
-- wrapper path, and (b) drop any pack dir that no lazy spec names. This
-- module is the shared, semantically-named way to resolve that path so
-- spec files can compose it via `dir = find_pack_plugin('<name>')`.
--
-- Algebraic shape:
--   find_pack_plugin : Name -> Maybe Path
--
-- Plain English: scan every entry in &packpath for `pack/*/start/<name>`
-- and return the first hit, falling back to the wrapper prefix recovered
-- from $NVIM_SYSTEM_RPLUGIN_MANIFEST, then to a basename match on rtp.
-- Returns nil when not present (e.g. running this config outside the Nix
-- wrapper), in which case the caller's lazy spec falls back to cloning.

local M = {}

local function glob_first_dir(pattern)
  for _, hit in ipairs(vim.fn.glob(pattern, false, true)) do
    if vim.fn.isdirectory(hit) == 1 then return hit end
  end
  return nil
end

function M.find_pack_plugin(name)
  -- 1. Standard: anywhere on &packpath under pack/*/start/<name>.
  for _, base in ipairs(vim.split(vim.o.packpath, ',')) do
    if base ~= '' then
      local hit = glob_first_dir(base .. '/pack/*/start/' .. name)
      if hit then return hit end
    end
  end
  -- 2. wlib / nixpkgs neovim wrapper fallback. The wrapper script execs
  -- into the unwrapped binary, so vim.v.progpath points at the *base*
  -- store path (no nvim-packdir). The wrapper exports
  --   NVIM_SYSTEM_RPLUGIN_MANIFEST=<wrapper-prefix>/nvim-rplugin.vim
  -- which gives us the wrapper prefix; its sibling `nvim-packdir/`
  -- holds the actual pack tree (start/<plugin>, opt/<plugin>).
  local manifest = vim.env.NVIM_SYSTEM_RPLUGIN_MANIFEST
  if manifest and manifest ~= '' then
    local wrapper_prefix = vim.fn.fnamemodify(manifest, ':h')
    local hit = glob_first_dir(wrapper_prefix .. '/nvim-packdir/pack/*/start/' .. name)
    if hit then return hit end
  end
  -- 3. Last resort: anything currently on rtp whose basename matches.
  for _, p in ipairs(vim.api.nvim_list_runtime_paths()) do
    if vim.fn.fnamemodify(p, ':t') == name and vim.fn.isdirectory(p) == 1 then
      return p
    end
  end
  return nil
end

return M
