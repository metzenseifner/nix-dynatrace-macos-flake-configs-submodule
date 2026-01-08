-- The way this works: setup translates string "plugins" into a lua module name and tries to load it.
-- This module must return a table that conforms to the PluginSpec interface.
-- any file under the module plugins will be merged into the main plugin spec.
--
-- The benefits of using this approach:
-- 
-- Simple to add new plugin specs. Just create a new file in your plugins module.
-- Allows for caching of all your plugin specs. This becomes important if you have a lot of smaller plugin specs.
-- Spec changes will automatically be reloaded when they're updated, so the :Lazy UI is always up to date.
-- Equivalent:  =require("lazy").setup({{import = "plugins"}})

-- Configure lazy.nvim with portable defaults
-- Disable luarocks/hererocks globally for portability across distributions
return require('lazy').setup('plugins', {
  rocks = {
    enabled = true,
    hererocks = false,
  },
}) -- load plugins module
