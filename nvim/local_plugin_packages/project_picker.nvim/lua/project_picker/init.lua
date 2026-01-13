-- File: lua/project_picker/init.lua
local M = {}
M._config = { sources = {}, on_select = nil }

function M._get_config()
  return M._config
end

local function expand_globs(pattern)
  -- Returns a list of directories matching the pattern (supports * and **)
  local items = vim.fn.glob(pattern, true, true)
  local dirs = {}
  for _, p in ipairs(items) do
    if vim.fn.isdirectory(p) == 1 then
      table.insert(dirs, vim.fn.fnamemodify(p, ':p'))
    end
  end
  return dirs
end

local function expand_roots(roots)
  local res = {}
  if not roots then return res end
  for _, root in ipairs(roots) do
    local matches = expand_globs(root)
    for _, m in ipairs(matches) do
      table.insert(res, m)
    end
  end
  -- dedupe + sort
  local seen, uniq = {}, {}
  for _, p in ipairs(res) do
    local key = (vim.fs and vim.fs.normalize and vim.fs.normalize(p)) or p
    if not seen[key] then
      seen[key] = true
      table.insert(uniq, p)
    end
  end
  table.sort(uniq)
  return uniq
end

local function get_all_projects()
  local all = {}
  for name, src in pairs(M._config.sources or {}) do
    local dirs = expand_roots(src.roots)
    for _, d in ipairs(dirs) do
      table.insert(all, { path = d, source = name })
    end
  end
  table.sort(all, function(a,b)
    if a.source == b.source then return a.path < b.path end
    return a.source < b.source
  end)
  return all
end

local function get_source_projects(name)
  local src = (M._config.sources or {})[name]
  if not src then return {} end
  local dirs = expand_roots(src.roots)
  local items = {}
  for _, d in ipairs(dirs) do
    table.insert(items, { path = d, source = name })
  end
  return items
end

local function default_on_select(path)
  local ok_tb, tb = pcall(require, 'telescope.builtin')
  vim.cmd('cd ' .. vim.fn.fnameescape(path))
  if ok_tb then
    tb.find_files({ cwd = path })
  else
    vim.cmd('edit ' .. vim.fn.fnameescape(path))
  end
end

local function expand_wildcard_sources(sources)
  local expanded = {}
  for name, src in pairs(sources) do
    if type(src) == "string" and src:match("/%*$") then
      local base_path = src:gsub("/%*$", "")
      if vim.fn.isdirectory(base_path) == 1 then
        local dirs = vim.fn.readdir(base_path, function(item)
          return vim.fn.isdirectory(base_path .. "/" .. item) == 1
        end)
        for _, dir in ipairs(dirs) do
          local source_name = dir
          local source_path = base_path .. "/" .. dir
          local subdirs = vim.fn.glob(source_path .. "/*", true, true)
          local roots = {}
          for _, subdir in ipairs(subdirs) do
            if vim.fn.isdirectory(subdir) == 1 then
              table.insert(roots, subdir)
            end
          end
          if #roots > 0 then
            expanded[source_name] = { roots = roots }
          end
        end
      end
    else
      expanded[name] = src
    end
  end
  return expanded
end

function M.setup(opts)
  local config = vim.tbl_deep_extend('force', {
    sources = {},
    on_select = default_on_select,
  }, opts or {})
  
  config.sources = expand_wildcard_sources(config.sources)
  M._config = config

  -- convenience commands
  vim.api.nvim_create_user_command('ProjectPickerProjects', function()
    require('telescope').extensions.project_picker.projects({})
  end, {})

  vim.api.nvim_create_user_command('ProjectPickerSources', function()
    require('telescope').extensions.project_picker.sources({})
  end, {})

  vim.api.nvim_create_user_command('ProjectPickerFromSource', function(params)
    require('telescope').extensions.project_picker.source({ name = params.args })
  end, {
    nargs = 1,
    complete = function(_, _, _)
      local names = {}
      for n, _ in pairs(M._config.sources or {}) do
        table.insert(names, n)
      end
      table.sort(names)
      return names
    end
  })
end

-- Telescope pickers
local function make_project_picker(items, opts)
  local has_telescope, _ = pcall(require, 'telescope')
  if not has_telescope then
    vim.notify('project_picker requires telescope.nvim', vim.log.levels.ERROR)
    return
  end
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers.new(opts, {
    prompt_title = opts.prompt_title or 'Projects',
    finder = finders.new_table({
      results = items,
      entry_maker = function(item)
        local name = vim.fn.fnamemodify(item.path, ':t')
        local display = string.format('%s   [%s]   %s', name, item.source, item.path)
        return {
          value = item,
          display = display,
          ordinal = display,
        }
      end
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(bufnr, _)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(bufnr)
        local path = selection.value.path
        local cb = (M._config.on_select or default_on_select)
        cb(path)
      end)
      return true
    end,
  }):find()
end

local function make_sources_picker(opts)
  local has_telescope, _ = pcall(require, 'telescope')
  if not has_telescope then
    vim.notify('project_picker requires telescope.nvim', vim.log.levels.ERROR)
    return
  end
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local items = {}
  for name, src in pairs(M._config.sources or {}) do
    local count = #expand_roots(src.roots)
    table.insert(items, { name = name, count = count })
  end
  table.sort(items, function(a,b) return a.name < b.name end)

  pickers.new(opts, {
    prompt_title = 'Project Sources',
    finder = finders.new_table({
      results = items,
      entry_maker = function(item)
        local display = string.format('%s (%d projects)', item.name, item.count)
        return {
          value = item,
          display = display,
          ordinal = display,
        }
      end
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(bufnr, _)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry().value
        actions.close(bufnr)
        make_project_picker(get_source_projects(selection.name), { prompt_title = 'Projects: ' .. selection.name })
      end)
      return true
    end
  }):find()
end

-- Telescope extension exports
local extension = {}

function extension.projects(opts)
  make_project_picker(get_all_projects(), opts or { prompt_title = 'All Projects' })
end

function extension.source(opts)
  local name = opts and opts.name or nil
  if not name then
    return make_sources_picker(opts or {})
  end
  make_project_picker(get_source_projects(name), opts or { prompt_title = 'Projects: ' .. name })
end

function extension.sources(opts)
  make_sources_picker(opts or {})
end

return M

