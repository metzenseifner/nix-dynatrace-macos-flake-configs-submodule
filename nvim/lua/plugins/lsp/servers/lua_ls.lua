return {
  lua_ls = {
    -- mason = false, -- set to false if you don't want this server to be installed with mason
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            -- Add lazy.nvim plugins to workspace
            "${3rd}/luv/library",
          },
        },
        completion = {
          callSnippet = "Replace",
        },
        telemetry = {
          enable = false,
        },
      },
    },
  }
}
