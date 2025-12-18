-- TODO consider making this only load for certain file types / LSP servers
return {
  "onsails/diaglist.nvim",
  opts = {
    -- optional settings
    -- below are defaults
    debug = false,

    -- increase for noisy servers
    debounce_ms = 150,
  },
  config = function(mod, opts)
    require "diaglist".init(opts)
  end
}
