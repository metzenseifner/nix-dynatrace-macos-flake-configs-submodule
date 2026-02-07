local lsp_flags = {
  debounce_text_changes = 150,
}

-- For null_ls none_ls
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local all_diagnostics_to_quickfix = function()
  -- override the callback for diagnostics and manually add them to the quick fix list
  -- populate quickfix list with diagnostics local method = "textDocument/publishDiagnostics" local default_callback = vim.lsp.callbacks[method] vim.lsp.callbacks[method] = function(err, method, result, client_id) default_callback(err, method, result, client_id) if result and result.diagnostics then local item_list = {} for _, v in ipairs(result.diagnostics) do local fname = result.uri table.insert(item_list, { filename = fname, lnum = v.range.start.line + 1, col = v.range.start.character + 1; text = v.message; }) end local old_items = vim.fn.getqflist() for _, old_item in ipairs(old_items) do local bufnr = vim.uri_to_bufnr(result.uri) if vim.uri_from_bufnr(old_item.bufnr) ~= result.uri then table.insert(item_list, old_item) end end vim.fn.setqflist({}, ' ', { title = 'LSP'; items = item_list; }) end end
end

local is_null_ls_formatting_enabled = function(bufnr)
  local file_type = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local generators = require("null-ls.generators").get_available(
    file_type,
    require("null-ls.methods").internal.FORMATTING
  )
  return #generators > 0
end

-- Formatting LSP request  example
--   request(0, 'workspace/executeCommand', {
--    command = 'eslint.applyAllFixes',
--    arguments = {
--      {
--        uri = vim.uri_from_bufnr(bufnr),
--        version = lsp.util.buf_versions[bufnr],
--      },
--    },
--  })

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },

  dependencies = {
    { "folke/neoconf.nvim",               cmd = "Neoconf",           config = true },
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "luvit-meta/library",              words = { "vim%.uv" } },
          { path = "${3rd}/luv/library",              words = { "vim%.loop", "vim%.uv" } },
          -- Index all lazy.nvim plugins for type inference
          { path = vim.fn.stdpath("data") .. "/lazy", words = {} },
        },
      },
    },
    { "Bilal2453/luvit-meta",             lazy = true },
    { 'diogo464/kubernetes.nvim',         description = "for yamlls" },
    { "mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    {
      "hrsh7th/cmp-nvim-lsp", -- this is a nvim-cmp source module also known as nvim-lsp
      dependencies = {
        { "hrsh7th/nvim-cmp" }
      }
      -- https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources
    },
  },

  ---@class PluginLspOpts
  opts = {
    -- This opts key has values for just about everything needed to
    -- configure lsp. It does not actually configure things, preferring
    -- declarative style definitions followed by delayed execution.

    -- options for vim.diagnostic.config() but handle them in another file ignoring these
    -- But this design is prob better: uses lazy.nvim to hotload changes
    --diagnostics = {
    --  underline = true,
    --  update_in_insert = false,
    --  virtual_text = { spacing = 4, prefix = "●" },
    --  severity_sort = true,
    --},
    -- Automatically format on save
    autoformat = false,
    virtual_lines = true,
    -- options for vim.lsp.buf.format
    -- `bufnr` and `filter` is handled by the LazyVim formatter,
    -- but can be also overridden when specified
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
    -- TODO:
    -- I am confused where the servers come from since I have all of my setup commented out...TODO figure this out! ANSWER I THINK: :MasonUninstallAll will remove them. If they exist, they will be started even when not configured here.
    -- Here is what I did: I commented out everything in this servers block. I ran :MasonUninstallAll and restarted Nvim editing a typescript file. Indeed only null-ls started.
    -- I then uncommented my tsserver block here, and got the following log messages with an error:
    -- [mason-lspconfig.nvim] installing tsserver
    -- Installing Mason package: typescript-language-server
    -- [mason-lspconfig.nvim] tsserver was successfully installed
    -- lspconfig applying setup to server tsserver
    -- ...share/nvim/lazy/nvim-lspconfig/lua/lspconfig/configs.lua:61: command.fn: expected function, got nil
    -- Successfully installed Mason package: typescript-language-server

    -- you can do any additional lsp server setup here
    -- return true if you don't want this server to be setup with lspconfig
    ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
    setup = {
      -- This setup is for declarative (also non-interpreted) config only. It means
      -- referencing other packages including itself lazily is not possible.
      -- If you need that, use the config block which accepts a function(pluginname, optstable).
      -- Specify * to use this function as a fallback for any server
      --tsserver = function(server, opts)
      --  P(opts)
      -- -- opts.on_attach(function(client, bufnr)
      -- --   vim.notify("Yep, you setup tsserver with an on_attach")
      -- -- end
      --end,

      ["*"] = function(server, opts)
        opts.on_attach = function(client, bufnr)
          -- Called globally if not overridden in opts.setup[server]
          vim.notify(
            string.format("Generic on_attach called for the language server %s\ncmd: %s\ncwd: %s", client.name,
              vim.inspect(client.config.cmd), vim.inspect(client.config.cmd_cwd)), 'debug')
        end
      end,

      -- WORKING (achieve auto remove unused imports on save with non-standard LSP command)
      tsserver = function(server, opts)
        opts.init_options = {
          preferences = {
            includeInlayParameterNameHints = 'all',
            includeInlayVariableTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          }
        }
        opts.on_attach = function(client, bufnr)
          -- Vim executes all matching autocommands in the order that you specify them.
          if client.name == "tsserver" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                --vim.notify(client.name .. ": OrganizeImports called.")
                --vim.cmd("OrganizeImports") -- removes unused imports, fixes order but conflicts sometimes with eslint
                --typescript.removeUnusedImports || typescript.sortImports || typescript.organizeImports || 
                -- remoteUnusedImports:
                -- - https://github.com/typescript-language-server/typescript-language-server/blob/master/src/organize-imports.ts#L40C7-L40C33
                -- - https://github.com/typescript-language-server/typescript-language-server/blob/b224b878652438bcdd639137a6b1d1a6630129e4/src/utils/types.ts#L25
                -- - https://github.com/typescript-language-server/typescript-language-server/blob/b224b878652438bcdd639137a6b1d1a6630129e4/src/lsp-server.ts#L778
                -- - https://github.com/typescript-language-server/typescript-language-server/blob/b224b878652438bcdd639137a6b1d1a6630129e4/src/lsp-server.ts#L880
                -- - why we pass path to buffer as arg[0] https://github.com/typescript-language-server/typescript-language-server/blob/b224b878652438bcdd639137a6b1d1a6630129e4/src/lsp-server.ts#L881
                -- - additional args: https://github.com/typescript-language-server/typescript-language-server/blob/b224b878652438bcdd639137a6b1d1a6630129e4/src/lsp-server.ts#L888
                --vim.lsp.buf.execute_command({ command = "_typescript.organizeImports", arguments = { vim.fn.expand("%:p") }, async =false })

                -- Fix problem with organizeImports and take advantage of  removeUsedImports
                local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
                params.context = { only = { "source.removeUnusedImports" } }
                local method = 'textDocument/codeAction'
                local result = vim.lsp.buf_request_sync(bufnr, method, params, 1000)
                --vim.notify("buf_request_sync:" .. vim.inspect(result))
                for _, res in pairs(result or {}) do
                  for _, r in pairs(res.result or {}) do
                    if r.kind == "source.removeUnusedImports.ts" then
                      if r.edit then
                        vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding) --vim.lsp.get_client_by_id(1).offset_encoding)
                      end
                    end
                  end
                end
              end,
            })
          end
        end
      end,
    },
  },
  -- config callback recieves as arg[1] the lazy.nvim opts table
  ---@param opts PluginLspOpts
  config = function(_, opts)
    -- List all capabilities of the LSP
    vim.api.nvim_create_user_command("LspCapabilities", function()
      local curBuf = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_active_clients { bufnr = curBuf }
      for _, client in pairs(clients) do
        if client.name ~= "null-ls" then
          local capAsList = {}
          for key, value in pairs(client.server_capabilities) do
            if value and key:find("Provider") then
              local capability = key:gsub("Provider$", "")
              table.insert(capAsList, "- " .. capability)
            end
          end
          table.sort(capAsList) -- sorts alphabetically
          local msg = "# " .. client.name .. "\n" .. table.concat(capAsList, "\n")
          vim.notify(msg, "trace", {
            on_open = function(win)
              local buf = vim.api.nvim_win_get_buf(win)
              vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
            end,
            timeout = 14000,
          })
          vim.notify("Capabilities = " .. vim.inspect(client.server_capabilities))
        end
      end
    end, {})

    -- setup autoformat
    --require("lazyvim.plugins.lsp.format").autoformat = opts.autoformat
    -- setup formatting and keymaps
    --require("lazyvim.util").on_attach(function(client, buffer)
    --  require("lazyvim.plugins.lsp.format").on_attach(client, buffer)
    --  require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
    --end)

    -- organize_imports would be great but see https://vi.stackexchange.com/questions/41538/how-do-i-organize-imports-with-tsserver-using-neovim-lsp
    --local organize_imports = function(bufnr)
    --  --local lsp_method_name = "_typescript.organizeImports"
    --  --vim.lsp.buf_request_sync(bufnr, lsp_method_name)
    --  -- params for the request
    --  local params = {
    --    command = "_typescript.organizeImports",
    --    arguments = { vim.api.nvim_buf_get_name(bufnr) },
    --    title = ""
    --  }
    --  --local params = {
    --  --  command = "java/organizeImports", -- https://github.com/mfussenegger/nvim-jdtls/blob/master/lua/jdtls.lua#L682C15-L682C35
    --  --  arguments = { vim.api.nvim_buf_get_name(bufnr) },
    --  --  title = ""
    --  --}
    --  -- perform a syncronous request
    --  -- 500ms timeout depending on the size of file a bigger timeout may be needed
    --  vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", params, 500)
    --end
    --vim.keymap.set('n', '<leader>ff', organize_imports, { desc = "lsp.buf_request_sync organizeImports" })

    local format_buffer = function()
      vim.lsp.buf.format({
        async = true,
        filter = function(client)
          if (client.name == 'tsserver') then
            local warning = "Ignoring tsserver formatting. See formatit function in keymap.lua to change this."
            vim.notify(warning)
            return false
          end
          print('Formatting with client (format_buffer): ' .. client.name)
          vim.schedule(function()
            -- vim.schedule_wrap does not work in this context
            require("notify")(
              string.format(
                "Running: lua vim.lsp.buf.format(...) :: Formatting file on buf %s using attached client: %s", bufnr,
                client.name))
          end)
          return true
        end
      })
    end


    --shared_server_opts = {
    --  on_attach = function(client, bufnr)
    --    print("hello")
    --    require 'notify'.notify('On-attach', 'none')
    --  end,
    --}

    -- diagnostics
    --for name, icon in pairs(require("lazyvim.config").icons.diagnostics) do
    --  name = "DiagnosticSign" .. name
    --  vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
    --end
    --vim.diagnostic.config(opts.diagnostics)
    -- LSP Server Settings
    ---@type lspconfig.options
    local servers = { -- deprecated: prefer separate files for each config
      --efm = {}, -- similar to null-ls / zero-ls
      --jdtls = {enable = false},
      --["java-test"] = {},
      --["java-debug-adapter"] = {},
      --yamlls = {}, -- configured in servers/yamlls.lua
      gopls = require("plugins.golang.lsp-gopls"),
      -- golangci-lint-langserver =
      -- CAVEAT: names of mason packages do not match names of servers
      -- hls = { -- disabled to avoid using mason version and using ghcup; also
      -- haskell-tools includes LSP language server based on your projects version
      --   mason = false,
      --   cmd = { "haskell-language-server-wrapper-2.2.0.0", "--lsp" },
      --   haskell = {
      --     -- Setting this to true could have a performance impact on large mono repos.
      --     checkProject = true,
      --     -- root_dir = { '.git' }
      --     --filetypes = { 'haskell', 'lhaskell', 'cabal' },
      --     --cabalFormattingProvider = "cabalfmt",
      --     formattingProvider = "ormolu",
      --     single_file_support = true,
      --   }
      -- }, -- haskell
      --java_language_server = {},
    }

    local add_server = function(servers)
      return function(server_module_name)
        return vim.tbl_deep_extend('error',
          servers
          , require('plugins.lsp.servers.' .. server_module_name))
      end
    end

    --servers = add_server(servers)('eslint')
    servers = add_server(servers)('yamlls')
    servers = add_server(servers)('tsserver')
    -- servers = add_server(servers)('nixfmt')
    servers = add_server(servers)('nil')
    -- servers = add_server(servers)('nix-eval-lsp') -- Disabled: nix_eval_lsp not in PATH
    servers = add_server(servers)('jdtls')
    servers = add_server(servers)('terraformls')
    servers = add_server(servers)('tflint')
    servers = add_server(servers)('jsonls')
    servers = add_server(servers)('ansiblels')
    servers = add_server(servers)('pyright')
    servers = add_server(servers)('marksman')
    servers = add_server(servers)('kotlin_language_server')
    servers = add_server(servers)('bashls')
    servers = add_server(servers)('vimls')
    servers = add_server(servers)('docker_compose_language_service')
    servers = add_server(servers)('groovyls')
    servers = add_server(servers)('lua_ls')

    -- Configure LSP to use nvim-cmp as a completion engine
    local capabilities = require("cmp_nvim_lsp").default_capabilities() -- This is a nvim-cmp source for the built-in lsp client.

    -- imperative start populating the server_opts table that will be passed to
    -- lspconfig

    -- implements mason-lspconfig.setup_handlers arg[0] callback
    local function setup(server)
      if server == "null-ls" or server == "none-ls" then
        return
      end
      if server == "tsserver" then -- TODO remove workaround from https://github.com/williamboman/mason.nvim/issues/1784 once closed
        server = "ts_ls"
      end
      local server_opts = vim.tbl_deep_extend("force", {
        -- appy capabilities (k,v) to server object (here we merge our nvim-cmp completion capabilities into each server's capabilities)
        -- before we pull the trigger (call object.setup on them)
        capabilities = vim.deepcopy(capabilities),
        -- Workaround for https://giter.vip/neovim/neovim/issues/26520
        --capabilities = vim.lsp.protocol.make_client_capabilities(),
        --{
        --  workspace = {
        --    didChangeWatchedFiles = {
        --      dynamicRegistration = false
        --    }
        --  }
        --}
      }, servers[server] or {})


      -- Trying to exclude certain servers but still get mason to autoinstall them
      --if server_opts["enable"] == false then
      --  vim.notify("Disabled in LSP Config: " .. server)
      --  return
      --end

      -- Apply opts table to function at opts.setup.<masonservername> to (server, server_opts)
      if opts.setup[server] then
        if opts.setup[server](server, server_opts) then
          return
        end
        -- Apply opts table to function at opts.setup["*"] to (server, server_opts)
      elseif opts.setup["*"] then -- What does this do? Matches the asterisk in opts table, custom catch-all
        if opts.setup["*"](server, server_opts) then
          return
        end
      end
      -- Apply fully-customized server_opts to each server we have configured
      -- Debug: show what settings we're applying
      if server == "yamlls" then
        vim.notify(string.format("Applying yamlls config with %d schemas",
          vim.tbl_count(server_opts.settings.yaml.schemas or {})), vim.log.levels.INFO)
      end
      vim.lsp.config(server, server_opts)
      vim.lsp.enable(server)
      -- it is technically possible to override servers here:
      -- require("lspconfig")["server_name"] = function() require'rust-tools'.setup {} end
    end

    local have_mason, mason_lspconfig = pcall(require, "mason-lspconfig")
    local available = have_mason and mason_lspconfig.get_available_servers() or {}

    local ensure_installed = {} ---@type string[]
    for server, server_opts in pairs(servers) do
      if server_opts then
        server_opts = server_opts == true and {} or server_opts
        -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
        if server_opts.mason == false or not vim.tbl_contains(available, server) then
          -- Call custom setup function
          setup(server)
        else
          ensure_installed[#ensure_installed + 1] = server
        end
      end
    end

    if have_mason then
      -- Filter out jdtls from mason management (handled by nix)
      local mason_servers = vim.tbl_filter(function(s)
        return s ~= "jdtls"
      end, ensure_installed)

      if #mason_servers ~= #ensure_installed then
        vim.notify("jdtls excluded from mason (using nix environment)", vim.log.levels.INFO)
      end

      mason_lspconfig.setup({ ensure_installed = mason_servers })
      -- Manually call setup for each mason-installed server
      for _, server in ipairs(ensure_installed) do
        setup(server)
      end
    end

    --------------------------------------------------------------------------------
    --                               Global Keymap                                --
    --------------------------------------------------------------------------------
    -- Requires gopls via nvim-lspconfig and Telescope installed
    vim.keymap.set('n', 'gr', function()
      require('telescope.builtin').lsp_references({ include_declaration = false })
    end, { desc = 'Show references with Telescope' })

    -- Disabled as seems less useful than the entire workspace search without the keystroke delay
    --vim.keymap.set('n', 'gs', require('telescope.builtin').lsp_document_symbols, {desc="Find/Search symbol within current document (buffer)"})

    vim.keymap.set('n', 'gs', function()
      --if you want to filter by symbol type: tb.lsp_document_symbols({ symbols = { 'function', 'method' } })
      require('telescope.builtin').lsp_dynamic_workspace_symbols()
    end, { desc = "Find/Search symbol within the entire workspace. (live search)" })

    -- intentional duplicate symbol
    vim.keymap.set('n', 'S', function()
      --if you want to filter by symbol type: tb.lsp_document_symbols({ symbols = { 'function', 'method' } })
      require('telescope.builtin').lsp_dynamic_workspace_symbols()
    end, { desc = "Find symbol/Search symbol within the entire workspace. (live search)" })

    -- Visual/select mode: grab selection and use it as default_text
    vim.keymap.set('v', 'S', function()
      -- get selection via Lua API
      local pos_start = vim.api.nvim_buf_get_mark(0, '<')
      local pos_end   = vim.api.nvim_buf_get_mark(0, '>')

      local lines     = vim.api.nvim_buf_get_text(
        0,
        pos_start[1] - 1, pos_start[2],
        pos_end[1] - 1, pos_end[2],
        {}
      )

      local text = table.concat(lines, '\n'):gsub('^%s+', ''):gsub('%s+', '')

      require('telescope.builtin').lsp_dynamic_workspace_symbols({ default_text = text })
    end, { desc = "Workspace symbols from visual selection" })

    vim.keymap.set('n', '<leader>f', format_buffer,
      { desc = "lsp.buf.format: Auto format code in buffer. TODO provide selection menu of formatters to apply." })

    vim.keymap.set('n', 'K', function()
      vim.notify("vim.lsp.buf.hover() called.")
      vim.lsp.buf.hover()
    end, { desc = 'Show type information in hover window.' })

    vim.keymap.set('n', '<leader>pls', function()
      vim.ui.input({ prompt = "Symbol: " }, function(input)
        if input == nil then
          vim.notify("No input provided", vim.log.levels.WARN)
        end
        vim.ui.select({ "in Workspace", "in Current Buffer" }, { prompt = "Select an option:" }, function(choice)
          if choice == "in Workspace" then
            require("telescope.builtin").lsp_workspace_symbols({ query = input })
          elseif choice == "in Current Buffer" then
            require("telescope.builtin").lsp_document_symbols({ query = input })
          end
        end)
      end)
    end, { desc = "Find symbol" })
  end,
  -- Mapper.map('n', '<leader>plsw', "<cmd>lua require'telescope.builtin'.lsp_workspace_symbols({query=''})<cr>",
  --   { silent = true, noremap = true }, "Telescope-Symbols", "lsp_workspace_symbols",
  --   "pick-symbols-workspace: Picker for all symbols in workspace")
  -- Mapper.map('n', '<leader>plsb', "<cmd>lua require'telescope.builtin'.lsp_document_symbols()<cr>",
  --   { silent = true, noremap = true }, "Telescope-Symbols", "lsp_document_symbols",
  --   "pick-symbols-buffer: Picker for symbols in current buffer")
}
