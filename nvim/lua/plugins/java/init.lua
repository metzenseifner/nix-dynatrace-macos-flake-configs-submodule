-- If you started neovim within `~/dev/xy/project-1` this would resolve to `project-1`
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
-- Provide unique workspace dirs for each project
local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace/" .. project_name) -- vim.fn.stdpath('data') .. '/java/' .. project_name

-- Eclipse JDT Language Server JDTLS
--
--------------------------------------------------------------------------------
--             Use this OR the nvim_lsp.jdtls.setup, but NOT BOTH             --
--                 Using this (nvim-jdtls) has more features                  --
--------------------------------------------------------------------------------

return {
  "mfussenegger/nvim-jdtls",
  enabled = false,
  ft = "java",
  config = function(_, _)
    local bundles = {
      --local debug_install_path = require("mason-registry").get_package("java-debug-adapter"):get_install_path()
      vim.fn.expand("~/.local/share/nvim/mason/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar"),
    }
    vim.list_extend(bundles, vim.split(vim.fn.glob("~/.local/share/nvim/mason/share/java-test/*.jar", false), "\n"))

    local config = {
      init_options = {
        bundles = bundles
      },

      cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/jdtls"), "-data", workspace_dir },
      root_dir = vim.fs.dirname(vim.fs.find({ ".gradlew", ".git", "mvn" }, { upward = true })[1]),

      -- settings is part of a JavaConfiguration
      settings = { -- TODO contains some stuff specific to a project that should be abstracted
        java = {
          --trace = {
          --  server = "verbose"
          --},
          configuration = {
            runtimes = {}
          },
          signatureHelp = { enabled = true },
          format = { enabled = true },
          saveActions = { organizeImports = false },
          --import = {
          --  gradle = {
          --    enabled = true
          --  },
          --  maven = {
          --    enabled = true
          --  },
          --  exclusions = {
          --    "**/node_modules/**",
          --    "**/.metadata/**",
          --    "**/archetype-resources/**",
          --    "**/META-INF/maven/**",
          --    "/**/test/**"
          --  }
          --},
          completion = { -- https://www.andersevenrud.net/neovim.github.io/lsp/configurations/jdtls/#javacompletionimportorder
            importOrder = { "java", "javax", "org", "com", "com.dynatrace" },
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.mockito.Mockito.*"
            },
          },
        }
      }
    }


    -- These require java-debug and vscode-java-test bundles, see install steps in this README further below.
    vim.keymap.set("n", "<leader>vc", function() require 'jdtls'.test_class() end, { desc = "Test class (DAP)" })
    vim.keymap.set("n", "<leader>vm", function() require 'jdtls'.test_nearest_method() end,
      { desc = "Test method (DAP)" })

    require("jdtls").start_or_attach(config)
  end
  -- config = function(_, _)
  --   -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
  --   local config = {
  --     -- The command that starts the language server
  --     -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  --     cmd = {
  --       "/Library/Java/JavaVirtualMachines/temurin-22.jdk/Contents/Home/bin/java", -- Or the absolute path '/path/to/java11_or_newer/bin/java'
  --       --"java",
  --       "-Declipse.application=org.eclipse.jdt.ls.core.id1",
  --       "-Dosgi.bundles.defaultStartLevel=4",
  --       "-Declipse.product=org.eclipse.jdt.ls.core.product",
  --       "-Dlog.protocol=true",
  --       "-Dlog.level=ALL",
  --       "-Xms1g",
  --       "--add-modules=ALL-SYSTEM",
  --       "--add-opens",
  --       "java.base/java.util=ALL-UNNAMED",
  --       "--add-opens",
  --       "java.base/java.lang=ALL-UNNAMED",
  --       --
  --       "-jar",
  --       vim.fn.stdpath('data') ..
  --       "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher.cocoa.macosx.aarch64_1.2.900.v20240129-1338.jar",
  --       "-configuration", vim.fn.stdpath('data') .. "/mason/packages/jdtls/config_mac_arm",
  --       "-data", workspace_dir
  --     },
  --     -- One dedicated LSP server & client will be started per unique root_dir
  --     root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),

  --     -- Here you can configure eclipse.jdt.ls specific settings
  --     -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  --     -- for a list of options
  --     settings = {
  --       --------------------------------------------------------------------------------
  --       --                            Java Language Level                             --
  --       --                            for Gradle or Maven                             --
  --       --------------------------------------------------------------------------------
  --       -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  --       -- And search for `interface RuntimeOption`
  --       -- enum ExecutionEnvironment {
  --       --        J2SE_1_5 = 'J2SE-1.5',
  --       --        JavaSE_1_6 = 'JavaSE-1.6',
  --       --        JavaSE_1_7 = 'JavaSE-1.7',
  --       --        JavaSE_1_8 = 'JavaSE-1.8',
  --       --        JavaSE_9 = 'JavaSE-9',
  --       --        JavaSE_10 = 'JavaSE-10',
  --       --        JavaSE_11 = 'JavaSE-11',
  --       --        JavaSE_12 = 'JavaSE-12',
  --       --        JavaSE_13 = 'JavaSE-13',
  --       --        JavaSE_14 = 'JavaSE-14',
  --       --        JavaSE_15 = 'JavaSE-15',
  --       --        JavaSE_16 = 'JavaSE-16',
  --       --        JavaSE_17 = 'JavaSE-17',
  --       --        JavaSE_18 = 'JavaSE-18',
  --       --        JAVASE_19 = 'JavaSE-19'
  --       --
  --       --}
  --       -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
  --       java = {
  --         configuration = {
  --           runtimes = {
  --             {
  --               name = "JavaSE-11",
  --               --path = "/usr/lib/jvm/java-11-openjdk/",
  --               path = "/Library/Java/JavaVirtualMachines/temurin-22.jdk/Contents/Home/bin"
  --             },
  --             {
  --               name = "JavaSE-17",
  --               path = "/opt/homebrew/opt/openjdk@17/bin",
  --             },
  --           }
  --         }
  --       },
  --     },

  --     -- Language server `initializationOptions`
  --     -- You need to extend the `bundles` with paths to jar files
  --     -- if you want to use additional eclipse.jdt.ls plugins.
  --     --
  --     -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --     --
  --     -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  --     init_options = {
  --       bundles = {}
  --     },
  --   }
  --   -- This starts a new client & server,
  --   -- or attaches to an existing client & server depending on the `root_dir`.
  --   require('jdtls').start_or_attach(config)
  --end
}
