local vim = vim

--vim.o.sessionoptions = "buffers,curdir,folds,globals,tabpages,winpos,winsize"

-- Exposes nvm node bin to nvim
--vim.cmd[[set $PATH = '/Users/jonathan.komar/.local/share/nvm/versions/node/v16.17.0/bin:' . $PATH]]


-- :help options
-- query option:
-- To replicate the behavior of :set+=, use:
-- vim.opt.wildignore:append { "*.pyc", "node_modules" }
-- To replicate the behavior of :set^=, use:
-- vim.opt.wildignore:prepend { "new_first_value" }
-- To replicate the behavior of :set-=, use:
-- vim.opt.wildignore:remove { "node_modules" }
--
-- Example: set listchars=space:_,tab:>~
-- vim.o.listchars = 'space:_,tab:>~'
-- ::equivalent::
-- vim.opt.listchars = { space = '_', tab = '>~' }
--
-- " move between panes to left/bottom/top/right
-- " I use tmux bindings for this: tmux checks whether pane has nvim running
--
--
-- " In Lua:
-- " vim.api.nvim_set_var to set internal variables.
-- " vim.api.nvim_set_option to set options.
-- " vim.api.nvim_set_keymap to set key mappings.
-- " -- LEADER
-- " -- These keybindings need to be defined before the first /
-- " -- is called; otherwise, it will default to "\"
-- " vim.g.mapleader = ","
-- " vim.g.localleader = "\\"
vim.opt.backup = false
vim.opt.smartindent = true
vim.opt.splitright = true -- open new vsplit window to right of buffer

vim.opt.conceallevel = 0  -- show `` in markdown files

vim.opt.expandtab = true  -- convert tabs to spaces
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.autoindent = true -- auto indent line same amount as previous line
--vim.opt.showbreak = "++"
--vim.opt.textwidth = 0


vim.opt.splitbelow  = true
vim.opt.number      = true
vim.opt.background  = "light"
-- vim.opt.completeopt = ""
vim.opt.wildmode    = { "longest,list" } -- get bash-like tab completions
vim.opt.hlsearch    = true
vim.opt.showmatch   = true
vim.opt.ignorecase  = false -- is case-insensitive regex
vim.opt.mouse       = 'a'
vim.opt.incsearch   = true
vim.opt.number      = true
vim.opt.cc          = '80'  -- set an 80 column border for good coding style
vim.opt.syntax      = 'off' -- syntax highlighting handled by treesitter?
vim.opt.ttyfast     = true  -- faster scrolling in vim
vim.opt.cursorline  = true  -- highlight line containing cursor
vim.opt.spell       = false -- toggle spell check
vim.opt.swapfile    = false -- whether to auto-create swap files in the event of abrupt closure
vim.opt.updatetime  = 3000  -- debounce for events like CursorHold, CursorHoldI vim.diagnostic (higher = less lag)
--vim.opt.backupdir=vim.fn.stdpath("state") .. "/.local/var/cache/nvim/" --dir to store backup files
-- also see vim.fn.stdpath("run") -- undecided what is better
vim.opt.clipboard   = 'unnamedplus' -- uses system clipboard
-- vim.opt.fileencoding -- the current file's encoding set when opening
--vim.opt.t_Co = 256 -- does not work
vim.opt.showtabline = 2    -- see help tabline (shows even if only one tab open

vim.opt.tags        = tags -- name of ctags file


vim.api.nvim_command('filetype plugin indent on') -- or vim.cmd('filetype plugin indent on')
vim.api.nvim_set_hl(0, "WinSeparator", {})
