-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.show_update_window = false

-- TODO add this where necessary
-- if wezterm.target_triple == 'x86_64-apple-darwin' then
--   -- font_dirs    = { '$HOME/.dotfiles/.fonts' }
-- end

require 'font' (config)
require 'color' (wezterm, config)
require 'hyperlinks' (wezterm, config)
require 'bell' (wezterm, config)
require 'keys' (wezterm, config)

-- TODO check whether tmux avail, if so, set it as default program
config.hide_tab_bar_if_only_one_tab = true
config.default_prog = { '/run/current-system/sw/bin/tmux' }
-- config.default_prog = { '/bin/zsh', '-c', 'tmux' } -- when sending tmux to background, leads to unrecoverable state in wezterm
-- config.default_prog = { '/opt/homebrew/bin/wezterm', 'start', '--', '/bin/zsh', '-c', '/opt/homebrew/bin/tmux' } -- when sending tmux to background, leads to unrecoverable state in wezterm

-- macOS specific expansion (like AltGr on other OS); true means: make Option like AltGr
-- When a key combination produces a composed key result, wezterm will look up
-- both the composed and uncomposed versions of the keypress in your key
-- mappings. If either lookup matches your assignment, that will take
-- precedence over the normal key processing.
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true
-- For all actions: https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html
-- For General Format https://wezfurlong.org/wezterm/config/keys.html#voidsymbol
-- In some cases, wezterm may not know how to represent a key event in either
-- its phys: or mapped: forms. In that case, you may wish to define an
-- assignment in terms of the underlying operating system key code, using a
-- raw: prefix.
-- Raw codes are hardware and windowing system dependent, so there is no portable way to list which key does what.
--config.debug_key_events = true -- start wezterm in terminal and use new window
config.keys = { -- ALT, OPT, META - these are all equivalent
  {
    -- Send tilde character directly instead of normal dead-key hold-state composition
    key = 'n',
    mods = 'ALT',
    action = wezterm.action.SendString '~' -- send ~ to terminal when pressing OPT-n
  },
  {
    -- causes issues with tmux using space bar
    -- follow by CTRL-Z leads to WezTerm Update Available that cannot be escaped
    key = 'phys:Space',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.DisableDefaultAssignment,
  }
}
-- Input Method Editor (IME) - An OS-provided service which allows for rich composition of input
-- WezTerm is now able to perform dead-key expansion when use_ime = false
config.use_ime = true

-- Dead Key - a keyboard layout may define these modal keys which don't immediately produce output (and thus appears to be "dead"), but instead holds some state that will compose with a subsequently pressed key.
--set use_dead_keys = false to skip the hold state; continuing the example above, Right-Opt n will then immediately produce ~.
--setting to false seems to disable n key for tilde
config.use_dead_keys = true



config.term = "xterm-256color"
--keys = {
--  -- make ctrl-\ work (or not)
--  { key = "phys:7", mods = "CTRL|ALT|SHIFT", action = "DisableDefaultAssignment" }
--}

config.initial_cols = 140 -- tput cols
config.initial_rows = 41  -- tput lines

return config
