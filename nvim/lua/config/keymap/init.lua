-- https://www.reddit.com/r/neovim/comments/u8jct5/a_stupid_but_effective_way_completely_native_to/
-- above regarding anonymous keymaps in nvim-tree when querying key maps
--
-- For TELESCOPE review :help telescope.command to understand calling conventions, prefer lua because viml does not support spaces in options.

-- Doc: Following is native Lua approach to keymaps
-- --[[ keys.lua ]]
-- local map = vim.api.nvim_set_keymap
--
-- -- remap the key used to leave insert mode
-- map('i', 'jk', '', {})
-- Toggle more plugins
-- map('n', 'l', [[:IndentLinesToggle]], {})
-- map('n', 't', [[:TagbarToggle]], {})
-- map('n', 'ff', [[:Telescope find_files]], {})


-- Doc: Using nvim-mapper
-- Reload this file dynamically at runtime using:
-- <cmd>luafile %
-- A stock keymap vim.api.nvim_set_keymap('n', '<leader>P', ":MarkdownPreview<CR>", {silent = true, noremap = true})

vim.cmd(":vnoremap < <gv") -- reselect visual block after demoting block (opposite of indent)
vim.cmd(":vnoremap > >gv") -- reselect visual block after promoting block (indent)


-- exit terminal mode to normal mode
vim.cmd('tnoremap <ESC> <C-\\><C-n>')
-- Send ESC char sequence to underlying program in terminal
vim.cmd('tnoremap <C-v><Esc> <Esc>')

local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
--local keymap = vim.api.nvim_set_keymap --builtin method

-- For associative arrays
function object_assign(t1, t2)
  for key, value in pairs(t2) do
    t1[key] = value
  end

  return t1
end

--vim.keymap.set("n", "<leader>cwd",
--  function()
--    P(vim.fn.expand("%p"))
--    P(require("lspconfig.util").root_pattern(".git", "package.json")(vim.fn.expand("%p")))
--  end,
--  { desc = "(Re)set current working directory to nearest .git anscestor of buffer's file." })


----------------------------------------------------------------------
--                      Open Help Topic Alias                       --
----------------------------------------------------------------------
function open_help_topic(keyword)
  vim.cmd('vert bel help ' .. keyword)
end

----------------------------------------------------------------------
--                       Git Worktrees Keymap                       --
----------------------------------------------------------------------
vim.keymap.set("n", "<leader>pgw", ":lua require('telescope').extensions.git_worktree.git_worktrees()<cr>",
  { desc = "Pick Work Tree (git-worktree)" })
vim.keymap.set("n", "<leader>pwt", ":lua require('telescope').extensions.git_worktree.git_worktrees()<cr>",
  { desc = "Pick Work Tree (git-worktree)" })
vim.keymap.set("n", "<leader>gwn", ":lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>",
  { desc = "Create New Git Worktree" })

--------------------------------------------------------------------------------
--                             Working Directory                              --
--------------------------------------------------------------------------------
--vim.keymap.set("n", "<leader>swd", function()
--    local job_id = vim.fn.jobstart({ "echo", "hello" }, {
--      stdout_buffered = true,
--      on_exit = function() end,
--      on_stdout = function(_, data)
--        if not data then return end
--        for _, line in ipairs(data) do print(line) end
--      end,
--      on_stderr = function(_, data) end,
--      pty = true,
--      rpc = false,
--      stderr_buffered = false,
--      detach = false,
--    })
--    print("job_id: ", job_id)
--  end
--  ,
--  { desc = "Reset current working directory to git root." })
-- git rev-parse --show-toplevel


--------------------------------------------------------------------------------
--                      Native Keymaps (nvim-mapper removed)                  --
--------------------------------------------------------------------------------
-- Load portable helpers for safe operations
local portable = require('config.portable')
-- Remove dependency on external Mapper package
-- Use portable.safe_keymap directly
local portable = require('config.portable')
local safe_keymap = portable.safe_keymap

-- M.map(mode, keys, cmd, options, category, unique_identifier, description)
-- The follow show up using <leader>MM
--
-- BEGIN TELESCOPE
safe_keymap('n', '<leader>rs', '<cmd>/\\%u2713<CR>', opts, "search-buffer-testcafe-success-char",
  "Search buffer for TestCafe test success char.")
safe_keymap('n', '<leader>rf', '<cmd>/\\%u2716<CR>', opts, "search-buffer-testcafe-failure-char",
  "Search buffer for TestCafe test failure char.")
safe_keymap('n', '<leader>hl', function() open_help_topic('lua-guide') end, opts, "help-lua-guide", "Help Lua Guide")
safe_keymap('n', '<leader>pm', "<cmd>Telescope mapper<cr>", opts, "Telescope-Keys", "mapper", "Open custom keymaps.") -- OPEN VISUAL OF THIS FILE
safe_keymap('n', '<leader>pmm', "<cmd>Neotree float reveal_file=~/.config/nvim/lua/config/keymap.lua reveal_force_cwd<cr>"
, opts, "Edit-KeyMapper", "edit-mapper", "Open custom keymaps for changes.")                                         -- OPEN VISUAL OF THIS FILE
safe_keymap('n', '<leader>pk', "<cmd>Telescope keymaps<cr>", opts, "Telescope-Keys", "keymaps",
  "Open keymap search for all key maps")
safe_keymap('n', '<leader>pb', "<cmd>lua require'telescope.builtin'.buffers()<cr>", { silent = true, noremap = true },
  "Telescope-vim", "vim-buffers", "Picker for buffers")
safe_keymap('n', '<leader>pt', "<cmd>lua require'telescope-tabs'.list_tabs()<cr>", { silent = true, noremap = true },
  "Telescope-vim", "vim-tabs", "Picker for tabs")
safe_keymap('n', '<leader>pcs', "<cmd>lua require'telescope.builtin'.colorscheme()<cr>", { silent = true, noremap = true }
, "Telescope-vim", "vim-colorscheme", "Picker for color schemes")
safe_keymap('n', '<leader>pmp', "<cmd>lua require'telescope.builtin'.man_pages()<cr>", { silent = true, noremap = true },
  "Telescope-man", "man-pages", "pick-man-pages: Picker for man-pages")
safe_keymap('n', '<leader>plr', "<cmd>lua require'telescope.builtin'.lsp_references()<cr>",
  { silent = true, noremap = true }, "Telescope-Symbols", "lsp_references",
  "Picker for all references to symbol under cursor")
-- safe_keymap('n', '<leader>plic', "<cmd>lua require'telescope.builtin'.lsp_incoming_calls()<cr>",
--   { silent = true, noremap = true }, "Telescope-LSP", "lsp_incoming_calls",
--   "pick-incoming-calls: Picker for incoming calls in LSP for symbol under cursor")
-- safe_keymap('n', '<leader>plic', "<cmd>lua require'telescope.builtin'.lsp_outgoing_calls()<cr>",
--   { silent = true, noremap = true }, "Telescope-LSP", "lsp_outgoing_calls",
--   "pick-outgoing-calls: Picker for outgoing calls in LSP for symbol under cursor")
-- safe_keymap('n', '<leader>pld', "<cmd>lua require'telescope.builtin'.lsp_definitions()<cr>",
--   { silent = true, noremap = true }, "Telescope-LSP", "lsp_definitions",
--   "pick-definitions: Picker for defintions in LSP for symbol under cursor")
-- safe_keymap('n', '<leader>pltd', "<cmd>lua require'telescope.builtin'.lsp_type_definitions()<cr>",
--   { silent = true, noremap = true }, "Telescope-LSP", "lsp_type_definitions",
--   "pick-type-definitions: Picker for type defintions in LSP for symbol under cursor")
safe_keymap('n', '<leader>pgc', "<cmd>lua require'telescope.builtin'.git_commits()<cr>", { silent = true, noremap = true }
, "Telescope-Git", "git_commits", "Picker for git commits")
safe_keymap('n', '<leader>pgb', "<cmd>lua require'telescope.builtin'.git_branches()<cr>",
  { silent = true, noremap = true }
  , "Telescope-Git", "git_branches", "Picker for git branches")
safe_keymap('n', '<leader>pgs', "<cmd>lua require'telescope.builtin'.git_status()<cr>", { silent = true, noremap = true }
, "Telescope-Git", "git_status", "Picker for git branches")
safe_keymap('n', '<leader>ph', "<cmd>Telescope help_tags<cr>", { silent = true, noremap = true }, "Telescope", "help_tags"
, "Open help tag picker.")
safe_keymap('n', '<leader>g', "<cmd>lua require'telescope.builtin'.grep_string({use_regex=true})<cr>",
  { silent = true, noremap = true }, "Telescope", "grep_string",
  "Search for string under cursor in current working directory.")
safe_keymap('n', '<leader>pca', "<cmd>lua vim.lsp.buf.code_action()<CR>", opts, "Telescope", "lsp_code_actions",
  "pick-code-actions LSP-detected code actions.")


-- END TELESCOPE

--safe_keymap('n', '<leader><leader>x', 'exec_verbose("vim.cmd(echo \"write | source %\")")', opts, "Helper", "execute_file_by_sourcing_it", "Neovim execute file by sourcing it.")
safe_keymap('n', '<leader><leader>x', 'vim.cmd({cmd="write"})<CR>', opts, "Helper", "execute_file_by_sourcing_it",
  "Neovim execute file by sourcing it.")

-- global maps
safe_keymap('n', '<leader>P', ":MarkdownPreview<CR>", { silent = true, noremap = true }, "Markdown", "md_preview",
  "Display Markdown preview in Qutebrowser")
safe_keymap('n', '<leader>tf', "<cmd>Neotree action=focus position=left reveal_file=%:p<CR>", opts, "Files",
  "nvimtree-open-select-buffer-file",
  "Tree file :: Select buffer's file in  nvim-tree")
safe_keymap('n', '<leader>tt', ":Neotree toggle left<CR>", { silent = true, noremap = true }, "Files", "nvimtree-toggle",
  "Toggle Neotree")
--vim.api.nvim_set_keymap("n", "<leader>to", "<cmd>Oil --float " .. vim.loop.cwd()  .. "<CR>",
--  { desc = "Open Oil at current working directory." })
--safe_keymap('n', '<leader>tc', ":Neotree float reveal_force_cwd dir=~/.config/nvim<CR>", { silent = true, noremap = true }
--  , "Files",
--  "neotree-open-config",
--  "Toggle Neotree Open config. Note this command causes Neotree to breakdown if used while inside neotree buffer.")
--vim.api.nvim_set_keymap("n", "<leader>tc", "<cmd>Oil --float ~/.config/nvim<CR>",
--  { desc = "Toggle Oil Open Lua Config Directory" })
--safe_keymap('n', '<leader>td', ":Neotree float reveal_force_cwd dir=~/Downloads<CR>", { silent = true, noremap = true }
--  , "Files",
--  "neotree-open-downloads", "Toggle Neotree Open Downloads")
--safe_keymap('n', '-', ":Neotree show left<CR>", { silent = true, noremap = true }, "Files", "neotree-open",
--  "Toggle Neotree")
--safe_keymap('v', '<leader>gY', '<cmd>lua require"gitlinker".get_repo_url()<cr>', {silent = true}, "Gitlinker", "getrepourl", "Get Repo URL")
--safe_keymap('v', '<leader>gB', '<cmd>lua require"gitlinker".get_repo_url({action_callback = require"gitlinker.actions".open_in_browser})<cr>', {silent = true}, "Gitlinker", "gitopeninbrowser", "Open Git URL in Browser")
safe_keymap('n', '<leader>p', "<cmd>lua local text=vim.fn.expand('%:p') require'osc52'.copy(text) print(text) <CR>",
  { silent = true, noremap = true }, "Paths", "bufferpath",
  "Show absolute path associated with current buffer.")

-- BEGIN COLOR THEME
safe_keymap('n', '<leader>nm', function() require 'colorscheme_select'.toggle() end, { silent = true, noremap = true },
  "Colorscheme", "toggle_colors", "Toggle light and dark color schemes")
-- END COLOR THEME

safe_keymap('n', '<leader><leader>o', '<cmd>!open "%"<CR>', opts, 'Exec', 'exec-open', 'Open in native application.')

-- buffer-specific maps
-- safe_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {noremap = true, silent = true}, "LSP", "lsp_definitions", "Go to definition")
-- safe_keymap_buf(bufnr, "n", "<leader>wl", {silent=true, noremap=true}, "", "", "Wrap ")


-- " Press i to enter insert mode, and ii to exit insert mode.
-- :inoremap ii <Esc>
-- :inoremap jk <Esc>
-- :inoremap kj <Esc>
-- :vnoremap jk <Esc>
-- :vnoremap kj <Esc>

safe_keymap("i", "ii", "<ESC><ESC>", { silent = true, noremap = true }, "General", "enterexitinsert",
  "i to enter insert mode, ii to exit insert mode")


safe_keymap("n", "<leader>yf",
  "<cmd>let @+=expand('%:p') | lua require('osc52').copy(vim.fn.expand('%:p')); print('Copied buffer file path to register @ and system clipboard: ' ..vim.fn.expand('%:p'))<CR>"
  ,
  { silent = true, noremap = true }, "Copy", "filepathtoclipboard", "Copies buffer filepath to clipboard and default @ register")
-- TODO weakness: does not work in visual mode because get_buf_range_url defaults to normal and we have no access to mode in closure around cmd
safe_keymap("n", "<leader>yr", function() require 'gitlinker'.get_buf_range_url() end, opts, "Copy",
  "gitlinkercopybufrangeurl", "Copies Git web app permalink URL from selected range")
safe_keymap("n", "<leader>yd", "<cmd>let @+=expand('%:p:h')<CR>", { silent = true, noremap = true }, "Copy",
  "pwdtoclipboard", "Copies pwd of buffer to clipboard")
-- " copies filepath to clipboard by pressing yf
-- :nnoremap <silent> yf :let @+=expand('%:p')<CR>
-- " copies pwd to clipboard: command yd
-- :nnoremap <silent> yd :let @+=expand('%:p:h')<CR>

-- safe_keymap('n', '<leader>l', ':IndentLinesToggle<CR>', { silent = true, noremap = true }, "Display", "toggleshowindent",
--   "Toggle IndentLinesToggle")
-- Toggle more plugins
-- map('n', 'l', [[:IndentLinesToggle]], {})
-- map('n', 't', [[:TagbarToggle]], {})
-- map('n', 'ff', [[:Telescope find_files]], {})
safe_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts, 'LSP', 'lsp.buf.declaration', 'Jump to declaration')
safe_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts, 'LSP', 'lsp.buf.definition', 'Jump to definition')
--safe_keymap('n', '<S-k>', '<cmd>lua vim.lsp.buf.hover()<CR>', opts, 'LSP', 'lsp.buf.hover', 'Hover')
--safe_keymap('n', '<S-k>', '<cmd>lua require("hover").hover()<CR>', opts, 'Hover', 'hover.hover',
--  'Hover using hover.nvim providers')
safe_keymap('n', '<leader><S-k>',
  function()
    vim.cmd('Lspsaga peek_definition')
    vim.notify("Lspsaga peek_definition executed")
  end, opts, 'LSP', 'Lspsaga peek_definition ')
safe_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts, 'LSP', 'lsp.buf.implementation',
  'Show implementation')
-- safe_keymap('n', '<leader>i', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>', opts, 'LSP', 'lsp.bug.incoming_calls',
--   'Show callers (inbound)') -- "quickfix" list of call sites
-- safe_keymap('n', '<leader>o', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>', opts, 'LSP', 'lsp.buf.outgoing_calls',
--   'Show calls (outbound)')  -- "quickfix" list of called
-- safe_keymap('n', '<S-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts, 'LSP', 'lsb.buf.signature_help',
--   'Show signature')
--  'Show definition in floating window')
-- safe_keymap('n', '<leader>o', '<cmd>Lspsaga outline<CR>', opts, 'Lspsaga-outline', 'Lspsaga outline',
--   'Toggle Outline of Symbols in buffer categorized.')
safe_keymap('n', '<leader>hr', '<cmd>lua vim.lsp.util.buf_highlight_references<CR>', opts, 'LSP',
  'lsp.util.buf_highlight_references', 'Highlight references')
safe_keymap('n', '<leader>hc', '<cmd>lua vim.lsp.util.buf_clear_references<CR>', opts, 'LSP',
  'lsp.util.buf_clear_references', 'Clear highlighted references')
safe_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts, 'LSP', 'lsp.buf.references', 'Show all references')
safe_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts, 'LSP',
  'lsp.buf.add_workspace_folder', 'Add Workspace')
safe_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts, 'LSP',
  'lsp.buf.remove_workspace_folder', 'Remove Workspace')
safe_keymap('n', '<leader>ws', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts, 'LSP', 'lsp.buf.workspace_symbol',
  'Show all symbols in Workspace') -- list all symbols in workspace
safe_keymap('n', '<leader>wl',
  '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts, 'LSP', 'lsp.buf.list_workspace_folders'
  , 'Show Workspaces')
safe_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts, 'LSP', 'lsp.buf.type_definition',
  'Show type definition')
safe_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts, 'LSP', 'lsp.buf.rename',
  'Rename symbols in workspace') -- rename all refs to symbol
safe_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts, 'LSP', 'lsp.buf.code_action',
  'TODO: What do I do?')
safe_keymap('n', '<leader>y', '<cmd>lua require("osc52").copy_operator()<CR>', { expr = true }, 'OSC52',
  'osc52_copy_operator', 'Copy to clipboard.')
--safe_keymap('n', '<leader>cc', '<leader>c_', { remap = true }, 'OSC52', 'osc52_copy_operator_remap', 'Copy to clipboard.')
safe_keymap('v', '<leader>c', '<cmd>lua require("osc52").copy_visual()<CR>', opts, 'OSC52', 'osc52_copy_visual',
  'Copy to clipboard.')

safe_keymap('n', '<leader>de', '<cmd>lua vim.diagnostic.show_line_diagnostics()<CR>', opts, 'LSP',
  'vim.diagnostic.show_line_diagnostics', 'Diagnose line')
safe_keymap('n', '<leader>dp', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts, 'LSP', 'vim.diagnostic.goto_prev',
  'Go to previous diagnosis')
safe_keymap('n', '<leader>dn', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts, 'LSP', 'vim.diagnostic.goto_next',
  'Go to next diagnosis')
safe_keymap('n', '<leader>dl', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts, 'LSP', 'vim.diagnostic.set_loclist',
  'Put all diagnostic messages into location list.')
safe_keymap('n', '<leader>dq', '<cmd>lua vim.diagnostic.set_qflist()<CR>', opts, 'LSP', 'vim.diagnostic.set_qflist',
  'Put all diagnostic messages into quickfix list.')

safe_keymap('n', '<leader>qw', function() print(vim.loop.cwd()) end, opts, 'Query', 'vim.fn.getwd',
  'Query current working directory.')

-- Does not work properly
safe_keymap('v', '<leader>cu',
  -- line1 = vim.api.nvim_buf_get_mark(0, "<")[1]
  -- line2 = vim.api.nvim_buf_get_mark(0, ">")[1]
  "<cmd>" .. [["'<,'>s/\<./\u&/"]] .. "<CR>"
  , opts, 'AlphabetCase', 'regex.uppercase.firstletter', 'Make first letter in line upper case.')


--local format_workspace = function()
--    request(0, 'workspace/executeCommand', {
--    command = 'eslint.applyAllFixes',
--    arguments = {
--      {
--        uri = vim.uri_from_bufnr(bufnr),
--        version = lsp.util.buf_versions[bufnr],
--      },
--    },
--  })
--end



safe_keymap('n', '<leader>pse', '<cmd>lua require("luasnip.loaders").edit_snippet_files(nil)<CR>', opts, 'Snippets',
  'edit_snippet_files', 'Edit snippet files')

--safe_keymap('n', '<leader>ts',
--    require 'neo-tree.command'.execute({
--      action = 'focus',
--      source = 'filesystem',
--      position = 'left',
--      dir = vim.fn.stdpath('config') .. '/snippets'
--    }), options, 'Tree', 'neotree.execute.open_file.snippets',
--  'Open Snippets directory in file tree.')

-- TODO convert to true Telescope extension (Telescope depends on this and calls it in setup)
--safe_keymap('n', '<leader><leader>pn', '<cmd>lua require("special.files").list_special_files()<CR>', opts, 'SpecialFiles',
--  'special.files.list_files', 'List special files in Telescope.')

local grep_special_files = function()
  local search_dir = vim.g.jonathans_special_files
  require 'telescope.builtin'.live_grep({
    prompt_title = 'Grep ' .. search_dir,
    search_dir = { search_dir },
    cwd = search_dir,
    grep_open_files = false
  }
  )
end
safe_keymap('n', '<leader><leader>pfg',
  function() grep_special_files() end, opts,
  'SpecialFiles',
  'special.files.live_grep', 'Grep over special files in Telescope.')

--safe_keymap('n', '<leader>tr', require 'neo-tree.command'.execute({
--      action = 'focus',
--      source = 'filesystem',
--      position = 'left',
--      reveal=true}), opts, 'NeoTree', 'neo-tree.reveal', 'Reveal file in tree.')

-- BEGIN CMP Autocompletion
--    safe_keymap('n', ['<Tab>'] = function(fallback)
--    safe_keymap('n',   if cmp.visible() then
--    safe_keymap('n',     cmp.select_next_item()
--    safe_keymap('n',   else
--    safe_keymap('n',     fallback()
--    safe_keymap('n',   end
--    safe_keymap('n', end,
--    safe_keymap('n', ['<C-n>'] = cmp.mapping.select_next_item(select_opts), --cmp.mapping.select_prev_item(),
--    safe_keymap('n', ['<C-p>'] = cmp.mapping.select_prev_item(select_opts), --cmp.mapping.select_next_item(),
--    safe_keymap('n', ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
--    safe_keymap('n', ['<Down>'] = cmp.mapping.select_next_item(select_opts),
--    safe_keymap('n', ['<C-Space>'] = cmp.mapping.complete(select_opts),
--    safe_keymap('n', ["<C-d>"] = cmp.mapping.scroll_docs(-4),
--    safe_keymap('n', ["<C-f>"] = cmp.mapping.scroll_docs(4),
--    safe_keymap('n', ["<C-e>"] = cmp.mapping.close(),
--    safe_keymap('n', ["<C-y>"] = cmp.mapping.confirm({
--    safe_keymap('n',   behavior = cmp.ConfirmBehavior.Insert,
--    safe_keymap('n',   select = true,
--    safe_keymap('n', }),
--  },
-- END CMP Autocompletion

local function luasnip_safe_jump_forward()
  local ls = require('luasnip')
  if ls.jumpable(1) then
    ls.jump(1)
  end
end

safe_keymap({ "i", "s" }, "<c-f>", luasnip_safe_jump_forward, opts, 'Snippets', 'luasnip_jump_forward',
  'Move cursor to next insert placeholder.')

local function luasnip_safe_jump_backward()
  local ls = require('luasnip')
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end

safe_keymap({ "i", "s" }, "<c-b>", luasnip_safe_jump_backward, opts, 'Snippets', 'luasnip_jump_backward',
  'Move cursor to previous insert placeholder.')

local function luasnip_safe_expand_or_jump()
  local ls = require('luasnip')
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end

safe_keymap({ "i", "s" }, "<c-s>", luasnip_safe_expand_or_jump, opts, 'Snippets', 'luasnip_expand_or_jump',
  'Expand text under cursor or jump')

-- Disabled in favor of local Keymap in nvim-cmp
-- vim.keymap.set("i", "<c-e>", function() require('luasnip').expand() end,
--   { desc = "Expand snippet before cursor" })



--local FORWARD = 1
--safe_keymap({ "i", "s" }, "<C-c>", require 'luasnip'.change_choice(FORWARD), 'Snippets', 'luasnip.change_choice_forward', 'Switch to next choice.')

safe_keymap("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/setup/luasnip.lua<CR>", opts, "Snippets", "reload",
  "Reload the luasnip file at runtime.")

-- -- <c-k> expansion key to find snippet for word under cursor
-- vim.keymap.set({ "i", "s" }, "<c-s>", function()
--   if ls.expand_or_jumpable() then
--     ls.expand_or_jump()
--   end
-- end, { silent = true })
--
-- -- -- <c-j> jump backwards key
-- vim.keymap.set({ "i", "s" }, "<c-a>", function()
--   if ls.jumpable(-1) then
--     ls.jump(-1)
--   end
-- end, { silent = true })
--
-- -- -- <c-l> cycle list of options
-- vim.keymap.set("i", "<c-l>", function()
--   if ls.choice_active() then
--     ls.change_choice(1)
--   end
-- end)
require('config.keymap.quickfix')
require('config.keymap.current_working_dir')
require('config.keymap.open_in_file_browser')
require('config.keymap.json')

--------------------------------------------------------------------------------
--                      Orgmode Global Keybindings                            --
--------------------------------------------------------------------------------
-- Orgmode keybindings moved to lua/plugins/orgmode/orgmode.lua `keys` property
-- This ensures lazy.nvim registers them immediately at startup for proper lazy-loading

return {}
