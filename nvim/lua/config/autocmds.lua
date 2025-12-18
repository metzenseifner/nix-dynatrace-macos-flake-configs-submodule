-- Reapply options on switch buffer
-- This is to override and global options that get set with
-- some filetypes like Jira
-- The problem is that some of these globals get set by packages for the
-- bar on the top and bottom with fancy colors. NOt sure how to solve this yet.
-- So options serve as the initial values
--vim.api.nvim_create_autocmd("BufEnter", {
--  pattern = {
--    "*"
--  },
--  callback = function(environment)
--    require'config.options'
--  end
--})

-- in your init.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.schedule(function()
      vim.api.nvim_echo({
        { "Quickfix opened → use ", "Normal" },
        { "<C-P>", "Identifier" },
        { " for previous, ", "Normal" },
        { "<C-N>", "Identifier" },
        { " for next", "Normal" },
      }, false, {})
    end)
  end,
})

-- Define a user command to activate the Git auto-commit on save for the current buffer
vim.api.nvim_create_user_command('GitAutoCommitOnSave', function()
  -- Create an autocommand group
  vim.api.nvim_create_augroup('GitAutoCommit', { clear = true })

  -- Set up the autocommand to trigger on file save
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = 'GitAutoCommit',
    buffer = 0,  -- Use the current buffer
    callback = function()
      vim.cmd('!git add %:p')
      vim.cmd('!git commit -m "Auto-commit on save."')
    end,
  })
end, {})

vim.api.nvim_create_user_command("Note", function(callContext)
  -- TODO if last char in file is not newline, prepend a newline
  local input = vim.fn.input("Text: ", os.date() .. " :: ") .. "\n"
  functions.write_text_file(input, vim.fn.stdpath("data") .. "/jonathans_special_files/notes.async.txt")
end, {})

-- https://luabyexample.org/docs/nvim-autocmd/
vim.api.nvim_create_autocmd("BufEnter", {
  -- "https://unix.stackexchange.com/a/609636/33386",
  pattern = {
    "*.yaml",
    "*.yml"
  },
  command = ":setlocal indentkeys-=0#"
})
vim.api.nvim_create_augroup("buffer", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "buffer",
  pattern = "json|markdown",
  command = ":IndentLinesDisable"
})

local set_columns = function(input)
  vim.g.original_columns = vim.opt.columns
  vim.opt.columns = input
  --TODO if vim.g.reset_buffer defined, then compose with this new function
  vim.g.reset_buffer = function()
    print("Resetting buffer columns")
    vim.opt.columns = vim.g.original_columns
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = "buffer",
  pattern = '*',
  callback = function(environment)
    if (vim.g.reset_buffer ~= nil) then vim.g.reset_buffer() end
  end
})

vim.api.nvim_create_autocmd("FileType", {
  group = "buffer",
  pattern = "Jira",
  --command = ':lua print("Jira filetype detected!")'
  callback = function(environment)
    print("Set filetype to 'Jira' and applying customizations")
    vim.opt.wrap = true      -- wrap causes vim to soft-wrap on the edge of the window.
    vim.opt.linebreak = true -- linebreak causes it to not break in the middle of a word, but this will only work if the list setting is not enabled.
    --vim.opt.numberwidth = 6
    set_columns(80)
    vim.opt.textwidth = 80 --vim.opt.columns = !tput cols
    vim.opt.showbreak = "++"
    vim.api.nvim_create_autocmd("VimResized", {
      group = "buffer",
      pattern = "*",
      command = 'if (&columns > 80) | set columns=80 | endif'
    })
  end
})

-- Apply old Jira textile filetype when filenames match those of firenvim conventions
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  pattern = {
    "dev-jira.dynatrace.org_*.txt",
    "dt-rnd.atlassian.net_*.txt",
    "*.jira"
  },
  command = ":set filetype=jira" --old textile atlassian junk
})

vim.api.nvim_create_autocmd({ 'ExitPre' }, {
  pattern = {
    "dev-jira.dynatrace.org_*.txt",
    "dt-rnd.atlassian.net_*.txt"
  },
  command = "!pandoc --from=markdown-auto_identifiers --to=jira '%'"
})

-- Show nvim-cmp suggestions after updatetime elapsed in normal mode
-- showing completions on space using this event proved to be a bit annoying
-- it was more of a workaround since the keystrokes to open the completion menu
-- were not working before.
--vim.api.nvim_create_autocmd("CursorHoldI", {
--  group = vim.api.nvim_create_augroup("cmp_complete_on_space", {}),
--  callback = function()
--    local line = vim.api.nvim_get_current_line()
--    local cursor = vim.api.nvim_win_get_cursor(0)[2]
--
--    if string.sub(line, cursor, cursor + 1) == " " then
--      require("cmp").complete({
--        config = {
--          sources = {
--            {
--              name = "nvim_lsp",
--              -- Hide all entries with the kind "Text"
--              -- source-specific enty filter with signature:
--              -- function(entry: cmp.Entry, ctx: cmp.Context): boolean
--              entry_filter = function(entry, ctx)
--                return
--                require("cmp").lsp.CompletionItemKind.Text ~= entry:get_kind() and
--                require("cmp").lsp.CompletionItemKind.Function ~= entry:get_kind() and
--                require("cmp").lsp.CompletionItemKind.Variable ~= entry:get_kind() and
--                require("cmp").lsp.CompletionItemKind.Snippet ~= entry:get_kind()
--              end
--            },
--          }
--        }
--      }
--      )
--    end
--  end,
--})

-- Fills Quickfix list with diagnostic messages (which are populated partially
-- by the LSP) upon writing a buffer and trying to exit a buffer.
-- This could be annoying, so TODO room for improvement
-- I DISABLED THIS BECAUSE IT INTERFERES WITH REFACTORING WITH QUICKFIX (TELESCRIPT RGREP TO QUICKFIX)
--vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--  -- you can disable BufWritePost because it is annoying
--  group = "buffer",
--  pattern = "*",
--  callback = function()
--    local status, diagTable = pcall(require('config.diagnostic').get_diagnostics({ qflist = true }))
--    if not status or not diagTable or not next(diagTable) then
--      vim.api.nvim_command('ccl') -- closes quickfix on write, undesirable when refactoring
--      return
--    end
--    functions.open_diagnostics()
--  end
--})

--"autocmd FileType help wincmd L
vim.api.nvim_create_autocmd("FileType",
  {
    pattern = 'help',
    callback = function()
      vim.cmd("wincmd L")
      print("Swapped windows with vim.cmd('wincmd L')")
    end
  })

-- Show diagnostics in a pop-up window on hover helper
-- see https://stackoverflow.com/questions/35910099/how-special-is-the-global-variable-g
local LspDiagnosticsPopupHandler = function()
  local current_cursor = vim.api.nvim_win_get_cursor(0)
  local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }

  -- Show the popup diagnostics window,
  -- but only once for the current cursor location (unless moved afterwards).
  if not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2]) then
    vim.w.lsp_diagnostics_last_cursor = current_cursor
    vim.diagnostic.open_float(0, { scope = "cursor" })
  end
end

--------------------------------------------------------------------------------
--          This the the autopopup for LSP Auto Completion nvim-cmp           --
--------------------------------------------------------------------------------
--Commented out because it was slowing down typing too much.

--- Show diagnostics automatically in floating window in NORMAL mode (debounce with vim.o.updatetime)
-- Removed duplicate vim.cmd autocmd - using only the nvim_create_autocmd below
vim.api.nvim_create_autocmd({ "CursorHold" }, {
  group = "buffer",
  pattern = '*',
  callback = function()
    LspDiagnosticsPopupHandler()
  end
})

-- Show signature help as floating window in INSERT mode
-- vim.cmd [[autocmd CursorHoldI * lua vim.lsp.buf.signature_help() ]]
--vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.lsp.buf..open_float(nil, {focus=false})]] -- This makes dianostics floating window auto appear
-- autocmd CursorHoldI * silent! lua vim.lsp.buf.signature_help()
--not needed if we wire up nvim-cmp with a source that providers signature_help messages to vim.diagnostic
--vim.cmd [[autocmd CursorHold,CursorHoldI * silent! lua vim.lsp.buf.signature_help() ]]


-- Registers a listener for BufWritePost events that executes
-- some command for a given buffer when (after, hence "Post") it is written to file.
local attach_to_buffer = function(output_bufnr, pattern, command)
  --local bufnr = 9999
  --local output_bufnr, command = bufnr
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup('jonathans-awesome-grp', { clear = true }),
    pattern = pattern,
    --pattern = {
    --  "api/actions/*.test.ts",
    --  "api/public/*.spec.ts",
    --  "api/actions/*.test.ts",
    --  "api/public/*.spec.ts",
    --},
    callback = function()
      local append_data = function(_, data)
        if data then
          vim.api.nvim_buf_set_lines(output_bufnr, -1, -1, false, data) -- append lines
        end
      end

      vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, { "output: " })
      
      local portable = require('config.portable')
      portable.safe_jobstart(command, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if not data then
            return
          end

          for _, line in ipairs(data) do
          end
        end,
        on_stderr = append_data,
      }, "AutoRun")
    end
  })
end

-- Make :AutoRun Vim-Ex-style command.
vim.api.nvim_create_user_command("AutoRun", function()
  local bufnr = vim.fn.input "Bufnr: "
  local pattern = vim.fn.input "Pattern: "
  local command = vim.split(vim.fn.input "Command: ", " ")
  --attach_to_buffer(tonumber(bufnr), pattern, command)
end, {})

--vim.api.nvim_create_augroup("plist", { clear = true })
--vim.api.nvim_create_autocmd({ "BufReadPost", "FileReadPost" }, {
--  group = "plist",
--  pattern = { "*.plist" },
--  callback = function()
--    vim.cmd("nmap ;l :w<CR>:!clear; plutil -convert xml1 '%' && echo PList OK<CR>")
--  end
--})

vim.cmd [[autocmd BufWritePost,FileWritePost *.plist !plutil -convert binary1 <afile>]]
vim.cmd [[autocmd BufNewFile,BufRead Jenkinsfile :set filetype=groovy]]

-- Autocommand to log any `:%!` filter function
vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = "!*", -- Match any external filter command
  callback = function(args)
    -- Extract the command being executed
    local command = args.match -- The full shell command (e.g., `!ls`, `!jq`)
    
    -- Get the current buffer's content (stdin for the filter function)
    local buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    
    -- Log the command and buffer content
    vim.notify("Filter Command: " .. command, vim.log.levels.INFO)
    vim.notify("Buffer Content (stdin):\n" .. buffer_content, vim.log.levels.DEBUG)
  end,
})

