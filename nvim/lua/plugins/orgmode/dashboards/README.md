# Orgmode Dashboards

This directory contains modular dashboard configurations for nvim-orgmode.

## Structure

- **init.lua**: Main module that exports all dashboard functions and handles dynamic team member view generation
- **personal_dashboard.lua**: Personal "things to do" dashboard with daily tasks, sprints, and initiatives
- **development_view.lua**: Individual team member development/growth views (commitments, goals, feedback, etc.)
- **team_development_view.lua**: Aggregated team development dashboard

## Usage

The main orgmode configuration imports this module:

```lua
local dashboards = require('plugins.orgmode.dashboards')
```

### Creating a Personal Dashboard

```lua
local my_dashboard = dashboards.make_dashboard_for("Your Name")()
```

### Creating a Development View

```lua
local dev_view = dashboards.make_personal_development_view_for("Your Name")
```

### Dynamic Team Member Dashboards

Team member views are automatically generated from the `team_members` YAML configuration:

```lua
local team_shortcuts = dashboards.generate_team_member_shortcuts(team_members_str)
```

This dynamically assigns keyboard shortcuts (a-z, skipping reserved keys like 'd', 'g', 's', 'u') to each team member's development view.

## Adding New Dashboards

To add a new dashboard type:

1. Create a new file in this directory (e.g., `my_dashboard.lua`)
2. Export your dashboard function:
   ```lua
   return {
     make_my_dashboard = function(params)
       return {
         description = "My Dashboard",
         types = { ... }
       }
     end
   }
   ```
3. Import and export it in `init.lua`:
   ```lua
   local my_dashboard = require('plugins.orgmode.dashboards.my_dashboard')
   M.make_my_dashboard = my_dashboard.make_my_dashboard
   ```
4. Use it in the main orgmode.lua configuration

## Benefits

- **Modular**: Each dashboard type is in its own file
- **Extensible**: Easy to add new dashboard types
- **Dynamic**: Team member views are generated automatically from configuration
- **Maintainable**: No need to hardcode team member shortcuts
