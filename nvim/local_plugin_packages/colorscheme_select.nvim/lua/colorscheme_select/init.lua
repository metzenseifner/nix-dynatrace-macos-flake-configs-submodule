local M = {}

local default_conf = {
  startup_mode = "light", -- or "dark"
  dark_schemes = {
    "duskfox",
    "mirage",
    "ayu-mirage"
  },
  light_schemes = {
    "ayu-light",
    "PaperColor",
    "dawnfox",
    "dayfox",
  }
}

M.conf = {}
M.runtime_state = {}

M.setup = function(opts)
  opts = opts or {}
  M.conf = vim.tbl_deep_extend("force", {}, default_conf, opts) -- force means right takes precedence (right overrides left)

  M.runtime_state = {
    mode = M.conf.startup_mode or "light",
    marked_light_idx = 1,
    marked_dark_idx = 1
  }
  if (M.conf.startup_mode) then
    if (M.conf.startup_mode == "light") then
      require 'colorscheme_select'.set_light(M.conf.light_schemes[M.runtime_state.marked_light_idx], M.runtime_state)
    elseif (M.conf.startup_mode == "dark") then
      require 'colorscheme_select'.set_dark(M.conf.dark_schemes[M.runtime_state.marked_dark_idx], M.runtime_state)
    else
      print("Unsupported startup_mode: ", M.conf.startup_mode)
      print("Supported sctartup_schemes: light | dark")
    end
  end

  -- Prototype function
  vim.api.nvim_create_user_command("ColorschemeSelect", function(cmd_opt)
      -- Implement using telescope.nvim picker
      -- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md
    end,
    { desc = "Select color scheme from curated set of schemes.", nargs = "*" })


  vim.api.nvim_create_user_command("Colorschemeselectlight", function(cmd_opts)
    local cs = require 'colorscheme_select'
    cs.set_light(cs.conf.light_schemes[cs.runtime_state.marked_light_idx], cs.runtime_state)
  end, {
    desc = "Sets colorscheme to light variant.",
    nargs = "*",
  })

  vim.api.nvim_create_user_command("Colorschemeselectdark", function(cmd_opts)
    local cs = require 'colorscheme_select'
    cs.set_dark(cs.conf.dark_schemes[cs.runtime_state.marked_dark_idx], cs.runtime_state)
  end, {

    desc = "Sets colorscheme to dark variant.",
    nargs = "*",
  })

  vim.api.nvim_create_user_command("Colorschemeselecttoggle", function(cmd_opts)
    local cs = require 'colorscheme_select'
    cs.toggle(cs.runtime_state, cs.conf)
  end, {
    desc = "Toggle colorscheme to between last-selected light or dark variant.",
    nargs = "*",
  })

  M.colorschemestate = "light"
end

M.set_light = function(scheme, runtime_state)
  --print("Setting light colorscheme: ", scheme)
  vim.opt.background = "light"
  runtime_state.mode = "light"
  vim.cmd("colorscheme " .. scheme)
end

M.set_dark = function(scheme, runtime_state)
  --print("Setting dark colorscheme: ", scheme)
  vim.opt.background = "dark"
  runtime_state.mode = "dark"
  vim.cmd("colorscheme " .. scheme)
end

M.toggle = function(runtime_state, conf)
  local r_runtime_state = runtime_state or require 'colorscheme_select'.runtime_state
  local r_conf = conf or require 'colorscheme_select'.conf
  if (r_runtime_state.mode == "light") then
    M.set_dark(r_conf.dark_schemes[r_runtime_state.marked_dark_idx], r_runtime_state)
  elseif (r_runtime_state.mode == "dark") then
    M.set_light(r_conf.light_schemes[r_runtime_state.marked_light_idx], r_runtime_state)
  else
    print("Unsupported mode detected. Cannot toggle colorscheme.")
  end
end

return M
