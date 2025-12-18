return {
  --- @type vim.lsp.Config
  jdtls = {
    cmd = {
      'nix',
      'develop',
      '--command',
      'jdtls',
    },
    init_options = {
      extendedClientCapabilities = {
        classFileContentsSupport = true,
      },
    },
    settings = {
      java = {
        autobuild = {
          enabled = true,
        },
        progressReports = {
          enabled = true,
        },
        compile = {
          nullAnalysis = {
            mode = "automatic",
          },
        },
        imports = {
          gradle = {
            enabled = true,
            wrapper = {
              enabled = true,
              checksums = {
                {
                  sha256 = '7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172',
                  allowed = true,
                },
              },
            },
          },
        },
      },
    },
  }
}

-- local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
-- local workspace_dir = vim.fn.stdpath('data') .. '/java/' .. project_name
--
-- -- https://www.andersevenrud.net/neovim.github.io/lsp/configurations/jdtls/
-- return {
--   --jdtls = {
--   --  start_or_attach({
--   --    cmd = cmd,
--   --    settings = lsp_settings,
--   --    on_attach = jdtls_on_attach,
--   --    capabilities = cache_vars.capabilities,
--   --    root_dir = jdtls.setup.find_root(root_files),
--   --    flags = {
--   --      allow_incremental_sync = true,
--   --    },
--   --    init_options = {
--   --      bundles = path.bundles,
--   --    },
--   --  })
--   --}
--   jdtls = { -- setup
--     --cmd_env = {
--     --  GRADLE_HOME = "/usr/share/gradle-7.1.1",
--     --  JAR = vim.NIL
--     --},
--     filetypes = { "java" },
--     -- The command that starts the language server
--     -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
--     init_options = {
--       jvm_args = {},
--       workspace = "/home/runner/workspace"
--     },
--     cmd = {
--       --"/Library/Java/JavaVirtualMachines/temurin-22.jdk/Contents/Home/bin/java", -- Or the absolute path '/path/to/java11_or_newer/bin/java'
--       "/opt/homebrew/opt/openjdk@11/bin/java",
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
--     --root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),
--     root_dir = function(fname)
--       for _, patterns in ipairs(root_files) do
--         local root = util.root_pattern(unpack(patterns))(fname)
--         if root then
--           return root
--         end
--       end
--       return vim.fn.getcwd()
--     end,
--
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
--   }
-- }
