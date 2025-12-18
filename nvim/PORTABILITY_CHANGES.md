# Neovim Config Portability Improvements

This document summarizes the changes made to improve the portability of your Neovim configuration.

## Overview

The configuration has been updated to gracefully handle missing external dependencies and provide fallback behavior when tools are not available on the system.

## Key Changes Made

### 1. Enhanced Portable Module (`lua/config/portable.lua`)

- Added `safe_jobstart()` function to safely execute vim.fn.jobstart with executable checks
- Added `safe_date_cmd()` function for cross-platform date command execution
- Enhanced error handling with `notify_once()` to prevent spam notifications

### 2. Removed Mapper Dependency (`lua/config/keymap/init.lua`)

- **REMOVED**: External Mapper package dependency
- **REPLACED**: All `Mapper.map()` calls with `portable.safe_keymap()` directly
- This eliminates the error you encountered on Linux about missing Mapper package

### 3. Bootstrap Protection (`init.lua`)

- Added check for `git` executable before attempting to clone lazy.nvim
- Provides clear error message if git is missing

### 4. Cross-Platform Date Utilities (`lua/date_utils.lua`)

- Added fallback mechanisms for date commands
- Supports both Unix/Linux/macOS `date` and Windows PowerShell `Get-Date`
- Falls back to Lua's `os.date()` if external commands fail

### 5. Safe File Browser (`lua/config/keymap/open_in_file_browser.lua`)

- Added executable checks before attempting to use system file browsers
- Provides user-friendly warnings if tools are missing

### 6. Protected External Tool Calls

Updated all external tool invocations in:
- `lua/config/autocmds.lua` - Safe jobstart for AutoRun commands
- `lua/config/globals.lua` - Safe jobstart for system commands
- Local plugins (yaml-to-json, testrunner, etc.)

### 7. Snippet Portability Improvements

Updated snippets to handle missing external tools gracefully:
- `snippets/all/utils.lua` - Safe timestamp generation
- `snippets/all/generated_date_snippets.lua` - Fallback date handling
- `snippets/all/dynatrace-*.lua` - Safe external tool execution
- `snippets/org/team_members.lua` - Safe yaml-supplier calls

**FIXED**: Added missing LuaSnip imports to snippet files:
- `snippets/all/dynatrace-links-yaml.lua` - Added luasnip imports and fixed syntax error
- `snippets/all/dynatrace-team-care.lua` - Added luasnip imports and fixed multiline string issues
- `snippets/all/dynatrace-team-platinum.lua` - Added luasnip imports

**FIXED**: Resolved LuaSnip multiline string formatting issues:
- Fixed function nodes returning malformed multiline strings in `dynatrace-team-care.lua`
- **Proper solution**: Use `[[ ]]` multiline literals with `vim.split(multiline, '\n')` to convert to table
- LuaSnip function nodes require multiline content as table of strings, not single string with `\n`
- This resolves errors like: `[LuaSnip Failed]: { "        CLOSED: [2025-10-29 Wed]\n      " }`

**Working pattern for multiline strings in LuaSnip function nodes:**
```lua
f(function(values)
  local multiline = string.format([[      :PROPERTIES:
      :OPENED: [%s]
      :TYPE: Team Captain
      :BY: Jonathan Komar
      :END:]], require('date_utils').timestamp_orgmode())
  return vim.split(multiline, '\n')  -- Convert to table of strings
end, {})
```

### 8. Local Plugin Updates

Enhanced local plugins for better portability:
- `yaml-to-json.nvim` - Added yq executable checks
- `testrunner.nvim` - Added safe jobstart wrapper
- `run_external_executable.nvim` - Added executable validation
- `telescope-custom-file-list.nvim` - Added ls command fallback

## Testing the Changes

### Quick Validation
```bash
# Test portable module loads correctly
nvim --headless -c "lua require('config.portable')" -c "quit"

# Test with missing tools (should show warnings, not errors)
nvim --headless -c "lua require('config.portable').safe_system('nonexistent-tool --version', 'test')" -c "quit"
```

### Expected Behavior

**Before Changes:**
- Config would fail to load on systems missing certain tools
- Error about missing Mapper package
- Hard crashes when external tools weren't available

**After Changes:**
- Config loads successfully on any system
- Missing tools generate warnings (not errors)
- Graceful fallbacks when external dependencies are unavailable
- No more Mapper dependency errors

### 9. YAML-Based Team Configuration (NEW)

**ADDED**: Dynamic team member loading from YAML configuration:
- `snippets/all/dynatrace-team-care.lua` now reads from `~/.config/yaml-supplier/team_care.yml`
- **No sensitive team data hardcoded** - all external for security
- **Empty fallback** if YAML loading fails (no hardcoded team info)
- **Easy team updates** - just edit the YAML file
- **Multi-source sprint detection** (sprint_supplier → YAML → fallback)

**Benefits:**
- Team changes only require YAML file updates
- Preserves all existing snippet functionality when YAML available
- Secure empty fallback - no sensitive data in nvim config
- Cross-platform compatible (uses `yq` + portable module)

See `YAML_TEAM_CONFIG.md` for detailed usage guide.

## External Tools That Are Now Optional

The following tools will be checked but are no longer required:
- `git` (for lazy.nvim bootstrap)
- `date` (Unix date command)
- `yq` (YAML processor)
- `sprint_supplier`, `yaml-supplier` (custom tools)
- `gopass` (password manager, used in snippets)
- File managers: `xdg-open`, `gio`, `open`
- `ls`, `grep` (Unix utilities)

## Recommendations

1. **Keep using tools where available** - The config will use external tools when present for better functionality
2. **Install commonly used tools** - Consider installing `git`, `yq`, and platform-specific file managers for full functionality
3. **Monitor warnings** - Use `:messages` in Neovim to see which tools are missing if you want full functionality

## Rollback Instructions

If you need to rollback these changes:
1. The original files are backed up with `.bak` extensions where modified
2. Restore from git if needed: `git checkout HEAD -- <filename>`
3. The changes are primarily additive (pcall wrappers) so they shouldn't break existing functionality

---

Your Neovim config should now work on any machine with Neovim installed, regardless of what external tools are available!