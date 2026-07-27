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
      -- rust_keymaps : (BufNr) -> IO (). Rewires a handful of generic LSP
      -- keys to rustaceanvim's `:RustLsp` command layer *only* in the rust
      -- buffer the client just attached to. The grouped/nested code actions
      -- rust-analyzer emits (extract, generate, macro expand, runnables) are
      -- not expandable through stock vim.lsp.buf.code_action, so the global
      -- <leader>ca (config/keymap/init.lua) is shadowed here per-buffer while
      -- left intact for every other language.
      local function rust_keymaps(bufnr)
        local function rustlsp(subcommand)
          return function() vim.cmd.RustLsp(subcommand) end
        end
        local map = function(lhs, fn, desc)
          vim.keymap.set("n", lhs, fn, { buffer = bufnr, desc = desc })
        end
        map("<leader>ca", rustlsp("codeAction"), "rustaceanvim: grouped code actions")
        map("<leader>rr", rustlsp("runnables"), "rustaceanvim: runnables")
        map("<leader>rd", rustlsp("debuggables"), "rustaceanvim: debuggables")
        map("<leader>rm", rustlsp("expandMacro"), "rustaceanvim: expand macro")
        map("<leader>re", rustlsp("explainError"), "rustaceanvim: explain error")
        map("<leader>rc", rustlsp("openCargo"), "rustaceanvim: open Cargo.toml")
        map("<leader>rp", rustlsp("parentModule"), "rustaceanvim: parent module")
        map("K", rustlsp({ "hover", "actions" }), "rustaceanvim: hover actions")
      end

      vim.g.rustaceanvim = {
        server = {
          default_settings = rust_analyzer_settings(),
          on_attach = function(_, bufnr)
            rust_keymaps(bufnr)
          end,
        },
      }
    end,
  },
}
