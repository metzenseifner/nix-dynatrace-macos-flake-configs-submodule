local shared_rg_args = {
  "--color=never",
  "--no-heading",
  "--with-filename",
  "--line-number",
  "--column",    -- Show column numbers (1-based). This only shows the column numbers for the first match on each line.
  '--no-ignore', -- Don’t respect ignore files (.gitignore, .ignore, etc.). This implies --no-ignore-dot, --no-ignore-exclude, --no-ignore-global, no-ignore-parent and --no-ignore-vcs.
  '--hidden',    -- Search hidden files and directories.
  '--follow',    --ripgrep will follow symbolic links while traversing directories.
}
local diagnostics_telescope_action = function(prompt_bufnr_or_opts, severity)
  local opts = {}
  local should_close_picker = false

  -- Check if called from within a picker (has prompt_bufnr) or standalone
  if type(prompt_bufnr_or_opts) == "number" then
    -- Called from within a picker with prompt_bufnr
    local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr_or_opts)
    if current_picker and current_picker.finder.bufnr then
      opts.bufnr = current_picker.finder.bufnr
    end
    should_close_picker = true
  elseif type(prompt_bufnr_or_opts) == "table" then
    -- Called standalone with opts table
    opts = vim.tbl_extend("force", opts, prompt_bufnr_or_opts)
  end

  if severity ~= "all" then
    opts.severity = severity
  end

  local all_diags = vim.diagnostic.get(opts.bufnr)
  local counts = { error = 0, warn = 0, info = 0, hint = 0 }
  for _, diag in ipairs(all_diags) do
    if diag.severity == vim.diagnostic.severity.ERROR then
      counts.error = counts.error + 1
    elseif diag.severity == vim.diagnostic.severity.WARN then
      counts.warn = counts.warn + 1
    elseif diag.severity == vim.diagnostic.severity.INFO then
      counts.info = counts.info + 1
    elseif diag.severity == vim.diagnostic.severity.HINT then
      counts.hint = counts.hint + 1
    end
  end

  local severity_label
  if severity == "all" then
    severity_label = "All"
  elseif severity == vim.diagnostic.severity.ERROR then
    severity_label = "ERROR"
  elseif severity == vim.diagnostic.severity.WARN then
    severity_label = "WARN"
  elseif severity == vim.diagnostic.severity.INFO then
    severity_label = "INFO"
  elseif severity == vim.diagnostic.severity.HINT then
    severity_label = "HINT"
  else
    severity_label = tostring(severity)
  end

  opts.prompt_title = string.format("Diagnostics - Filter <C-x>[e:%d w:%d i:%d h:%d] - %s",
    counts.error, counts.warn, counts.info, counts.hint, severity_label)

  if should_close_picker then
    require("telescope.actions").close(prompt_bufnr_or_opts)
  end

  vim.schedule(function()
    require("telescope.builtin").diagnostics(opts)
  end)
end
-- Use telescope to find files on a given path
local pick_files = function(path, config)
  local path = path or vim.loop.cwd()
  require 'telescope.builtin'.find_files(object_assign({ cwd = path, hidden = true },
    require 'telescope.themes'.get_ivy({ previewer = true })))
end

return {
  "nvim-telescope/telescope.nvim", -- replaces any search plugin you use, including FZF
  event = "VeryLazy",
  --config = function() require("telescope").load_extension("mapper") end
  config = function(_, opts)
    local actions = require("telescope.actions")
    local live_grep_args_actions = require("telescope-live-grep-args.actions")
    local action_state = require("telescope.actions.state")

    -- Custom action to open Oil with selected file
    local open_in_oil = function(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      actions.close(prompt_bufnr)

      if entry then
        local filepath = entry.path or entry.filename or entry.value
        if filepath then
          -- Open oil in the directory containing the file
          local dir = vim.fn.fnamemodify(filepath, ":h")
          require("oil").open(dir)

          -- Schedule cursor positioning after oil opens
          vim.schedule(function()
            local filename = vim.fn.fnamemodify(filepath, ":t")
            -- Search for the file in the oil buffer
            vim.fn.search("\\V" .. vim.fn.escape(filename, "\\"), "w")
          end)
        end
      end
    end

    local conf =
    {
      defaults = {
        -- Default configuration for telescope goes here:
        -- config_key = value,
        vimgrep_arguments = {
          -- mandatory for ripgrep: "--no-heading", "--with-filename", "--line-number", "--column"
          "rg",
          -- Global settings here, but also see local per-call default_text to prepopulate search fields in live_grep_args
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column", -- Show column numbers (1-based). This only shows the column numbers for the first match on each line.
          --"--smart-case", # on by default, but I removed it
          -- custom additions
          -- '--no-ignore',   -- Don’t respect ignore files (.gitignore, .ignore, etc.). This implies --no-ignore-dot, --no-ignore-exclude, --no-ignore-global, no-ignore-parent and --no-ignore-vcs.
          -- '--hidden',     -- Search hidden files and directories.
          -- '--follow',      --ripgrep will follow symbolic links while traversing directories.
        },

        path_display = { "smart" },
        mappings = {
          i = {
            -- map actions.which_key to <C-h> (default: <C-/>)
            -- actions.which_key shows the mappings for your picker,
            -- e.g. git_{create, delete, ...}_branch for the git_branches picker
            -- ["<C-i>"] = "which_key",
            ["<C-h>"] = actions.which_key, -- show help in insert mode
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-g>"] = actions.move_to_top,
            ["<C-G>"] = actions.move_to_bottom,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            --["<C-q>"] = actions.send_selected_to_qflist,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<C-l>"] = actions.send_selected_to_loclist,
            ["<C-e>"] = actions.select_all,
            ["<C-n>"] = open_in_oil,
            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,
          },
          n = {
            ["esc"] = actions.close,
            ["<CR>"] = actions.select_default,
            ["?"] = actions.which_key, -- show help in normal mode
          },
        },
      },
      pickers = {
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
        diagnostics = {
          mappings = {
            i = {
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<C-x>e"] = function(prompt_bufnr)
                diagnostics_telescope_action(prompt_bufnr, vim.diagnostic.severity.ERROR)
              end,
              ["<C-x>w"] = function(prompt_bufnr)
                diagnostics_telescope_action(prompt_bufnr, vim.diagnostic.severity.WARN)
              end,
              ["<C-x>i"] = function(prompt_bufnr)
                diagnostics_telescope_action(prompt_bufnr, vim.diagnostic.severity.INFO)
              end,
              ["<C-x>a"] = function(prompt_bufnr)
                diagnostics_telescope_action(prompt_bufnr, "all")
              end,
            },
          },
        },
        find_files = {
          theme = "dropdown",
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
          --find_command = { "perl", "-Prn" }
        },
        colorscheme = {
          enable_preview = true,
        }
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
        -- Your extension configuration goes here:
        -- extension_name = {
        --   extension_config_key = value,
        -- }
        -- please take a look at the readme of the extension you want to configure
        --sessions = {
        --  sessions_dir = vim.fn.stdpath('data') .. '/telescope-sessions/',
        --}
        live_grep_args = {
          auto_quoting = false, -- enable/disable auto-quoting
          mappings = {          -- extend mappings
            i = {
              ["<C-a>"] = live_grep_args_actions.quote_prompt(),
              ["<C-i>"] = live_grep_args_actions.quote_prompt({ postfix = " --iglob " }),
              -- freeze the current list and start a fuzzy search in the frozen list
              ["<C-space>"] = actions.to_fuzzy_refine,
            },
          },
        }
      },
      import = {
        -- Add imports to the top of the file keeping the cursor in place
        insert_at_top = true,
        -- Support additional languages
        custom_languages = {
          {
            -- The regex pattern for the import statement
            regex = [[^(?:import(?:[\"'\s]*([\w*{}\n, ]+)from\s*)?[\"'\s](.*?)[\"'\s].*)]],
            -- The Vim filetypes
            filetypes = { "typescript", "typescriptreact", "javascript", "react" },
            -- The filetypes that ripgrep supports (find these via `rg --type-list`)
            extensions = { "js", "ts", "tsx" },
          },
        },
      }
    }

    require("telescope").setup(conf)

    function install_extension(name)
      require("telescope").load_extension(name)
    end

    install_extension("file_browser")
    install_extension("mapper")
    install_extension("ui-select")
    install_extension("bookmarks")
    install_extension("repo")
    install_extension("gh")
    install_extension("git_worktree")
    install_extension("env")
    install_extension("luasnip")

    -- Only load rest extension if rest.nvim is actually loaded
    if pcall(require, "rest-nvim") then
      install_extension("rest") -- require("telescope").extensions.rest.select_env()
    end

    install_extension("cder") -- for switching working directories
    install_extension("notify")
    install_extension("file_browser")
    install_extension("neoclip")
    install_extension("conduct")
    --install_extension("import")
    install_extension("neoclip")
    --install_extension("lazygit")
    -- install_extension("file_list")

    --------------------------------------------------------------------------------
    --                               Global Keymap                                --
    --------------------------------------------------------------------------------
    vim.keymap.set('n', '<leader>r', require('telescope.builtin').registers, { desc = 'Telescope registers' })
    -- putting in telescope package was not working (prob due to lazy loading)
    vim.keymap.set('v', '<C-f>',
      function()
        require("telescope-live-grep-args.shortcuts").grep_visual_selection({
          quote = false,
          trim = true,
          default_text = table.concat(shared_rg_args, " "),
          postfix = "",
          prompt_title = "Search in Buffer",
          search_dirs = { vim.api.nvim_buf_get_name(0) },
        })
      end,
      { desc = "Grep selection in current buffer." })

    vim.keymap.set('n', "<leader>pd", function() diagnostics_telescope_action({ bufnr = 0 }, "all") end,
      { desc = "Buffer diagnostics" })
    vim.keymap.set('n', "<leader>pdd", function() diagnostics_telescope_action({}, "all") end,
      { desc = "Workspace diagnostics" })
    vim.keymap.set('n', "<leader>d", "<cmd>lua vim.diagnostic.setloclist()<cr>",
      { desc = "Buffer diagnostics to location list" })
    vim.keymap.set('n', "<leader>dd", "<cmd>lua vim.diagnostic.setqflist()<cr>",
      { desc = "Workspace diagnostics to quickfix list" })
    -- Grep visual selection in the whole workspace (recursive search)
    vim.keymap.set('v', '<C-f><C-f>', function()
      require("telescope-live-grep-args.shortcuts").grep_visual_selection({
        quote = false,
        trim = true,
        default_text = table.concat(shared_rg_args, " "),
        postfix = "",
        prompt_title = "Search in Workspace",
      })
    end, { desc = "Grep selection in workspace." })

    -- vim.keymap.set('n', '<leader>fg', rhs, opts)
    vim.keymap.set('v', '<C-f>',
      function()
        local function grep_in_selection_effect()
          -- Get start and end line of visual selection
          local start_line = vim.fn.line("'<")
          local end_line = vim.fn.line("'>")

          -- Build ripgrep argument
          local range_arg = string.format("--line-range %d:%d", start_line, end_line)

          -- Call Telescope live_grep_args with extra args
          require('telescope').extensions.live_grep_args.live_grep_args({
            additional_args = function()
              return { range_arg }
            end
          })
        end
        -- function() require("telescope-live-grep-args.shortcuts").grep_visual_selection({ quote = false, trim = true }) end
        grep_in_selection_effect()
      end
      ,
      { desc = "Grep within selection." })

    -- vim.keymap.set('n', '<leader>pp',
    --   function() pick_files(vim.fn.expand("~") .. "/devel/dynatrace_bitbucket/15_TEAM_CARE_PROJECTS") end,
    --   { desc = "Pick a project" })

    vim.keymap.set('n', '<leader>ppp', "<cmd>lua require'telescope.builtin'.pickers()<cr>", {
      desc =
      "Pick a picker."
    })
    vim.keymap.set('n', '<leader>pfg',
      "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find({prompt_title='Live Grep in Buffer', layout_config={prompt_position='bottom'}})<cr>",
      {
        desc =
        "Pick find buffer. Find string in buffer using current_buffer_fuzzy_find."
      })
    vim.keymap.set('n', '<leader>pfgp',
      function()
        local path = vim.fn.input("Enter root path: ", vim.fn.expand("%:p:h"))
        require('telescope').extensions.live_grep_args.live_grep_args({
          search_dirs = { path },
          prompt_title =
              "Live Grep Args under " .. path
        })
      end,
      {
        desc =
        "Pick path root and grep recursively starting there."
      })
    -- Incoming callers (who calls the symbol under cursor)
    vim.keymap.set('n', 'gai', function()
      require 'telescope.builtin'.lsp_incoming_calls({
        show_line = true,  -- show the line where the call occurs
        fname_width = 40,  -- widen filename column
        trim_text = false, -- don't trim call line text
      })
    end, { desc = 'LSP Incoming Calls' })

    -- Outgoing calls (what the symbol calls)
    vim.keymap.set('n', 'gao', function()
      require 'telescope.builtin'.lsp_outgoing_calls({
        show_line = true,
        fname_width = 40,
        trim_text = false,
      })
    end, { desc = 'LSP Outgoing Calls' })

    vim.keymap.set("n", "<leader>pe", function()
      -- Use Telescope to prompt for the shell command
      -- require('telescope.builtin').input({
      --   prompt = 'Enter shell command:',
      --   default_text = "yq -iP '.hotfixAutomationEnabled = false' %s -o json",
      --   on_submit = function(input)
      --     -- Get the current buffer name
      --     local name = vim.fn.expand('%')
      --
      --     -- Replace %s with the buffer name in the input command
      --     local cmd = string.format(input, name)
      --
      --     -- Execute the shell command
      --     vim.fn.system(cmd)
      --   end
      -- })
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      require('telescope.pickers').new({}, {
        prompt_title = 'Enter shell command',
        finder = require('telescope.finders').new_table {
          results = { "yq -iP '.hotfixAutomationEnabled = false' %s -o json" }
        },
        sorter = require('telescope.config').values.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            local input = selection[1]

            -- Get the current buffer name
            local name = vim.fn.expand('%')

            -- Replace %s with the buffer name in the input command
            local cmd = string.format(input, name)

            -- Execute the shell command safely
            local portable = require('config.portable')
            local result = portable.safe_system(cmd, "telescope_shell_executor")
            if result ~= "" then
              vim.notify("Command output: " .. result, vim.log.levels.INFO)
            end
          end)
          return true
        end,
      }):find()
    end, { desc = "Pick executable to run in shell" })

    local values = require('telescope.config').values
    vim.keymap.set('n', '<leader>pfgg',
      function()
        local cmd_str = table.concat(values.vimgrep_arguments or {}, ' ')
        require('telescope').extensions.live_grep_args.live_grep_args(
          object_assign(
            {
              default_text = table.concat(shared_rg_args, " "),
              prompt_title = string.format('live_grep_args: %s', cmd_str)
              -- prompt_title =
              -- "live_grep_args (Ripgrep) . (+/- files with --iglob **/dir/**) (--no-ignore to ignore gitignore)",
              -- results_title = cmd_str
            }, -- sits above the results pane
            require 'telescope.themes'.get_ivy({ previewer = true }))
        )
      end,
      {
        desc =
        "Pick path root and grep recursively starting there."
      })
    vim.keymap.set('n', '<leader>pfga',
      "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", {
        desc =
        "Pick find grep args in buffer. Open live grepper accepting custom arguments."
      })
    vim.keymap.set('n', '<leader>pff',
      function()
        local path = vim.loop.cwd()
        require 'telescope.builtin'.find_files(object_assign(
          { cwd = path, hidden = true, prompt_title = "find_files " .. path },
          require 'telescope.themes'.get_ivy({ previewer = true })))
      end,
      {
        desc =
        "Pick find files."
      })

    vim.keymap.set('n', '<leader>pfc',
      function()
        local sorters = require('telescope.sorters')
        local path = vim.loop.cwd()
        local path_under_cursor = vim.fn.expand("<cfile>")
        -- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/builtin/__files.lua#L274-L275
        -- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/builtin/__files.lua#L323-L325
        require 'telescope.builtin'.find_files(object_assign(
          {
            cwd = path,
            hidden = true,
            -- search_file = path_under_cursor,
            -- prompt_title = "find_files (find) " .. path,
            -- find_command = { "find", ".", "-type", "f", "-name" } -- search_file passed in
            -- sorter = sorters.fuzzy_with_index_bias({}) -- make it not fuzzy-find, instead simple, non-fuzzy sorting of the results
          },
          require 'telescope.themes'.get_ivy({ previewer = true })))

        vim.defer_fn(function()
          vim.api.nvim_feedkeys(path_under_cursor or "", "n", false)
        end, 10)
      end,
      {
        desc =
        "Pick find files."
      })
    vim.keymap.set('n', '<leader>pfu',
      function()
        local path = vim.fn.expand("~")
        require 'telescope.builtin'.find_files(object_assign(
          { cwd = path, hidden = true },
          require 'telescope.themes'.get_ivy({ previewer = true })))
      end,
      {
        desc =
        "Pick find files in user directory."
      })

    vim.keymap.set('n', '<leader><leader>pn',
      function()
        --local path = vim.fn.stdpath('data') .. "/jonathans_special_files/1on1-team-care"
        local path = vim.g.jonathans_special_files
        --vim.fn.expand("$HOME") ..
        --    "/Library/CloudStorage/OneDrive-Dynatrace/Dokumente/jonathans_special_files"
        require("telescope.builtin").find_files(object_assign(
          { cwd = path, hidden = false, prompt_title = "Pick file under: " .. path },
          require("telescope.themes").get_ivy({ previewer = true })))
      end, { desc = "Pick from special files recursively." })

    vim.keymap.set('n', '<leader>pcff',
      function()
        local path = vim.fn.stdpath("config")
        require("telescope.builtin").find_files(object_assign(
          { cwd = path, hidden = true, prompt_title = "Fuzzy File Find under " .. path },
          require("telescope.themes").get_ivy({ previewer = true })))
      end, { desc = "Pick config file recursively." })

    vim.keymap.set('n', '<leader>pcgg',
      function()
        local path = vim.fn.stdpath("config")
        require('telescope').extensions.live_grep_args.live_grep_args({
          search_dirs = { path },
          prompt_title =
              "Recursive Grep Args under " .. path
        })
      end,
      {
        desc =
        "Pick config using grep (recursive)."
      })

    vim.keymap.set('n', '<leader><leader>p1',
      function()
        local path = vim.g.jonathans_special_files .. "/1on1-team-care"
        require("telescope.builtin").find_files(object_assign(
          { cwd = path, hidden = false, prompt_title = "Pick file under: " .. path },
          require("telescope.themes").get_ivy({ previewer = true })))
      end, { desc = "Pick one-on-one file." })

    vim.keymap.set("n", "<leader><leader>pc", "<cmd>Telescope colorscheme<CR>", { desc = "Pick colorscheme." })
  end,

  dependencies = {
    -- TODO: Decide whether to include extensions here
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
    { "ThePrimeagen/git-worktree.nvim" }, -- debug ~/.cache/nvim/telescope.log https://github.com/ThePrimeagen/git-worktree.nvim/issues/112#issuecomment-2074240307
    { "nvim-lua/plenary.nvim" },
    { "LinArcX/telescope-env.nvim" },
    { "benfowler/telescope-luasnip.nvim" },
    { "cljoly/telescope-repo.nvim" },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "dhruvmanila/telescope-bookmarks.nvim" },
    { "nvim-telescope/telescope-github.nvim" },
    { "rest-nvim/rest.nvim" },
    { "rcarriga/nvim-notify" },
    { "nvim-telescope/telescope-file-browser.nvim" },
    { "AckslD/nvim-neoclip.lua" },
    --{ "kdheepak/lazygit.nvim "},
    --{ "piersolenski/telescope-import.nvim" },-- had issues
    --{ "pvelayudhan/telescope-sessions.nvim" },
    {
      "aaditeynair/conduct.nvim",
      dependencies = "nvim-lua/plenary.nvim",
      config = function(_, _)
        local conf = {
          -- define function that you bind to a key in a project config
          functions = {},

          -- define presets for projects
          presets = {},

          hooks = {
            before_session_save = function() end,
            before_session_load = function() end,
            after_session_load = function() end,
            before_project_load = function() end,
            after_project_load = function() end,
          }
        }
        require("conduct").setup(conf)

        -- vim.keymap.set("n", "<leader>ps", ":Telescope conduct sessions<CR>", { desc = "Pick a session" })
        -- vim.keymap.set("n", "<leader>pp", ":Telescope conduct projects<CR>", { desc = "Pick a project" })
        -- Ctrl d	Delete selected session or project
        -- Ctrl r	Rename selected session or project
      end
    },
    {
      "LukasPietzschmann/telescope-tabs",
      dependencies = "nvim-telescope/telescope.nvim",
      config = function()
        require("telescope-tabs").setup({
          entry_formatter = function(tab_id, buffer_ids, file_names, file_paths)
            local entry_string = table.concat(file_names, ", ")
            return string.format("%d: %s", tab_id, entry_string)
          end,
          entry_ordinal = function(tab_id, buffer_ids, file_names, file_paths)
            return table.concat(file_names, " ")
          end,
          show_preview = true,
        })
      end,
    },
    { "zane-/cder.nvim" },
    --{"nvim-telescope/telescope-packer.nvim"},
    -- {
    --   dir = vim.fn.stdpath('config') .. "/local_plugin_packages/telescope-custom-file-list.nvim",
    -- }
  }
}
