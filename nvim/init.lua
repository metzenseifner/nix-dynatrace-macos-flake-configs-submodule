-- Neovim Lua Guide https://github.com/nanotee/nvim-lua-guide
vim.g.mapleader = ","
-- Boostrap lazy.nvim as package manager (if not alreay installed)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- ~/.local/share/nvim
if not vim.loop.fs_stat(lazypath) then
  if vim.fn.executable("git") == 1 then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  else
    vim.notify("Git not found! Please install lazy.nvim manually or install git.", vim.log.levels.ERROR)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Ensure lazy is loadable after adding to rtp (needed for NixOS)
if vim.loop.fs_stat(lazypath) then
  package.path = lazypath .. "/lua/?.lua;" .. lazypath .. "/lua/?/init.lua;" .. package.path
end

-- cabbrev turns first arg into the rest args
vim.cmd [[cabbrev help vert bel help]]

--print("Leader is: " .. tostring(vim.api.nvim_get_var(vim.g.mapleader)))

-- nnoremap <leader>dd :Lexplore %:p:h<CR>
-- nnoremap <Leader>da :Lexplore<CR>

--" lua package.path = './lua/config/?.lua;' .. package.path
--" searches every path on runtimepath for a directory called lua and tries to load plugins.lua
require('config/globals')               -- Globally available stuff (global namespace)
require('config/filetype')
require('config/plugin_bootstrapper')   -- Plugins
require('config/options')               -- Options
require('config/keymap')                -- Key Mappings
functions = require('config/functions') -- Functions (namespaces, so does not make sense here)
require('config/custom_module_loader')
require('config/autocmds')
require('config/diagnostic')
require('config/highlight_groups')
require('config/portable')
--"--lua require()
