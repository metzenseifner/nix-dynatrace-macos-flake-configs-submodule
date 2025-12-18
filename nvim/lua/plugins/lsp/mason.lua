return {
  "williamboman/mason.nvim",
  cmd = "Mason",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  build = {
    -- set env var or run nvm use version to enable npm upon changes
  },
  opts = {
    ensure_installed = {
      --"stylua",
      --"shfmt",
      --"flake8",
    },
    --automatic_installation = true, --unnecessary because we call setup with ensure_installed
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
