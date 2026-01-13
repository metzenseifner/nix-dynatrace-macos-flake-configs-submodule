# project_picker.nvim

A Neovim plugin for managing and switching between projects organized by source.

## Features

- Organize projects by source namespaces
- Wildcard source expansion: automatically create sources from directory structure
- Telescope integration for fuzzy finding projects
- Customizable project selection behavior

## Configuration

### Basic Usage

```lua
require("project_picker").setup({
  sources = {
    dynamic_projects = {
      roots = { "/path/to/projects/*" },
    },
  },
})
```

### Wildcard Source Expansion

Use a wildcard path pattern where each directory becomes a source namespace:

```lua
require("project_picker").setup({
  sources = {
    -- Each directory in /path/to/sources becomes a source
    -- Each subdirectory within becomes a project root
    ["/path/to/sources/*"] = "/path/to/sources/*",
  },
})
```

For example, with this structure:
```
/path/to/sources/
├── team_a/
│   ├── project1/
│   └── project2/
└── team_b/
    ├── project3/
    └── project4/
```

You'll get sources named `team_a` and `team_b`, each containing their respective projects.

### Custom Selection Handler

```lua
require("project_picker").setup({
  sources = { ... },
  on_select = function(path)
    vim.cmd('cd ' .. vim.fn.fnameescape(path))
    require('telescope.builtin').find_files({ cwd = path })
  end
})
```

## Commands

- `:ProjectPickerProjects` - Show all projects from all sources
- `:ProjectPickerSources` - Show available sources
- `:ProjectPickerFromSource <source>` - Show projects from a specific source

## Telescope Extensions

```lua
:Telescope project_picker projects
:Telescope project_picker sources
:Telescope project_picker source name=<source>
```
