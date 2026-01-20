-- none-ls (rebranded null-ls) and and other lsp servers provide sources for dianogstics, formatting, etc
-- When removing an lsp server (not from null-ls), it is important to MasonUninstall it
-- otherwise it will continue to start up by virtual of load-buffer hooks.
--
-- null-ls servers correctly map the source name if implemented as such, otherwise
-- show null-ls if unspecified
-- remember to add null-ls formatting (for auto correction) and diagnostics servers for messages if both desired
--formatters
--The recommended approach is to use the newer vim.lsp.buf.format API, which makes it easy to select which server you want to use for formatting:
--How to select (or not select) formatters when formatting, see
--https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts
--Short answer is to supply a callback function to textDocumentformatting that takes a bufnr and calls vim.lsp.buf.format
--vim.lsp.buf.format({filter = function(client) return eturn client.name == "null-ls" end, bufnr = bufnr, })
--Also see https://neovim.discourse.group/t/automatically-choose-one-language-server-to-format-code-when-using-multiple-language-servers/800/3
-- TODO Commented out to try conform.nvim below
return {
  {
    "nvimtools/none-ls.nvim", -- Consider replaceing null-ls with stevearc/conform.nvim for formatting (conform is a formatter plugin)
    -- See :NullLsInfo
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason.nvim", "nvimtools/none-ls-extras.nvim" },
    config = function(_, opts)
      local null_ls = require("null-ls")
      null_ls.setup({
        debug = false, -- possible culprit for sluggish slow typing in neovim!
        on_attach = function(client, bufnr)
          --vim.notify(vim.inspect(client))
          local filetype = vim.bo.filetype
          local sources = vim.tbl_map(function(v) return string.format("%s: %s", v.name, v.generator.opts.command) end,
            require 'null-ls.sources'.get_available(filetype))
          vim.schedule_wrap(
            vim.notify(
              string.format(
                "null-ls attached to buffer with sources:\n -  %s\n\nRun :NullLsLog for logs.\nRun :NullLsInfo for path to log.",
                table.concat(sources, '\n -  '), vim.log.levels.DEBUG)
            )
          )
          -- Enable format on save when supported by server
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({
              group = augroup,
              buffer = bufnr
            })
            vim.notify(vim.inspect(client), 'debug')
            vim.notify(string.format('null-ls client "%s" supports textDocument/formatting', client.name), 'debug')
            --if client.capabilities.textDocument.codeAction.codeActionLiteralSupport.codeActionKind.valueSet["source.organizeImports"] then
            --vim.api.nvim_clear_autocmds({ group = "myautoformat", buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.notify("[null-ls] Applying formatting: " .. client.name, "debug")
                vim.lsp.buf.format({ async = false }) -- blocks until changes have been applied or times out
              end,
            })
          end
          if client.name == "null-ls" then -- name is always null-ls in this context
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
                local action_to_call = "source.organizeImports"
                params.context = { only = { action_to_call } }
                local method = 'textDocument/codeAction' -- query includes custom actions not required by the LSP spec
                local result = vim.lsp.buf_request_sync(bufnr, method, params, 1000)
                local debugRequestResponse = function(result) vim.notify("buf_request_sync:" .. vim.inspect(result)) end
                --debugRequestResponse(result)
                --for _, res in pairs(result or {}) do
                --  for _, r in pairs(res.result or {}) do
                --    if r.kind == "source.removeUnusedImports.ts" thenstand
                --      if r.edit then
                --        vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding) --vim.lsp.get_client_by_id(1).offset_encoding)
                --      end
                --    end
                --  end
                --end
              end,
            })
          end
        end,
        root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git",
          "dtp.config.ts"),
        notify_format = "[null-ls] %s",
        diagnostics_format = "null-ls #{m}",
        -- Note that setting autostart = true is unnecessary (and unsupported),
        -- as null-ls will always attempt to attach to buffers automatically if
        -- you've configured and registered sources.
        -- Built-in sources have access to a special method, with(), which modifies a subset of the source's default options
        sources = {
          -- See https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
          -- TODO these binaries automatically WARNING: If any missing, this will cause an ambiguous async error (plenary)
          --nls.builtins.formatting.fish_indent,
          --null_ls.builtins.diagnostics.luacheck,
          --null_ls.builtins.diagnostics.markdownlint,
          --nls.builtins.diagnostics.fish,
          --nls.builtins.formatting.stylua,
          --nls.builtins.formatting.shfmt,
          --nls.builtins.diagnostics.flake8,


          --require("plugins.golang.null-ls-goimports_reviser"), -- causes issues


          null_ls.builtins.formatting.prettier.with({
            filetypes = { "typescript", "typescriptreact", "javascript" },
            -- see https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/builtins/formatting/prettier.lua#L38
            -- see https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/HELPERS.md#generator_factory
            --env = {
            --  PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/utils/linter-config/.prettierrc.json"),
            --},
            -- on_attach does not seem to work here
            --on_attach = function(client, bufnr)
            --  vim.api.nvim_create_augroup("myautoformat", { clear = true })
            --  if client.supports_method("textDocument/formatting") then
            --    --vim.api.nvim_clear_autocmds({ group = "myautoformat", buffer = bufnr })
            --    vim.api.nvim_create_autocmd("BufWritePre", {
            --      group = "autoformat",
            --      buffer = bufnr,
            --      callback = function()
            --        vim.notify("null-ls formatting: Applying prettier.")
            --        vim.lsp.buf.format({ async = false })
            --      end,
            --    })
            --  end
            --end
            -- LSP options (e.g. formatting options) are available as params.options
            command = "prettier", -- docker run -i --rm -v $(pwd):$(pwd) -w $(pwd) prettier $@
            -- TODO Failure notification if prettier fails to execute
            extra_args = function(params)
              -- from https://github.com/jose-elias-alvarez/null-ls.nvim/discussions/1389#discussioncomment-4905919
              if vim.fs.dirname(vim.fs.find({ '.prettierrc', '.prettierrc.js' }, { upward = false })[1]) then
                vim.notify("Found prettier config file. Using its parameters.", "debug")
                return params.options -- exit early if we have a .prettierrc config
              end

              local default_cli_options = {
                "--arrow-parens=" .. "avoid",
                "--no-bracket-spacing",
                "--bracket-same-line=" .. "false",
                "--embedded-language-formatting=" .. "auto",
                "--end-of-line=" .. "lf",
                "--html-whitespace-sensitivity=" .. "strict",
                "--insert-pragma=" .. "false",
                "--require-pragma=" .. "false",
                --"--jsx-bracket-same-line = false,
                "--jsx-single-quote=" .. "false", -- I do not like single quotes!
                "--single-quote=" .. "false",
                "--use-tabs=" .. "false",
                "--print-width=" .. "80",
                "--prose-wrap=" .. "preserve",
                "--quote-props=" .. "consistent",
                "--semi=" .. "true",
                "--single-attribute-per-line=" .. "false",
                "--tab-width=" .. "2",
                "--trailing-comma=" .. "all",
              }
              vim.notify("Using prettier defaults: " .. table.concat(default_cli_options, ","), "debug")
              return default_cli_options -- your extra args serving as defaults if no .prettierrc
            end,
            --args = {"x", "prettier"} -- overrides lsp args completely, prefer extra_args to append existing args with a new set of args
            --env = {
            --    PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/utils/linter-config/.prettierrc.json"),
            --  },
          }),
          --
          -- eslint diagnostics seems flaky, so I enabled the eslint lsp plugin
          -- disabled
          --require("none-ls.code_actions.eslint_d").with({
          --  filetypes = {
          --    "javascript",
          --    "javascriptreact",
          --    "javascript.jsx",
          --    "typescript",
          --    "typescriptreact",
          --    "typescript.tsx",
          --    "vue",
          --    "svelte",
          --    "astro"
          --  },
          --}),
          require("none-ls.code_actions.eslint_d").with({
            condition = function(utils)
              return utils.root_has_file({
                ".eslintrc",
                ".eslintrc.js",
                ".eslintrc.cjs",
                ".eslintrc.yaml",
                ".eslintrc.yml",
                ".eslintrc.json",
                "eslint.config.js",
                "eslint.config.mjs",
                "eslint.config.cjs",
              })
            end,
            filetypes = {
              "javascript",
              "javascriptreact",
              "javascript.jsx",
              "typescript",
              "typescriptreact",
              "typescript.tsx",
              "vue",
              "svelte",
              "astro"
            },
          }),

          -- eslint_d diagnostics seem to work better, but are flaky with branch changes and major file changes. Also it stays running between buffers.
          -- requires eslint_d on PATH and turned out to be faster, but lifecycle of node process is outside of neovims control so it can be annoying to restart to restart
          --nls.builtins.diagnostics.eslint_d.with({
          --  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
          --  filter = function(diagnostic)
          --    -- ignore prettier warnings from eslint-plugin-prettier
          --    return diagnostic.code ~= "prettier/prettier"
          --  end,
          --}),
          --env = {
          --  es6 = true
          --}
          -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md#diagnostics_format-string
          -- #{m}: message
          -- #{s}: source name (defaults to null-ls if not specified)
          -- #{c}: code (if available)
          --diagnostics_format = "[#{c}] #{m} (#{s})"
          --diagnostic_config = {
          --  -- see :help vim.diagnostic.config()
          --  underline = true,
          --  virtual_text = false,
          --  signs = true,
          --  update_in_insert = false,
          --  severity_sort = true,
          --},
          --require("none-ls.formatting.eslint_d").with({
          --  filetypes = { "javascript",
          --    "javascriptreact",
          --    "javascript.jsx",
          --    "typescript",
          --    "typescriptreact",
          --    "typescript.tsx",
          --    "vue",
          --    "svelte",
          --    "astro" }
          --}),                                            -- requires none-ls-extras.nvim
          require("none-ls.diagnostics.eslint_d").with({ -- requires none-ls-extras.nvim
            condition = function(utils)
              return utils.root_has_file({
                ".eslintrc",
                ".eslintrc.js",
                ".eslintrc.cjs",
                ".eslintrc.yaml",
                ".eslintrc.yml",
                ".eslintrc.json",
                "eslint.config.js",
                "eslint.config.mjs",
                "eslint.config.cjs",
              })
            end,
            filetypes = {
              "javascript",
              "javascriptreact",
              "javascript.jsx",
              "typescript",
              "typescriptreact",
              "typescript.tsx",
              "vue",
              "svelte",
              "astro"
            },
            filter = function(diagnostic)
              -- ignore prettier warnings from eslint-plugin-prettier
              return diagnostic.code ~= "prettier/prettier"
            end,
          }),

          -- null_ls.builtins.formatting.eslint.with({ -- slow performance
          --   filter = function(diagnostic)
          --     return diagnostic.code ~= "prettier/prettier"
          --   end,
          -- }),

          --nls.builtins.formatting.eslint_d.with({
          --  filter = function(diagnostic)
          --    return diagnostic.code ~= "prettier/prettier"
          --  end,
          --}),

          --null_ls.builtins.code_actions.eslint,
          --nls.builtins.code_actions.eslint_d,
          null_ls.builtins.diagnostics.ansiblelint,
          --null_ls.builtins.diagnostics.eslint_d, -- unneeded with tsserver
          --null_ls.builtins.diagnostics.ansiblelint,
          null_ls.builtins.formatting.npm_groovy_lint.with({
            command = "bun x npm-groovy-lint"
          }), -- npm i -g npm-groovy-lint
          --null_ls.builtins.formatting.goimports, -- auto add or remove go imports: does both gopls imports and gopls format
          require("plugins.golang.null-ls-golangci-lint"), -- golangci-lint v2 diagnostics from nix flake
          --null_ls.builtins.code_actions.gomodifytags, -- add tags to json (covered by gopher.nvim)
          --null_ls.builtins.code_actions.impl, -- generate method stubs for implementing an interface (covered by gopher.nvim)
        },
        --border = nil,
        --cmd = { "nvim" },
        --debounce = 250,
        --debug = false,
        default_timeout = 10000,
        --diagnostic_config = {},
        --diagnostics_format = "#{m}",
        --log_level = "warn",
        --notify_format = "[null-ls] %s",
      })
    end
  },
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      require("mason-null-ls").setup({
        ensure_installed = nil,
        automatic_installation = true,
      })
    end
  },
}
