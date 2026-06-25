-- rustaceanvim: alternative Rust backend, selectable at runtime.
--
-- Delivery: the plugin source is installed by the Nix wrapper as a pack
-- plugin (modules/neovim/flake.nix, settings.specs.rustaceanvim). We pin
-- lazy's `dir =` at that path (resolved via the shared nixwrapper.pack
-- discovery) so lazy adopts the Nix-built copy instead of cloning. When
-- run outside the wrapper, dir is nil and lazy clones from the repo.
--
-- Selection: this spec is `enabled` only when the active backend is
-- rustaceanvim (config/rust_backend.lua). When it is the default
-- rust_analyzer, lazy leaves the pack dir off &runtimepath, so
-- rustaceanvim's ftplugin never runs and the lspconfig-managed
-- rust_analyzer owns Rust buffers instead. Switching is :RustBackend
-- followed by a restart.
--
-- Configuration: rustaceanvim is configured by setting `vim.g.rustaceanvim`
-- *before* the plugin loads (hence `init`, not `config`). We reuse the
-- single source of truth for rust-analyzer tuning — the same settings
-- table the Nix-LSP loader feeds to lspconfig, living at
-- $NIX_LSP_DIR/rust_analyzer.lua — so both backends drive rust-analyzer
-- identically. The rust-analyzer binary is already on $PATH from
-- modules/neovim/lsps/rust_analyzer.nix regardless of which backend wins.

local find_pack_plugin = require('nixwrapper.pack').find_pack_plugin
local rust_backend = require('config.rust_backend')

-- rust_analyzer_settings : () -> Map "rust-analyzer" Settings
-- Lifts the inner ["rust-analyzer"] map from the shared lspconfig file so
-- rustaceanvim's server.default_settings matches the rust_analyzer path.
local function rust_analyzer_settings()
  local dir = vim.env.NIX_LSP_DIR
  if not dir or dir == '' then return {} end
  local ok, mod = pcall(dofile, dir .. '/rust_analyzer.lua')
  if ok and type(mod) == 'table' and mod.rust_analyzer and mod.rust_analyzer.settings then
    return mod.rust_analyzer.settings
  end
  return {}
end

return {
  {
    "mrcjkb/rustaceanvim",
    dir = find_pack_plugin("rustaceanvim"),
    ft = { "rust" },
    enabled = function()
      return rust_backend.current() == rust_backend.backends.rustaceanvim
    end,
    init = function()
      vim.g.rustaceanvim = {
        server = {
          default_settings = rust_analyzer_settings(),
        },
      }
    end,
  },
}
