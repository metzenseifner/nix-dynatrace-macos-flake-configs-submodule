return {
  "akinsho/toggleterm.nvim",

  config = function(_, _)
    local Terminal = require('toggleterm.terminal').Terminal

    vim.keymap.set('n', '<leader>gc', function()
      -- Guard: check if we're inside a git repo
      vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
      if vim.v.shell_error ~= 0 then
        vim.notify("⚠️  Not a git repository.", vim.log.levels.WARN)
        return
      end


      --------------------------------------------------------------------------------
      --              This stuff was a safe check when I used the more              --
      --                  destructive git fetch; git reset --hard                   --
      --                           origin/main approach.                            --
      --------------------------------------------------------------------------------

      -- local remote = "origin"
      -- local base = vim.fn.system(
      --   string.format("git symbolic-ref -q --short refs/remotes/%s/HEAD 2>/dev/null", remote)
      -- )
      -- base = base:gsub("%s+", "")
      -- if base == "" then
      --   base = remote .. "/main"
      -- end

      -- local branch = base:gsub("^origin/", "") -- e.g. "main"
      -- local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

      local function open_terminal(input)
        local term = Terminal:new({
          direction = "horizontal",
          close_on_exit = false,
          on_open = function(t)
            t:send(input)
            vim.api.nvim_buf_set_keymap(t.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
            vim.api.nvim_buf_set_keymap(t.bufnr, "t", "<C-o>", "", {
              noremap = true,
              silent = true,
              callback = function()
                t:close()
                t.direction = "horizontal"
                t:open()
                vim.cmd("startinsert!")
              end
            })
          end,
        })
        term:toggle()
      end

      local function prompt_command()
        vim.ui.input({
          prompt = 'Command: ',
          -- default = string.format('git fetch && git reset --hard %s', base),
          default = string.format('git pull'),
        }, function(input)
          if input then
            open_terminal(input)
          end
        end)
      end


      prompt_command()
      --if cwd == branch then
      --  -- Convention matches, proceed normally
      --  prompt_command()
      --else
      --  -- Warn the user they are NOT in the expected worktree
      --  vim.notify(
      --    string.format(
      --      "⚠️  WARNING: Current dir '%s' does not match branch '%s'.\n" ..
      --      "This will OVERWRITE your local branch with the remote.\n" ..
      --      "Select 'Yes, overwrite' to continue or 'Cancel' to abort.",
      --      cwd, branch
      --    ),
      --    vim.log.levels.WARN
      --  )

      --  vim.ui.select(
      --    { "Cancel", "Yes, overwrite" },
      --    {
      --      prompt = string.format("⚠️Overwrite branch: %s?", branch)
      --    },
      --    function(choice)
      --      if choice == "Yes, overwrite" then
      --        prompt_command()
      --      end
      --    end
      --  )
      --end


      --   vim.ui.input({
      --     prompt = 'Command: ',
      --     default = 'git fetch && git reset --hard origin/HEAD',
      --   }, function(input)
      --     if input then
      --       local term = Terminal:new({
      --         -- cmd = input, -- overrides default shell
      --         direction = "horizontal",
      --         close_on_exit = false,
      --         -- float_opts = {
      --         --   border = "curved",
      --         --   width = math.floor(vim.o.columns * 0.9),
      --         --   height = math.floor(vim.o.lines * 0.9),
      --         -- },
      --         on_open = function(t)
      --           t:send(input)
      --           -- vim.cmd("startinsert!") -- if you want to enter insert mode
      --           -- Press 'q' in normal mode to close quickly
      --           vim.api.nvim_buf_set_keymap(t.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
      --           -- Press <C-o> to switch to horizontal split
      --           vim.api.nvim_buf_set_keymap(t.bufnr, "t", "<C-o>", "", {
      --             noremap = true,
      --             silent = true,
      --             callback = function()
      --               t:close()
      --               t.direction = "horizontal"
      --               t:open()
      --               vim.cmd("startinsert!")
      --             end
      --           })
      --         end,
      --       })
      --       term:toggle()
      --     end
      --   end)
    end, { desc = 'Run git command in terminal' })
  end
}
