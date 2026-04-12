-- Dynamic window sizing and font scaling based on screen geometry.
--
-- On gui-attached: queries the active screen's pixel dimensions and DPI,
-- computes an appropriate font size (linearly scaled from a 144-DPI
-- reference), then resizes the window to ~85% of the screen, centered.

local apply = function(wezterm, config)
  local resized = false

  wezterm.on('window-config-reloaded', function(window, pane)
    if resized then
      return
    end
    resized = true

    local screens = wezterm.gui.screens()
    local active = screens.active

    -- Reference: 15 pt looked right on a Retina MacBook (144 effective DPI).
    local ref_dpi = 144
    local ref_font_size = 15.0

    local dpi = active.effective_dpi or 96
    local font_size = ref_font_size * (dpi / ref_dpi)

    -- Clamp to a sensible range
    font_size = math.max(9.0, math.min(font_size, 18.0))

    -- Size the window to ~85% of the screen, centered
    local width  = math.floor(active.width * 0.85)
    local height = math.floor(active.height * 0.85)
    local x = active.x + math.floor((active.width  - width)  / 2)
    local y = active.y + math.floor((active.height - height) / 2)

    window:set_inner_size(width, height)
    window:set_position(x, y)
    window:set_config_overrides({ font_size = font_size })
  end)
end

return apply
