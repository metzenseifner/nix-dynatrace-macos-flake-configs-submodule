-- Create autocmd to check jdtls availability when opening Java files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    vim.defer_fn(function()
      if vim.fn.executable('jdtls') == 0 then
        vim.notify(
          "⚠️  jdtls not found in PATH!\n\n" ..
          "Please activate your nix development shell:\n" ..
          "  nix develop .#jdk-21\n\n" ..
          "Your Java LSP will not work until jdtls is available.\n\n" ..
          "Run :JdtlsCheckEnv to diagnose issues.",
          vim.log.levels.WARN,
          {
            title = "jdtls Missing",
            timeout = 8000,
          }
        )
      end
    end, 500) -- Delay to avoid spam on startup
  end,
})

-- Load jdtls helpers
local jdtls_helpers = require('plugins.lsp.jdtls-helpers')
jdtls_helpers.setup_commands()
jdtls_helpers.setup_handlers()

return {
  --- @type vim.lsp.Config
  jdtls = {
    mason = false, -- Disable mason management for jdtls
    cmd = {
      'jdtls',     -- Use jdtls directly from nix shell environment
    },
    init_options = {
      extendedClientCapabilities = {
        classFileContentsSupport = true,
      },
    },
    on_attach = function(client, bufnr)
      vim.notify(
        string.format("✓ jdtls attached successfully"),
        vim.log.levels.INFO
      )

      -- Check for formatter config
      local jdtls_helpers = require('plugins.lsp.jdtls-helpers')
      vim.defer_fn(function()
        jdtls_helpers.detect_formatter_config()
      end, 1000)

      -- Add buffer-local keymaps for jdtls utilities
      local opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set('n', '<leader>jc', ':JdtlsCleanCaches<CR>',
        vim.tbl_extend('force', opts, { desc = 'Clean jdtls/Gradle caches' }))
      vim.keymap.set('n', '<leader>jn', ':JdtlsCheckNetwork<CR>',
        vim.tbl_extend('force', opts, { desc = 'Check network/VPN' }))
      vim.keymap.set('n', '<leader>je', ':JdtlsCheckEnv<CR>',
        vim.tbl_extend('force', opts, { desc = 'Check jdtls environment' }))
      vim.keymap.set('n', '<leader>js', ':JdtlsCheckSync<CR>',
        vim.tbl_extend('force', opts, { desc = 'Check Gradle sync status' }))
    end,
    on_init = function(client)
      if vim.fn.executable('jdtls') == 0 then
        vim.notify(
          "⚠️  jdtls not found in PATH!\n\nPlease activate nix shell:\n  nix develop .#jdk-21",
          vim.log.levels.WARN,
          { timeout = 5000 }
        )
        return false
      end

      -- Auto-detect Eclipse formatter config in project root
      local root_dir = client.config.root_dir or vim.fn.getcwd()
      local formatter_files = {
        { name = "mc-code-style.xml",      profile = "MC-GoogleStyle" },
        { name = ".eclipse-formatter.xml", profile = nil },
        { name = "eclipse-formatter.xml",  profile = nil },
        { name = "formatter.xml",          profile = nil },
      }

      for _, fmt in ipairs(formatter_files) do
        local formatter_path = root_dir .. "/" .. fmt.name
        if vim.fn.filereadable(formatter_path) == 1 then
          -- Update client settings to use this formatter
          local settings = client.config.settings or {}
          settings.java = settings.java or {}
          settings.java.format = settings.java.format or {}
          settings.java.format.enabled = true
          settings.java.format.settings = {
            url = "file://" .. formatter_path,
            profile = fmt.profile,
          }

          -- Notify LSP to update configuration
          client.notify("workspace/didChangeConfiguration", { settings = settings })

          vim.defer_fn(function()
            vim.notify(
              string.format(
                "Eclipse Formatter Style Guide Detected\n\n" ..
                "File: %s\n" ..
                (fmt.profile and ("Profile: %s\n\n") or "\n") ..
                "jdtls will use this for formatting.\n\n" ..
                "Format code with:\n" ..
                "  • Visual mode: gq\n" ..
                "  • Normal mode: :lua vim.lsp.buf.format()",
                fmt.name,
                fmt.profile or ""
              ),
              vim.log.levels.INFO,
              { title = "jdtls Formatter Config", timeout = 6000 }
            )
          end, 2000)

          return true
        end
      end

      -- No formatter found - notify user
      vim.defer_fn(function()
        vim.notify(
          "ℹ️  No Eclipse Formatter Found\n\n" ..
          "Searched for:\n" ..
          "  • mc-code-style.xml\n" ..
          "  • eclipse-formatter.xml\n" ..
          "  • .eclipse-formatter.xml\n\n" ..
          "Using jdtls default formatting.",
          vim.log.levels.INFO,
          { title = "jdtls Formatter", timeout = 4000 }
        )
      end, 2000)

      return true
    end,
    settings = {
      java = {
        -- Enable verbose Gradle sync logging
        trace = {
          server = "verbose"
        },
        -- Formatter settings will be auto-detected and configured in on_init
        configuration = {
          -- Use Java 17 for Gradle builds (from JAVA_17_HOME env var set by nix shell)
          -- This allows jdtls to run on Java 21 while Gradle uses Java 17
          runtimes = vim.fn.getenv("JAVA_17_HOME") ~= vim.NIL and {
            {
              name = "JavaSE-17",
              path = vim.fn.getenv("JAVA_17_HOME"),
              default = true,
            }
          } or {},
        },
        import = {
          gradle = {
            -- Tell Gradle import to use Java 17 (compatible with Gradle 7.6.6)
            java = {
              home = vim.fn.getenv("GRADLE_JAVA_HOME") ~= vim.NIL and vim.fn.getenv("GRADLE_JAVA_HOME") or vim.NIL,
            },
            -- Disable wrapper checksum validation that's causing snapshot download errors
            wrapper = {
              checksums = {},
            },
          },
        },
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
