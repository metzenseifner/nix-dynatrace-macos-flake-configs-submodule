-- Abreviations for lua vim module
local vim = vim
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

M = {}

-- M.open_selected_path_with_telescope = function()
--   local start_pos = vim.fn.getpos("'<")
--   local end_pos = vim.fn.getpos("'>")
--   local lines = vim.fn.getline(start_pos[2], end_pos[2])
--   local selected_text = table.concat(lines, "\n")
-- 
--   -- Trim whitespace
--   selected_text = selected_text:gsub("^%s+", ""):gsub("%s+$", "")
-- 
--   -- Check if it's a valid file or directory
--   if vim.fn.filereadable(selected_text) == 1 or vim.fn.isdirectory(selected_text) == 1 then
--     require('telescope.builtin').find_files({ cwd = selected_text })
--   else
--     print("Selected text is not a valid file or directory path: " .. selected_text)
--   end
-- end


M.add_selected_path_to_quickfix = function()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  local selected_text = table.concat(lines, "\n")

  -- Trim leading/trailing whitespace
  selected_text = selected_text:gsub("^%s+", ""):gsub("%s+$", "")

  -- Resolve to absolute path
  local cwd = vim.fn.getcwd()
  local resolved_path = vim.fn.fnamemodify(selected_text, ":p")
  if vim.fn.filereadable(resolved_path) ~= 1 and vim.fn.isdirectory(resolved_path) ~= 1 then
    resolved_path = vim.fn.fnamemodify(cwd .. "/" .. selected_text, ":p")
  end

  -- Normalize path to avoid trailing garbage
  resolved_path = vim.fn.fnamemodify(resolved_path, ":p")

  if vim.fn.filereadable(resolved_path) == 1 or vim.fn.isdirectory(resolved_path) == 1 then
    local entry = {
      filename = resolved_path, -- absolute path only
      lnum = 0,                 -- line 0 to open at top
      col = 1,
      text = ""                 -- keep text empty to avoid clutter
    }
    vim.fn.setqflist({ entry }, 'a') -- append to quickfix list
    print("Added to quickfix list: " .. resolved_path)
  else
    print("Not a valid file or directory: " .. selected_text)
  end
end

-- Register command
vim.api.nvim_create_user_command('AddSelectedPathToQuickfix', M.add_selected_path_to_quickfix, {})

-- Key binding
vim.keymap.set('v', '<leader>q', M.add_selected_path_to_quickfix, { desc = 'Add selected path to quickfix list' })



M.get_all_headings = function()
  local orgmode = require('orgmode')
  local parser = require('orgmode.parser')
  local headlines = parser.parse_file(vim.fn.expand('%'))
  for _, headline in ipairs(headlines) do
    print(headline.title)
  end
end
M.filter_done_items = function()
  local orgmode = require('orgmode')
  local parser = require('orgmode.parser')
  local headlines = parser.parse_file(vim.fn.expand('%'))
  for _, headline in ipairs(headlines) do
    if headline.todo_keyword == 'DONE' then
      print(headline.title)
    end
  end
end
M.make_horizontal_rule = function(
    args_from_other_nodes,
    parent_snippet_or_node,
    user_args
)
  --vim.schedule_wrap(P(args))
  --local title = args[1][1]
  --local str_len = vim.fn.strlen(title)
  local line_width = user_args.times
  --local LF() = "\010"
  local char = user_args.char
  if user_args.line_char == "single" then
    char = "-"
  elseif user_args.line_char == "double" then
    char = "="
  elseif user_args.line_char == "underscore" then
    char = "_"
  end
  local underline = string.rep(char, line_width)
  return underline
end

-- Uses Lib UV (supports async ops, some sync)
-- WHY? goal: write quick messages to a file to keep up with brain actitiviy without interrupting focus task
-- help luv-file-system-operations
-- help lua-lib-os
-- help lua-lib-io
M.write_text_file = function(text, path, config)
  path   = path or os.tmpname() --/tmp/randomname
  config = config or { flags = "a+", mode = 438 }
  -- local fd, err = io.open(path, {"a+"})
  -- local err, fd = uv.fsopen(path, flags or "r", mode or 438)
  function writeWithSimpleErrorHandling(callback)
    vim.uv.fs_open(path, "a+", 438, function(err, fd)
      assert(not err, err)
      -- stat might be redudant unless needed to check readability.
      vim.uv.fs_fstat(fd, function(err, stat)
        assert(not err, err)
        local offset = -1
        local dataToWrite = text
        vim.uv.fs_write(fd, dataToWrite, offset, function(err)
          assert(not err, err)
          vim.uv.fs_close(fd, function(err)
            assert(not err, err)
            return callback(data)
          end)
        end)
      end)
    end)
  end

  writeWithSimpleErrorHandling(function(data)
    print("Writing (async) to", path)
  end)
end


-- See also
--          local isOk, result = pcall(vim.fn.readfile, testOutputFile)
--          if not isOk then
--            vim.notify("Could not read JSON config file at " .. testOutputFile, vim.log.levels.ERROR)
--          end
M.read_text_file = function(path, config)
  local fd = vim.uv.fs_open(path, "r")
end

-- Get lua module path
--
-- Usage: Be sure to call this function early in the module for accuracy
-- as it refers to the Lua stack.
--:
-- @remarks
-- The reason for this complexity of the match is to handle Windows paths too.
--
-- @returns an absolute path pointing to the lua module
M.get_module_path = function()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*[/\\])") or "./"
end

-- TODO
M.move_range_up = function()
  --local current_range = -- could just be a line or selection
  --local cmd = 'move'
  --local destination = -- move up of range means get line above first line of range and move there.
end
-- TODO
M.move_range_down = function()
  --local current_range = -- could just be a line or selection
  --local cmd = 'move'
  --local destination = -- move up of range means get line above first line of range and move there.
end

M.getWords = function()
  return tostring(fn.wordcount().words)
end

M.printLSPCapabilities = function()
  print(vim.inspect(vim.lsp.buf_get_clients()[1].resolved_capabilities))
end

M.get_visual_selection = function()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

M.textToClipboard = function(text)
  require('osc52').copy(text);
end

M.copy = function(input)
  if input ~= nil then
    vim.notify(string.format("Copying %s to clipboard and unnamed register \"", input))
    
    vim.api.nvim_command("let @\" = '" .. input .. "'")
    require('osc52').copy(input);
   return input
  end

  local mode = vim.api.nvim_get_mode()["mode"]
  if mode == "n" then
    require('osc52').copy_operator();
  end
  if mode == "v" then
    vim.notify(string.format("Copying %s", M.get_visual_selection()))
    -- Yank into unnamed register
    vim.api.nvim_command("let @\" = '" .. M.get_visual_selection() .. "'")
    require('osc52').copy_visual();
  end
end

M.is_empty_table = function(t)
  if t == nil then
    return true
  end
  return next(t) == nil
end

-- Map: Apply function f over each element
--
-- No order guaranteed.
function M.map(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do
    t[k] = f(v)
  end
  return t
end

-- Map: Apply predicate to each element
--
--   @returns New table with all elements whose predicate(value) == true.
--
-- No order guaranteed.
-- @deprecated prefer M.filter
function M.filterTableOfTables(tbl_of_tables, predicate)
  local t = {}
  for _kIdx, vTbl in pairs(tbl_of_tables) do
    if predicate(vTbl) then
      table.insert(t, vTbl)
    end
  end
  return t
end

-- Applies a predicate to each element (which can be a table)
-- @example
-- function(player) return player.Team == RED or player.Team == BLUE end
-- @returns a new table with elements meeting the predicate
function M.filter(sequence, predicate)
  local newlist = {}
  for i, v in ipairs(sequence) do
    if predicate(v) then
      table.insert(newlist, v)
    end
  end
  return newlist
end

M.print_package_path = function()
  print(table.concat(split(package.path, ";"), "\n"))
end

M.todo_open = function()
  local todoPath = ""
end

M.org_imports = function()
  local clients = vim.lsp.buf_get_clients()
  for _, client in pairs(clients) do
    print(client)
    local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
    params.context = { only = { "source.organizeImports" } }

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  end
end

M.print_loaded_packages = function()
  -- See direct loaded :lua print(vim.inspect(package.loaded, { depth = 1 }))
  local packages = package.loaded
  for name, _ in pairs(packages) do
    print(name)
  end
end

M.xdg_paths = function()
  local stdpaths = {
    "cache",
    "config",
    "config_dirs",
    "data",
    "data_dirs",
    "log",
    "run",
    "state",
  }
  for _, path in pairs(stdpaths) do
    local resolved_path = vim.fn.stdpath(path)
    print("stdpath(" .. path .. ") = " .. M.to_string(resolved_path))
  end
end

M.dump = function(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. M.dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

M.to_string = function(input)
  if type(input) == "string" then
    return input
  end
  if type(input) == "table" then
    --return require('inspect')(input)
    return M.dump(input)
  end
end

M.lsp_query_cursor_position = function()
  -- @returns TextDocumentPositionParams
  P(vim.lsp.util.make_position_params())
end

M.send_lsp_request = function()
  local position_params = vim.lsp.util.make_position_params()
  local new_name = vim.fn.input("New name > ")
  position_params.newName = new_name
  -- vim.lsp.buf_request(0, 'textDocument/rename', position_params, function(err, method, result, client_id, bufnr, config)
  vim.lsp.buf_request(0, 'textDocument/rename', position_params, function(err, method, result, ...)
    print(vim.inspect(result))
    -- print("Calling rename...")
    -- --vim.lsp.handlers["textDocument/rename"](err, method, result, ...)
    -- print("... done with rename")
  end)
end

function _G.ReloadConfig()
  for name, _ in pairs(package.loaded) do
    if name:match('^cnull') then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
end

-- function M.find_root_dir()
--   local full_path = vim.fn.expand("%:p")
--   return vim.fs.dirname(vim.fs.find({"package.json"} {path = full_path, upward = true})[1])
-- end

vim.api.nvim_set_keymap('n', '<Leader>vs', '<Cmd>lua ReloadConfig()<CR>', { silent = true, noremap = true })
vim.cmd('command! ReloadConfig lua ReloadConfig()')


-- Easy way to reload modules with plenary
--require("plenary.reload").reload_module("cnull") -- replace with your own namespace

M.set_current_working_directory_to = function(config)
  local cwd = vim.loop.cwd()
  local default_path = vim.fn.expand("%:p:h")

  -- Use 'dir' as completion parameter arg to allow for tab-completion for directories
  local target_cwd = vim.fn.input("Desired Path: ", default_path, 'dir')
  vim.notify(string.format("CWD before change: %s\nCWD after change: %s", cwd, target_cwd))
  if target_cwd then
    vim.api.nvim_set_current_dir(target_cwd)
  else
    vim.notify(
      "CWD unchanged because target_cwd was nil.")
  end
end

M.set_current_working_directory_to_top_dir = function(config)
  local find_nearest_git_dir_parent = function(p) return require("lspconfig.util").find_git_ancestor(p) end
  local defaultConfig = {
    path = vim.fn.expand("%:p")
  }
  local conf = config or defaultConfig
  vim.notify(string.format("functions.set_current_working_directory_to_top_dir(%s) called.", vim.inspect(config)),
    vim.log.levels.DEBUG)
  local git_dir = find_nearest_git_dir_parent(conf.path)
  return vim.loop.cwd()
end

return M
