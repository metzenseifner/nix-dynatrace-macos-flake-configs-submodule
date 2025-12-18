local wezterm = require 'wezterm'

local apply = function(config)
  -- Use following command to discover settings of font. StyleRules differ (intensity for bold in match rule vs weight for bold in font)
  -- wezterm ls-fonts --list-system
  config.font = wezterm.font('Hack Nerd Font', {}) -- also see https://monaspace.githubnext.com
  config.font_size = 15.0
  config.line_height = 1.4
  config.font_rules = {
    -- https://wezfurlong.org/wezterm/config/lua/config/font_rules.html
    -- Use to decide how to render that text.
    -- Bold
    {
      intensity = 'Bold',
      italic = false,
      font = wezterm.font('Hack Nerd Font', { weight = "Bold", stretch = "Normal", style = "Normal" })
    },
    -- Bold and Italic
    {
      intensity = "Bold",
      italic = true,
      font = wezterm.font('Hack Nerd Font', { weight = "Bold", stretch = "Normal", style = "Italic" })
    },
    -- normal-intensity-and-italic
    {
      intensity = "Normal",
      italic = true,
      font = wezterm.font('Hack Nerd Font', { weight = "Regular", style = "Italic" })
    },
    -- Italic
    {
      intensity = "Half",
      italic = true,
      font = wezterm.font('Hack Nerd Font', { weight = "Regular", style = "Italic" })
    }
  }
end

return apply
