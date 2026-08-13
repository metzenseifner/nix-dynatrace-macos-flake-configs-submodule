local apply = function(wezterm, config)
  config.keys = {
    {
      key = 'C',
      mods = 'CTRL|SHIFT',
      action = wezterm.action_callback(function(window, pane)
        local schemes = wezterm.color.get_builtin_schemes()
        local choices = {}
        for name, _ in pairs(schemes) do
          table.insert(choices, { id = name, label = name })
        end
        table.sort(choices, function(a, b) return a.label < b.label end)

        window:perform_action(
          wezterm.action.InputSelector {
            title = 'Choose color scheme',
            choices = choices,
            fuzzy = true,
            action = wezterm.action_callback(function(inner_window, _pane, id, label)
              if id then
                inner_window:set_config_overrides { color_scheme = label }
              end
            end),
          },
          pane
        )
      end),
    },
  }
end

return apply
