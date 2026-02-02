---Type definitions from orgmode.nvim
---See: https://github.com/nvim-orgmode/orgmode/blob/master/lua/orgmode/config/_meta.lua
---
---Import orgmode types by requiring the config module.
---This ensures LSP recognizes these types:
--- - OrgAgendaCustomCommand (complete command structure)
--- - OrgAgendaCustomCommandAgenda (agenda type view)
--- - OrgAgendaCustomCommandTags (tags type view)
--- - OrgAgendaCustomCommandTypeInterface (base interface)
---
---Usage in your code:
---   ---@return OrgAgendaCustomCommand
---   function my_dashboard() ... end

-- Import orgmode config to make types available to LSP
---@module 'orgmode.config'

return {}
