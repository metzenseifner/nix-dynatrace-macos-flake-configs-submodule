-- nix.conf settings index — the keys a freeform option cannot declare.
--
-- Algebraic shape:
--
--   Σ_declared ⊂ Σ_nix.conf        |Σ_declared| = 12     |Σ_nix.conf| = 124
--
-- `nix.settings` (nix-darwin and NixOS alike) is a *freeform* submodule:
-- `attrsOf (nix config atom | list of atoms)`. Only the dozen keys the module
-- spells out exist as options; every other nix.conf key is admitted by type
-- alone and is therefore absent from the option tree. That is why hovering
-- `settings` lists a few keys and stops — and why no option-aware server
-- (nil, nixd) can do better: the information is not in the options.
--
-- Plain English: the authority for the full key set is the Nix binary itself.
-- `:NixConf` lists every setting `nix config show --json` reports, with its
-- description, its default, and the value in effect on this machine. <CR>
-- inserts `<key> = ` at the cursor.
--
-- Related: modules/neovim/lsps/nixd.lua documents the *declared* options.

local M = {}

local cached ---@type table<string, table>|nil

-- Σ_nix.conf as reported by the running Nix. Cached for the session.
local function nix_conf()
  if cached then
    return cached
  end
  if vim.fn.executable('nix') ~= 1 then
    vim.notify('nix not found in PATH', vim.log.levels.ERROR)
    return nil
  end
  local res = vim.system({ 'nix', 'config', 'show', '--json' }, { text = true }):wait(15000)
  if res.code ~= 0 then
    vim.notify('nix config show failed: ' .. (res.stderr or ''), vim.log.levels.ERROR)
    return nil
  end
  local ok, decoded = pcall(vim.json.decode, res.stdout)
  if not ok or type(decoded) ~= 'table' then
    vim.notify('could not decode nix config show --json', vim.log.levels.ERROR)
    return nil
  end
  cached = decoded
  return cached
end

local function render(value)
  if type(value) == 'table' then
    if vim.tbl_isempty(value) then
      return '[]'
    end
    return table.concat(vim.tbl_map(tostring, value), ' ')
  end
  return tostring(value)
end

local function first_line(description)
  for line in (description or ''):gmatch('[^\n]+') do
    if line:match('%S') then
      return line
    end
  end
  return ''
end

-- Σ_nix.conf -> [{ name, setting }] ordered by name.
local function entries()
  local conf = nix_conf()
  if not conf then
    return nil
  end
  local names = vim.tbl_keys(conf)
  table.sort(names)
  return vim.tbl_map(function(name)
    return { name = name, setting = conf[name] }
  end, names)
end

local function detail(entry)
  local s = entry.setting
  local lines = {
    '# ' .. entry.name,
    '',
    '- default: `' .. render(s.defaultValue) .. '`',
    '- in effect here: `' .. render(s.value) .. '`',
  }
  if s.aliases and not vim.tbl_isempty(s.aliases) then
    table.insert(lines, '- aliases: `' .. table.concat(s.aliases, ', ') .. '`')
  end
  if s.experimentalFeature then
    table.insert(lines, '- requires experimental feature: `' .. s.experimentalFeature .. '`')
  end
  table.insert(lines, '')
  for line in (s.description or ''):gmatch('([^\n]*)\n?') do
    table.insert(lines, line)
  end
  return lines
end

local function insert_key(name)
  vim.api.nvim_put({ name .. ' = ' }, 'c', true, true)
  vim.cmd('startinsert!')
end

local function telescope_picker(items)
  local ok, pickers = pcall(require, 'telescope.pickers')
  if not ok then
    return false
  end
  local finders = require('telescope.finders')
  local previewers = require('telescope.previewers')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers.new({}, {
    prompt_title = 'nix.conf settings (' .. #items .. ')',
    finder = finders.new_table({
      results = items,
      entry_maker = function(item)
        return {
          value = item.name,
          ordinal = item.name .. ' ' .. first_line(item.setting.description),
          display = string.format('%-34s %s', item.name, first_line(item.setting.description)),
          item = item,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'nix.conf setting',
      define_preview = function(self, entry)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, detail(entry.item))
        vim.bo[self.state.bufnr].filetype = 'markdown'
      end,
    }),
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(bufnr)
        if entry then
          insert_key(entry.value)
        end
      end)
      return true
    end,
  }):find()
  return true
end

function M.open()
  local items = entries()
  if not items then
    return
  end
  if telescope_picker(items) then
    return
  end
  -- Fallback when telescope is unavailable.
  vim.ui.select(items, {
    prompt = 'nix.conf setting',
    format_item = function(item)
      return string.format('%-34s %s', item.name, first_line(item.setting.description))
    end,
  }, function(item)
    if item then
      insert_key(item.name)
    end
  end)
end

function M.setup()
  vim.api.nvim_create_user_command('NixConf', function()
    M.open()
  end, { desc = 'Browse every nix.conf setting (the freeform half of nix.settings)' })
end

return M
