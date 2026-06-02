-- Mason is retained as an EXPLICIT FALLBACK only.
--
-- The canonical providers for language servers live in
-- `modules/neovim/lsps/` as sibling pairs:
--
--   <name>.nix  — declares the package(s) (e.g. pkgs.lua-language-server)
--   <name>.lua  — holds the lspconfig settings table
--
-- nvim-lspconfig.lua scans NIX_LSP_DIR (exported by the wrapper flake)
-- at startup, dofile()s every .lua, and merges the configs. Whatever
-- it finds is stripped from mason-lspconfig's ensure_installed below,
-- so Mason only touches servers NOT yet declared in modules/neovim/lsps.
--
-- The LspAttach audit (config/lsp_provider_audit.lua) emits a
-- WARN-level vim.notify whenever an attached server's binary resolves
-- outside /nix/store/ — typically a Mason-installed binary under
-- ~/.local/share/nvim/mason/. Treat that warning as a TODO: add the
-- matching <name>.nix + <name>.lua under modules/neovim/lsps/.
return {
  "williamboman/mason.nvim",
  cmd = "Mason",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  build = {
    -- set env var or run nvm use version to enable npm upon changes
  },
  opts = {
    ensure_installed = {
      -- Intentionally empty: declare LSPs/formatters in Nix instead
      -- (modules/neovim/lsps/<name>.{nix,lua}). Mason auto-installs
      -- only what mason-lspconfig requests for servers NOT covered by
      -- that directory (i.e. fallbacks).
      --"stylua",
      --"shfmt",
      --"flake8",
    },
    --automatic_installation = true, --unnecessary because we call setup with ensure_installed
    -- Prevent mason from managing jdtls (use nix instead)
    ui = {
      check_outdated_packages_on_open = true,
      border = "rounded",
    },
  },
  ---@param opts MasonSettings | {ensure_installed: string[]}
  config = function(_, opts)
    require("mason").setup(opts)
    local mr = require("mason-registry")
    for _, tool in ipairs(opts.ensure_installed) do
      local p = mr.get_package(tool)
      if not p:is_installed() then
        p:install()
      end
    end

    local registry = require "mason-registry"

    registry:on(
      "package:handle",
      vim.schedule_wrap(function(pkg, handle)
        vim.notify(string.format("Installing Mason package: %s", pkg.name), vim.log.levels.INFO)
      end)
    )

    registry:on(
      "package:install:success",
      vim.schedule_wrap(function(pkg, handle)
        vim.notify(string.format("Successfully installed Mason package: %s", pkg.name), vim.log.levels.DEBUG)
      end)
    )

    registry:on(
      "package:install:failure",
      vim.schedule_wrap(function(pkg, handle)
        vim.notify(string.format("Failed to install Mason package: %s", pkg.name), vim.log.levels.ERROR)
      end)
    )
  end,
}
