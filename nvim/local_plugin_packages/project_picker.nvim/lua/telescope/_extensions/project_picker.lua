-- Telescope extension for project_picker
local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('project_picker.nvim requires telescope.nvim')
end

local project_picker = require('project_picker')

return telescope.register_extension({
  setup = function(ext_config, config)
    -- Extension setup if needed
  end,
  exports = {
    projects = function(opts)
      local all_projects = {}
      local config = project_picker._get_config and project_picker._get_config() or require('project_picker')._config or
      {}

      for name, src in pairs(config.sources or {}) do
        local function expand_globs(pattern)
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
          return res
        end

        local dirs = expand_roots(src.roots)
        for _, d in ipairs(dirs) do
          table.insert(all_projects, { path = d, source = name })
        end
      end

      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf_module = require('telescope.config')
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      pickers.new(opts or {}, {
        prompt_title = 'All Projects',
        finder = finders.new_table({
          results = all_projects,
          entry_maker = function(item)
            local path = item.path:gsub('/$', '')
            local name = vim.fn.fnamemodify(path, ':t')
            local display = string.format('[%s] %s', item.source, name)
            return {
              value = item,
              display = display,
              ordinal = display,
            }
          end
        }),
        sorter = conf_module.values.generic_sorter(opts or {}),
        attach_mappings = function(bufnr, _)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(bufnr)
            local path = selection.value.path
            local cb = (config.on_select or function(p)
              vim.cmd('cd ' .. vim.fn.fnameescape(p))
              require('telescope.builtin').find_files({ cwd = p })
            end)
            cb(path)
          end)
          return true
        end,
      }):find()
    end,

    sources = function(opts)
      local config = project_picker._get_config and project_picker._get_config() or require('project_picker')._config or
      {}
      local sources_list = {}

      for name, _ in pairs(config.sources or {}) do
        table.insert(sources_list, { name = name })
      end

      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf_module = require('telescope.config')
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      pickers.new(opts or {}, {
        prompt_title = 'Project Sources',
        finder = finders.new_table({
          results = sources_list,
          entry_maker = function(item)
            return {
              value = item,
              display = item.name,
              ordinal = item.name,
            }
          end
        }),
        sorter = conf_module.values.generic_sorter(opts or {}),
        attach_mappings = function(bufnr, _)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(bufnr)
            require('telescope').extensions.project_picker.source({ name = selection.value.name })
          end)
          return true
        end,
      }):find()
    end,

    source = function(opts)
      local name = opts and opts.name
      if not name then
        return require('telescope').extensions.project_picker.sources(opts)
      end

      local config = project_picker._get_config and project_picker._get_config() or require('project_picker')._config or
      {}
      local src = (config.sources or {})[name]
      if not src then
        vim.notify('Source not found: ' .. name, vim.log.levels.ERROR)
        return
      end

      local function expand_globs(pattern)
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
        return res
      end

      local dirs = expand_roots(src.roots)
      local projects = {}
      for _, d in ipairs(dirs) do
        table.insert(projects, { path = d, source = name })
      end

      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf_module = require('telescope.config')
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      pickers.new(opts or {}, {
        prompt_title = 'Projects: ' .. name,
        finder = finders.new_table({
          results = projects,
          entry_maker = function(item)
            local proj_name = vim.fn.fnamemodify(item.path, ':t')
            return {
              value = item,
              display = string.format('%s   %s', proj_name, item.path),
              ordinal = proj_name,
            }
          end
        }),
        sorter = conf_module.values.generic_sorter(opts or {}),
        attach_mappings = function(bufnr, _)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(bufnr)
            local path = selection.value.path
            local cb = (config.on_select or function(p)
              vim.cmd('cd ' .. vim.fn.fnameescape(p))
              require('telescope.builtin').find_files({ cwd = p })
            end)
            cb(path)
          end)
          return true
        end,
      }):find()
    end,
  },
})
