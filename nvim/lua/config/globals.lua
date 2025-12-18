local vim = vim

vim.g.nohidden = 1
vim.g.do_filetype_lua = 1    -- Activate the Lua filetype detection mechanism
-- vim.g.did_load_filetypes = 0 -- Disable filetype.vim detection mechanism
vim.g.jonathans_special_files = "~/Library/CloudStorage/OneDrive-Dynatrace/Dokumente/jonathans_special_files"
vim.g.startup_bookmarks = {
  ["C"] = '~/devel/dynatrace_bitbucket/15_TEAM_CARE_PROJECTS/',
}


--vim.g.colors_name = "PaperColor" -- same as vim.cmd[[colorscheme PaperColor]]
vim.g.colors_name = "ayu-light"

-- " let g:ale_linters = {
-- " 			\ 'javascript': ['eslint'],
-- " 			\}
-- " mappings to nav the list of warnings provided by linter
-- " nmap <silent> [" <Plug>(ale_first)
-- " nmap <silent> [" <Plug>(ale_previous)
-- " nmap <silent> ]" <Plug>(ale_next)
-- " nmap <silent> ]" <Plug>(ale_last)
vim.api.nvim_set_hl(0, "TermCursor", { link = "TermCursor" })

vim.g.netrw_preview = 1
-- Convert table to string and print
-- @returns input, untampered
P = function(v)
  print(vim.inspect(v))
  return v
end

-- Print current working dir
C = function()
  local uv = vim.loop -- libuv
  print(uv.cwd())
end

RELOAD = function(...)
  return require('plenary.reload').reload_module(...)
end

R = function(name)
  RELOAD(name)
  return require(name)
end

-- To appropriately highlight codefences returned from denols, you will need to augment vim.g.markdown_fenced languages
vim.g.markdown_fenced_languages = {
  "ts=typescript"
}

vim.api.nvim_create_user_command('JiraFile', function(context)
  print('JiraFile setting filetype to Jira and printing args for fun: ' .. context.args)
  vim.bo.filetype = "Jira" -- vim.bo = buffer-scoped options
end, { nargs = "*" })

--
local get_buf_by_name = function(name)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf):sub(-string.len(name)) == name then
      return buf
    end
  end
end
local clear_buf = function(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
end

-- Maybe useful down the line
-- local outputWithReplacedNewlinesAsSpaces = output:gsub('[\n\r]', ' ')
vim.api.nvim_create_user_command('Changedfiles', function(context)
  local portable = require('config.portable')
  local default = "origin/main"
  local relativeBranch = vim.fn.input('Since <commitlike>:', default)
  local sinceCommit = ""
  
  if portable.has("git") then
    local handle = portable.safe_popen("git merge-base HEAD " .. relativeBranch, 'r', 'Changedfiles')
    if handle then
      handle:flush()
      sinceCommit = handle:read("*a")
      handle:close()
    end
    vim.notify(sinceCommit)

    local command = string.format("git diff --name-only $(git merge-base HEAD %s)", sinceCommit)
    local newbufname = "files-changed-since-" .. sinceCommit
    local newbufnr = get_buf_by_name(newbufname)
    if not newbufnr then
      newbufnr = vim.api.nvim_create_buf(true, true)
      vim.api.nvim_buf_set_name(newbufnr, newbufname)
      vim.api.nvim_buf_set_option(newbufnr, 'modifiable', true)
      vim.api.nvim_open_win(newbufnr, false, { split = 'right', win = 0 })
    else
      clear_buf(newbufnr)
      vim.api.nvim_open_win(newbufnr, false, { split = 'right', win = 0 })
    end
    vim.notify(string.format("Output buffer(bufnr: %s, name: %s)", newbufnr, newbufname))
    
    local portable = require('config.portable')
    portable.safe_jobstart(command, {
      stdout_buffered = true, -- buffer by LF
      on_stdout = function(_, data)
        --if data then table.insert(stdout, data) end
        if data then
          vim.api.nvim_buf_set_lines(newbufnr, 0, -1, false, data)
        end
      end,
      on_stderr = function(_, data) end,
      on_exit = function()
        local lines = vim.api.nvim_buf_get_lines(newbufnr, 0, -2, true)
        clear_buf(newbufnr)
        vim.api.nvim_buf_set_lines(newbufnr, 0, -1, false, lines)
      end,
    })
  else
    vim.notify("Git command not found - cannot run Changedfiles", vim.log.levels.WARN)
  end
end, { nargs = "*" })

function exec_verbose(fnstr)
  -- Prints literal code before executing it
  print("Executing::" .. fnstr)
  tokens = loadstring(fnstr)
  tokens()
end

function add_missing_imports()
  print("Running add_missing_imports")
  -- local buffer_contents = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false)
  local myargs = {
    range = {
      start = { 1, 1 },
      ['end'] = { -1, 1 }
    }
  }

  vim.lsp.buf.code_action(myargs)
  print("Done add_missing_imports")
end
