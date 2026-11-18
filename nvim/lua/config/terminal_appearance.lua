-- What the surrounding terminal's background looks like, and how to keep
-- 'background' in agreement with it.
--
--   Mode     = "light" | "dark"
--   Detector = () -> Mode?            -- PARTIAL: nil means "no opinion"
--   detect   = first non-nil answer over an ordered list of detectors,
--              else the fallback
--
-- In plain English: ask each source in turn, take the first one that actually
-- knows, and fall back to Neovim's own default when none of them do. The
-- ordering is the whole design -- see M.order.

local M = {}

-- Neovim's built-in default for 'background'. Also the answer when every
-- detector abstains (a dumb terminal over a serial line, say).
M.fallback = "dark"

-- The last mode this module applied. Needed to tell our own write to
-- 'background' apart from one the TUI made, which is a real signal.
M.last_applied = nil

-- 'background' as it stood before anything in this config touched it. If the
-- TUI's OSC 11 reply had already landed by then, this is ground truth; if it
-- had not, this is just the default. Only "light" distinguishes the two cases,
-- which is why M.detectors.startup_background never claims "dark".
local background_at_load = vim.o.background

---------------------------------------------------------------------------
-- Luminance
---------------------------------------------------------------------------

-- WCAG relative-luminance crossover: above this, black text beats white on
-- the given background. That is the same question 'background' answers.
local light_threshold = 0.179

local function srgb_to_linear(channel)
  if channel <= 0.04045 then
    return channel / 12.92
  end
  return ((channel + 0.055) / 1.055) ^ 2.4
end

-- hex "#rrggbb" -> Mode?   (nil when the string is not a colour)
local function mode_of_hex(hex)
  local r, g, b = tostring(hex):match("^#?(%x%x)(%x%x)(%x%x)$")
  if not r then
    return nil
  end
  local luminance =
      0.2126 * srgb_to_linear(tonumber(r, 16) / 255)
      + 0.7152 * srgb_to_linear(tonumber(g, 16) / 255)
      + 0.0722 * srgb_to_linear(tonumber(b, 16) / 255)
  return luminance > light_threshold and "light" or "dark"
end

M.mode_of_hex = mode_of_hex

---------------------------------------------------------------------------
-- Detectors
---------------------------------------------------------------------------

M.detectors = {}

-- The terminal itself, by way of the TUI. Neovim sets 'background' from an
-- OSC 11 reply (:help 'background'), and that reply is asynchronous: it can
-- land after we already wrote our own best guess. When it does, the option no
-- longer holds what we put there, and that mismatch IS the terminal
-- overruling us -- the most direct evidence available, so it ranks first.
-- Self-clearing: once the new value is adopted, the two agree and this falls
-- silent again. This covers the window OptionSet cannot, because OptionSet
-- does not fire during startup (:help OptionSet).
M.detectors.tui_background = function()
  if M.last_applied and vim.o.background ~= M.last_applied then
    return vim.o.background
  end
  return nil
end

-- The macOS system appearance, which is the same value wezterm's own config
-- reads through wezterm.gui.get_appearance() (see configs/wezterm/color).
-- Because both sides read one source, they cannot drift. Unlike an
-- environment variable, it is never stale.
M.detectors.macos_appearance = function()
  if vim.uv.os_uname().sysname ~= "Darwin" then
    return nil
  end
  if vim.fn.executable("defaults") ~= 1 then
    return nil
  end
  -- Bounded wait: a wedged `defaults` must not hang startup.
  local result = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }):wait(500)
  if result.code == 0 then
    return (result.stdout or ""):find("Dark") and "dark" or "light"
  end
  -- Light mode does not store the key at all, so that specific failure IS the
  -- answer. Any other failure means we learned nothing.
  if (result.stderr or ""):find("does not exist") then
    return "light"
  end
  return nil
end

-- The terminal background colour wezterm exports into each pane's environment.
-- Survives tmux and ssh, where `defaults` is absent, but it is frozen at pane
-- spawn: flip the system theme and every already-running shell keeps the old
-- value. Hence it ranks below the system appearance.
M.detectors.wezterm_background = function()
  local hex = vim.env.WEZTERM_BACKGROUND_COLOR
  if not hex or hex == "" then
    return nil
  end
  return mode_of_hex(hex)
end

-- COLORFGBG, the old rxvt convention some terminals and multiplexers still
-- set, as "<fg>;<bg>" ANSI indices. Index 0 and 8 are the dark ends.
M.detectors.colorfgbg = function()
  local bg = tostring(vim.env.COLORFGBG or ""):match(";(%d+)$")
  if not bg then
    return nil
  end
  bg = tonumber(bg)
  if bg == 0 or bg == 8 then
    return "dark"
  end
  if bg == 7 or bg == 15 then
    return "light"
  end
  return nil
end

-- See background_at_load above: the TUI's OSC 11 answer, when it arrived early
-- enough to be visible at require time.
M.detectors.startup_background = function()
  if background_at_load == "light" then
    return "light"
  end
  return nil
end

---------------------------------------------------------------------------
-- Resolution
---------------------------------------------------------------------------

-- Freshest and most authoritative first. Each later entry covers a host the
-- earlier ones cannot see: wezterm's variable reaches inside tmux and ssh,
-- COLORFGBG covers other terminals, and the startup snapshot is the only one
-- that works on a bare NixOS console with an OSC 11-capable terminal.
M.order = {
  "tui_background",
  "macos_appearance",
  "wezterm_background",
  "colorfgbg",
  "startup_background",
}

-- detect : [DetectorName]? -> (Mode, DetectorName?)
-- The second return value names the detector that answered, nil for fallback.
M.detect = function(order)
  for _, name in ipairs(order or M.order) do
    local detector = M.detectors[name]
    local mode = detector and detector()
    if mode then
      return mode, name
    end
  end
  return M.fallback, nil
end

-- adopt : () -> (Mode, DetectorName?)
-- Resolve, write the answer to 'background', and record it. The record is what
-- lets tui_background tell a later disagreement apart from our own write, so
-- callers that set 'background' from a detection should go through here rather
-- than assigning the option directly.
M.adopt = function()
  local mode, source = M.detect()
  M.last_applied = mode
  vim.opt.background = mode
  return mode, source
end

-- A one-line account of the current reading, for a user command or :messages.
M.describe = function()
  local mode, source = M.detect()
  return ("terminal appearance: %s (via %s)"):format(mode, source or "fallback")
end

---------------------------------------------------------------------------
-- Keeping up with changes
---------------------------------------------------------------------------

-- Nothing pushes an appearance change at us: Neovim implements no OSC 2031
-- theme-change notification, so there is no event to subscribe to. We pull
-- instead, on the occasions that mean "you may have been away while it
-- changed", and we accept the TUI's own late OSC 11 reply when it lands.
--
-- on_change : (Mode -> ()) -> ()
-- The callback fires only on an actual change. The caller owns the initial
-- apply, so the current mode is recorded here without invoking it.
M.on_change = function(callback)
  local applying = false

  local apply = function(mode)
    if mode == M.last_applied then
      return
    end
    M.last_applied = mode
    applying = true
    local ok, err = pcall(callback, mode)
    applying = false
    if not ok then
      vim.notify("terminal_appearance: " .. tostring(err), vim.log.levels.WARN)
    end
  end

  M.sync = function()
    apply((M.detect()))
  end

  local group = vim.api.nvim_create_augroup("TerminalAppearance", { clear = true })

  -- FocusGained needs `set -g focus-events on` in tmux to ever fire.
  vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
    group = group,
    desc = "Re-detect terminal light/dark appearance",
    callback = function()
      M.sync()
    end,
  })

  -- A late OSC 11 reply shows up as the TUI setting 'background' out from
  -- under us. That is ground truth, so take it at face value rather than
  -- re-resolving -- re-resolving would let a lower-ranked detector overrule
  -- the terminal itself. The guard keeps our own write from looping back.
  vim.api.nvim_create_autocmd("OptionSet", {
    group = group,
    pattern = "background",
    desc = "Follow the terminal's own OSC 11 background report",
    callback = function()
      if applying then
        return
      end
      apply(vim.v.option_new)
    end,
  })
end

-- Fallback until on_change installs the real one, so callers can always
-- :lua require('config.terminal_appearance').sync() without a nil check.
M.sync = function() end

return M
