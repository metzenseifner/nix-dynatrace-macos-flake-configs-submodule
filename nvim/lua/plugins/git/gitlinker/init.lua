return {
  {
    "ruifm/gitlinker.nvim", -- Generate permalink URLs to Repo Manager to commits
    dependencies = { { "nvim-lua/plenary.nvim" } },
    config = function()
      require("gitlinker").setup({
        --function()
        --  vim.api.nvim_set_keymap('n', '<leader>gY', '<cmd>lua require"gitlinker".get_repo_url()<cr>', {silent = true})
        --  vim.api.nvim_set_keymap('n', '<leader>gB', '<cmd>lua require"gitlinker".get_repo_url({action_callback = require"gitlinker.actions".open_in_browser})<cr>', {silent = true})
        --end

        opts = {
          remote = nil, -- force the use of a specific remote
          -- adds current line nr in the url for normal mode
          add_current_line_on_normal_mode = true,
          -- callback for what to do with the url
          action_callback = function(url)
            -- original: require"gitlinker.actions".copy_to_clipboard,
            --yank to unnamed register
            vim.api.nvim_command("let @\" = '" .. url .. "'")
            -- copy to sys clipboard
            --require('osc52').copy_register('@"')
            require("osc52").copy(url)
          end,
          -- print the url after performing the action
          print_url = true,
        },
        --url_data = {
        --  host = "bitbucket.lab.dynatrace.org",
        --  port = nil, --"3000" or nil,
        --  repo = "<user/repo>",
        --  rev = "<commit sha>",
        --  file = "<path/to/file/from/repo/root>",
        --  lstart = 42, -- the line start of the selected range / current line
        --  lend = 57, -- the line end of the selected range
        --},
        callbacks = {
          ["bitbucket.lab.dynatrace.org"] = function(url_data)
            -- http://lua-users.org/wiki/StringLibraryTutorial
            -- Example URLs
            -- User URL:
            --   https://bitbucket.lab.dynatrace.org/users/jonathan.komar/repos/github-automation-app/browse
            --   ssh://git@bitbucket.lab.dynatrace.org/~jonathan.komar/github-automation-app.git
            -- Non-User URL:
            --   https://bitbucket.lab.dynatrace.org/projects/APPS/repos/dynatrace-app-template/browse
            --   ssh://git@bitbucket.lab.dynatrace.org/apps/dynatrace-app-template.git
            -- Non-User URL:
            --   https://bitbucket.lab.dynatrace.org/projects/APPS/repos/slack-app/browse
            --   ssh://git@bitbucket.lab.dynatrace.org/autoapp/slack-app.git
            -- {+bitbucket}{/owner, repository_name}/src{/commitish}{/filepath}{?fileviewer}{#fileline}
            function isUserNamespace(url_data, username)
              if string.find(url_data.repo, username) then
                return true
              else
                return false
              end
            end

            function extractRepo(url_data)
              local index_of_slash = string.find(url_data.repo, "/", 1)
              local repo = string.sub(url_data.repo, index_of_slash + 1, -1)
              return repo
            end

            function extractProjectNamespace(url_data)
              local index_of_slash = string.find(url_data.repo, "/", 1)
              local project_ns = string.sub(url_data.repo, 1, index_of_slash - 1)
              return project_ns
            end

            function getNamespace(predicate, url_data)
              if isUserNamespace(url_data, "jonathan.komar") then
                return "/users/jonathan.komar"
              else
                return "/projects/" .. extractProjectNamespace(url_data)
              end
            end

            local url = "https://"
                .. url_data.host
                .. getNamespace(isUserNamespace, url_data)
                .. "/repos/"
                .. extractRepo(url_data)
                .. "/browse"

            if url_data.file then
              url = url .. "/" .. url_data.file
            end
            --https://bitbucket.lab.dynatrace.org/projects/APPFW/repos/appfw-spec/browse/serverless/runtime-reference.md?useDefaultHandler=true&https://bitbucket.lab.dynatrace.org/projects/APPFW/repos/appfw-spec/browse/serverless/runtime-reference.md?useDefaultHandler=true&at=4aa00b425ddf80fdb75de9a28006cbd638fdf8c6#40
            -- use useDefaultHandler=true for markdown
            if url_data.rev then
              url = url .. "?useDefaultHandler=true&at=" .. url_data.rev
            end
            if url_data.lstart then
              url = url .. "#" .. url_data.lstart
              if url_data.lend then
                url = url .. "-" .. url_data.lend
              end
            end
            --for key, value in pairs(url_data) do
            --  print(key .. ": " .. value)
            --end
            return url
            --require"gitlinker.hosts".get_gitea_type_url(url_data)
          end,
        },
        -- default mapping to call url generation with action_callback
        mappings = "<leader>gy",
      })

      -- Custom function to generate links for all quickfix items (async with progress)
      vim.keymap.set("n", "<leader>gY", function()
        local qflist = vim.fn.getqflist()
        if #qflist == 0 then
          vim.notify("Quickfix list is empty", vim.log.levels.WARN)
          return
        end

        local total = #qflist
        vim.notify(string.format("Processing %d quickfix entries...", total), vim.log.levels.INFO)

        -- Process asynchronously to avoid blocking UI
        vim.schedule(function()
          local links = {}
          local gitlinker = require("gitlinker")
          local current_buf = vim.api.nvim_get_current_buf()
          local current_win = vim.api.nvim_get_current_win()
          local processed = 0
          
          -- Process items in batches to allow UI updates
          local function process_batch(start_idx)
            local batch_size = 5
            local end_idx = math.min(start_idx + batch_size - 1, total)
            
            for i = start_idx, end_idx do
              local item = qflist[i]
              processed = processed + 1
              
              if item.bufnr > 0 and item.lnum > 0 then
                local filepath = vim.fn.bufname(item.bufnr)
                if filepath ~= "" then
                  -- Switch to the buffer temporarily
                  pcall(function()
                    vim.api.nvim_set_current_buf(item.bufnr)
                    vim.api.nvim_win_set_cursor(current_win, {item.lnum, item.col or 0})
                    
                    -- Generate the URL using gitlinker's internal method
                    local url = gitlinker.get_buf_range_url("n")
                    
                    if url then
                      table.insert(links, "- " .. url)
                    end
                  end)
                end
              end
              
              -- Update progress every 10% or on last item
              if processed % math.max(1, math.floor(total / 10)) == 0 or processed == total then
                vim.schedule(function()
                  vim.notify(
                    string.format("Progress: %d of %d quickfix entries", processed, total),
                    vim.log.levels.INFO,
                    { timeout = 1000 }
                  )
                end)
              end
            end
            
            -- Continue with next batch or finish
            if end_idx < total then
              vim.schedule(function()
                process_batch(end_idx + 1)
              end)
            else
              -- All done, restore buffer and copy results
              vim.schedule(function()
                pcall(function()
                  vim.api.nvim_set_current_buf(current_buf)
                end)
                
                if #links > 0 then
                  local result = table.concat(links, "\n")
                  vim.api.nvim_command("let @\" = '" .. result:gsub("'", "''") .. "'")
                  
                  -- Copy to clipboard asynchronously
                  vim.schedule(function()
                    require("osc52").copy(result)
                    vim.notify(
                      string.format("✓ Copied %d quickfix links to clipboard and register", #links),
                      vim.log.levels.INFO,
                      { timeout = 3000 }
                    )
                  end)
                else
                  vim.notify("No valid links generated from quickfix list", vim.log.levels.WARN)
                end
              end)
            end
          end
          
          -- Start processing first batch
          process_batch(1)
        end)
      end, { desc = "Copy quickfix list as git links (async)", silent = true })
    end,
  },
}
