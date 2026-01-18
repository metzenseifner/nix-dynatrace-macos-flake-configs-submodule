--- @type vim.lsp.Config
return {
  kotlin_language_server = {
    -- Force proper JSON objects:
    settings     = vim.empty_dict(),
    init_options = vim.empty_dict(),

    -- Later, when you add real settings, keep them under the 'kotlin' key:
    -- settings = {
    --   kotlin = {
    --     compiler = { jvm = { target = "default" } },
    --   },
    -- },

    -- bug with dependencies: https://github.com/fwcd/kotlin-language-server/issues/487#issuecomment-1782096036
    -- Debug
    -- lua print(vim.inspect(vim.lsp.get_clients({name='kotlin_language_server'})[1].config))
    -- Optional but helps KLS avoid edge-cases in cache path resolution
    -- init_options = {
    --   storagePath = vim.fn.stdpath("cache") .. "/kotlin-language-server"
    -- }
    -- Set bytecode version of jdk exposed in environment
    -- settings = {
    --   kotlin = {
    --     compiler = {
    --       jvm = {
    --         target = "23"
    --       }
    --     },
    --   },
    -- }
  }
}
