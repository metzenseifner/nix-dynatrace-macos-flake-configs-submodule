-- Option-tree browser — "what keys may this attribute set hold?"
--
-- Algebraic shape:
--
--   path       : Buffer × Cursor -> [Segment]         (via treesitter)
--   resolve    : OptionTree × [Segment] -> Option ⊕ Branch ⊕ ∅
--   children   : Option ⊕ Branch -> [{ name, type, description }]
--
-- Why this exists: hover (K) answers "what is *this* symbol", and no
-- language server answers it with the children of a submodule — nixd
-- returns "? (missing type)" for `nix.settings` and `system.defaults`,
-- and nil returns its own inferred type, elided after a few fields. The
-- enumeration lives in the evaluated option tree, so this asks the option
-- tree directly: `:NixOptions` resolves the attribute path under the
-- cursor against this flake's darwin, NixOS and home-manager options and
-- lists every declared child with its type and documentation.
--
-- Plain English: put the cursor anywhere in `nix.settings = { … }` and run
-- `:NixOptions` to get a searchable list of the keys that option declares.
-- <CR> inserts the selected key. A *freeform* option (`nix.settings`) says
-- so in the title, because its remaining keys are not declared anywhere in
-- the option tree — see :NixConf (config/nix_conf_options.lua).
--
-- Related: modules/neovim/lsps/nixd.lua uses the same host-picking rule to
-- document a single option under the cursor.

local M = {}

local uv = vim.uv or vim.loop

--------------------------------------------------------------------------------
-- Attribute path under the cursor
--------------------------------------------------------------------------------

local function node_text(node)
  return vim.treesitter.get_node_text(node, 0)
end

local function attrpath_of(binding)
  local ok, field = pcall(function()
    return binding:field('attrpath')[1]
  end)
  if ok and field then
    return field
  end
  for child in binding:iter_children() do
    if child:type() == 'attrpath' then
      return child
    end
  end
  return nil
end

-- Segments of an attrpath that start at or before the cursor, so that
-- `nix.settings` with the cursor on `nix` yields just `nix`.
local function segments_before(attrpath, row, col)
  local parts = {}
  for child in attrpath:iter_children() do
    if child:named() then
      local sr, sc = child:range()
      if sr < row or (sr == row and sc <= col) then
        parts[#parts + 1] = node_text(child)
      end
    end
  end
  return parts
end

-- Attrpaths of every enclosing binding, outermost first.
local function enclosing(node)
  local parts = {}
  local n = node
  while n do
    if n:type() == 'binding' then
      local ap = attrpath_of(n)
      if ap then
        table.insert(parts, 1, node_text(ap))
      end
    end
    n = n:parent()
  end
  return parts
end

function M.path_at_cursor()
  if vim.bo.filetype ~= 'nix' then
    return nil
  end
  local ok = pcall(vim.treesitter.get_parser, 0, 'nix')
  if not ok then
    return nil
  end
  local node = vim.treesitter.get_node({ bufnr = 0, lang = 'nix' })
  if not node then
    return nil
  end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  -- Innermost attrpath containing the cursor, if the cursor is on a key.
  local attrpath = node
  while attrpath and attrpath:type() ~= 'attrpath' do
    attrpath = attrpath:parent()
  end

  local parts
  if attrpath then
    -- Climb from above the binding that owns this attrpath, so its own
    -- segments are not counted twice.
    local binding = attrpath:parent()
    parts = enclosing(binding and binding:parent() or nil)
    vim.list_extend(parts, segments_before(attrpath, row, col))
  else
    parts = enclosing(node)
  end

  local joined = table.concat(parts, '.')
  local segments = vim.split(joined, '.', { plain = true, trimempty = true })
  return #segments > 0 and segments or nil
end

--------------------------------------------------------------------------------
-- The option tree
--------------------------------------------------------------------------------

-- Same rule as modules/neovim/lsps/nixd.lua: the outermost flake.nix inside
-- the checkout, because only the top-level flake of this flake-of-flakes
-- declares darwinConfigurations and nixosConfigurations.
local function flake_root()
  local dir = vim.fs.normalize(vim.fn.expand('%:p:h'))
  local dirs = { dir }
  for parent in vim.fs.parents(dir) do
    dirs[#dirs + 1] = parent
  end
  local found = nil
  for _, d in ipairs(dirs) do
    if uv.fs_stat(d .. '/flake.nix') then
      found = d
    end
    if uv.fs_stat(d .. '/.git') then
      break
    end
  end
  return found
end

-- darwin ⊕ nixos, this host's platform first.
local function system_roots()
  local darwin = '    { source = "darwin"; value = pick "darwinConfigurations"; }'
  local nixos = '    { source = "nixos"; value = pick "nixosConfigurations"; }'
  if uv.os_uname().sysname == 'Darwin' then
    return darwin .. '\n' .. nixos
  end
  return nixos .. '\n' .. darwin
end

-- Exposed so it can be evaluated on its own:
--   :lua =require('config.nix_option_tree').query_expr(vim.uv.cwd(), { 'nix', 'settings' })
function M.query_expr(root, segments)
  local path = '[ ' .. table.concat(
    vim.tbl_map(function(s)
      return string.format('%q', s)
    end, segments),
    ' '
  ) .. ' ]'

  return string.format(
    [[
let
  flake = builtins.getFlake %q;
  host = %q;
  path = %s;

  pick =
    output:
    let
      configs = flake.${output} or { };
      names = builtins.attrNames configs;
    in
    if builtins.hasAttr host configs then configs.${host}
    else if names == [ ] then null
    else configs.${builtins.head names};

  # This host's own system first, so its documentation wins a tie.
  systems = [
%s
  ];

  homeRoots = builtins.concatMap (
    s:
    if s.value != null && builtins.hasAttr "home-manager" s.value.options then
      [ { source = "home-manager"; options = s.value.options.home-manager.users.type.getSubOptions [ ]; } ]
    else
      [ ]
  ) systems;

  roots =
    (map (s: { inherit (s) source; options = s.value.options; }) (builtins.filter (s: s.value != null) systems))
    # Every system carries the same home-manager module, so one root suffices.
    ++ (if homeRoots == [ ] then [ ] else [ (builtins.head homeRoots) ]);

  isOption = n: builtins.isAttrs n && (n._type or null) == "option";
  subOptions = node: if isOption node then node.type.getSubOptions [ ] else node;

  step =
    node: name:
    let
      attrs = subOptions node;
    in
    if builtins.isAttrs attrs && builtins.hasAttr name attrs then attrs.${name} else null;

  resolve =
    node: p:
    if node == null then null
    else if p == [ ] then node
    else resolve (step node (builtins.head p)) (builtins.tail p);

  text = d: if builtins.isAttrs d then (d.text or "") else (if d == null then "" else toString d);
  hidden = n: n == "_module" || n == "_freeformOptions";

  describe = attrs: name: {
    inherit name;
    type = if isOption attrs.${name} then attrs.${name}.type.description else "attribute set of options";
    description = if isOption attrs.${name} then text (attrs.${name}.description or "") else "";
  };

  match =
    root:
    let
      node = resolve root.options path;
      attrs = if node == null then { } else subOptions node;
      names = if builtins.isAttrs attrs then builtins.filter (n: !hidden n) (builtins.attrNames attrs) else [ ];
    in
    if node == null then
      null
    else
      {
        inherit (root) source;
        type = if isOption node then node.type.description else "attribute set of options";
        description = if isOption node then text (node.description or "") else "";
        declarations = if isOption node then map toString (node.declarations or [ ]) else [ ];
        freeform = builtins.isAttrs attrs && builtins.hasAttr "_freeformOptions" attrs;
        children = map (describe attrs) names;
      };
in
{
  path = builtins.concatStringsSep "." path;
  matches = builtins.filter (m: m != null) (map match roots);
}
]],
    root,
    uv.os_gethostname(),
    path,
    system_roots()
  )
end

--------------------------------------------------------------------------------
-- Presentation
--------------------------------------------------------------------------------

-- `.GlobalPreferences` is a legal attribute name but not a bare identifier.
local function as_attr(name)
  return name:match("^[%a_][%w_%-']*$") and name or string.format('%q', name)
end

local function first_line(s)
  for line in (s or ''):gmatch('[^\n]+') do
    if line:match('%S') then
      return line
    end
  end
  return ''
end

-- ⋃ matches, keeping the first source that declares each child.
local function merge(matches)
  local seen, items = {}, {}
  for _, m in ipairs(matches) do
    for _, child in ipairs(m.children) do
      if not seen[child.name] then
        seen[child.name] = true
        items[#items + 1] = vim.tbl_extend('error', child, { source = m.source })
      end
    end
  end
  table.sort(items, function(a, b)
    return a.name < b.name
  end)
  return items
end

local function detail(path, item)
  local lines = {
    '# ' .. path .. '.' .. item.name,
    '',
    '- type: `' .. item.type .. '`',
    '- declared by: `' .. item.source .. '`',
    '',
  }
  for line in (item.description or ''):gmatch('([^\n]*)\n?') do
    lines[#lines + 1] = line
  end
  return lines
end

local function present(path, result)
  local items = merge(result.matches)
  if #items == 0 then
    vim.notify(('%s declares no children'):format(path), vim.log.levels.WARN)
    return
  end

  local freeform = false
  local sources = {}
  for _, m in ipairs(result.matches) do
    freeform = freeform or m.freeform
    sources[#sources + 1] = m.source
  end
  local title = ('%s — %d keys [%s]'):format(path, #items, table.concat(sources, ', '))
  if freeform then
    title = title .. ' freeform: :NixConf for the rest'
  end

  local ok, pickers = pcall(require, 'telescope.pickers')
  if not ok then
    vim.ui.select(items, {
      prompt = title,
      format_item = function(item)
        return ('%-32s %s'):format(item.name, item.type)
      end,
    }, function(item)
      if item then
        vim.api.nvim_put({ as_attr(item.name) .. ' = ' }, 'c', true, true)
      end
    end)
    return
  end

  local finders = require('telescope.finders')
  local previewers = require('telescope.previewers')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers.new({}, {
    prompt_title = title,
    finder = finders.new_table({
      results = items,
      entry_maker = function(item)
        return {
          value = item.name,
          ordinal = item.name .. ' ' .. item.type .. ' ' .. first_line(item.description),
          display = ('%-32s %s'):format(item.name, item.type),
          item = item,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'option',
      define_preview = function(self, entry)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, detail(path, entry.item))
        vim.bo[self.state.bufnr].filetype = 'markdown'
      end,
    }),
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(bufnr)
        if entry then
          vim.api.nvim_put({ as_attr(entry.value) .. ' = ' }, 'c', true, true)
          vim.cmd('startinsert!')
        end
      end)
      return true
    end,
  }):find()
end

--------------------------------------------------------------------------------
-- Entry point
--------------------------------------------------------------------------------

function M.open(arg)
  local segments = (arg and arg ~= '' and vim.split(arg, '.', { plain = true, trimempty = true }))
      or M.path_at_cursor()
  if not segments then
    vim.notify('No attribute path under the cursor (pass one: :NixOptions system.defaults)',
      vim.log.levels.WARN)
    return
  end
  local root = flake_root()
  if not root then
    vim.notify('No flake.nix above this buffer', vim.log.levels.WARN)
    return
  end

  local path = table.concat(segments, '.')
  vim.notify(('Evaluating options under %s …'):format(path), vim.log.levels.INFO)
  vim.system(
    { 'nix', 'eval', '--impure', '--json', '--expr', M.query_expr(root, segments) },
    { text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 then
        vim.notify(('nix eval failed for %s:\n%s'):format(path, first_line(res.stderr or '')),
          vim.log.levels.ERROR)
        return
      end
      local decoded_ok, result = pcall(vim.json.decode, res.stdout)
      if not decoded_ok or type(result) ~= 'table' then
        vim.notify('Could not decode the option tree', vim.log.levels.ERROR)
        return
      end
      if #(result.matches or {}) == 0 then
        vim.notify(('%s is not a declared option here'):format(path), vim.log.levels.WARN)
        return
      end
      present(path, result)
    end)
  )
end

function M.setup()
  vim.api.nvim_create_user_command('NixOptions', function(cmd)
    M.open(cmd.args)
  end, {
    nargs = '?',
    desc = 'List the keys declared under the option path at the cursor (or the given one)',
  })
end

return M
