-- lazy.nvim only descends into plugin subdirectories that expose an
-- `init.lua`; a directory without one is skipped wholesale. This file is
-- that entry point for plugins/rust, importing the lazy specs that live
-- beside it.
--
-- Only rustaceanvim is a lazy plugin spec. null-ls-rust-postformat.lua
-- returns a none-ls *source* (not a plugin) and is require()d directly by
-- plugins/lsp/null-ls/init.lua, so it must NOT be imported here.
return {
  { import = "plugins/rust/rustaceanvim" },
}
