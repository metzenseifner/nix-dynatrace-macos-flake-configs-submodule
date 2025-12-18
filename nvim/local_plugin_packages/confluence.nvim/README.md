# Confluence.nvim

Edit Confluence pages directly in Neovim with transparent API integration.

## Features

✅ **Subcommand API** - `:Confluence open`, `:Confluence save`, etc.  
✅ **Multiple formats** - Confluence HTML or org-mode via pandoc  
✅ **Direct URL opening** - Paste any Confluence page URL  
✅ **Transparent editing** - Edit pages as if they were local files  
✅ **Auto-save integration** - `:w` saves directly to Confluence  
✅ **External auth** - Uses configurable secrets provider (e.g., gopass)  
✅ **Format conversion** - HTML ↔ org-mode with pandoc  
✅ **Version management** - Automatic version incrementation  

## Installation

Add to your lazy.nvim configuration:

```lua
{
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/confluence.nvim",
  config = function()
    require('confluence').setup({
      base_url = "https://dt-rnd.atlassian.net",
      auth = {
        email = "your.email@company.com",
        token_supplier = function()
          -- Use gopass to get Confluence API token
          local handle = io.popen("gopass show -o confluence/api-token")
          if not handle then
            error("Failed to execute gopass command")
          end
          local token = handle:read("*l")
          handle:close()
          return token and token:gsub("%s+", "") or nil
        end,
      },
      buffer_options = {
        filetype = "confluence",  -- Default filetype
        wrap = true,             -- Enable line wrapping
        spell = true,            -- Enable spell checking
      },
      pandoc = {
        enabled = true,          -- Enable pandoc conversions
        executable = "pandoc",   -- Pandoc executable path
      }
    })
    })
  end
}
```

## Usage

### Opening Pages

**Confluence Format (default):**
```vim
:Confluence open https://dt-rnd.atlassian.net/wiki/spaces/~712020a30e03943f474896bf2d9bf8a1a2b23a/pages/691273899/TC+Handover
```

**Org-mode Format (with pandoc):**
```vim
:Confluence open --as=orgmode https://dt-rnd.atlassian.net/wiki/spaces/~712020a30e03943f474896bf2d9bf8a1a2b23a/pages/691273899/TC+Handover
```

### Managing Pages

```vim
:Confluence save           " Save current page
:Confluence reload         " Reload from server
:Confluence setup          " Show configuration
```

### Saving Changes

```vim
:w                    " Auto-saves to Confluence
:ConfluenceSave      " Explicit save command
<leader>cs           " Buffer-local keymap
```

### Reloading from Server

```vim
:e!                  " Reload latest version from server
:ConfluenceReload    " Explicit reload command  
<leader>cr           " Buffer-local keymap
```

## Buffer Management

The plugin creates specialized buffers for Confluence pages with:

✅ **Buffer-specific autocmds** - Only Confluence buffers intercept `:w`  
✅ **Normal file saving preserved** - Regular files save normally  
✅ **Custom filetype** - `confluence` filetype with syntax highlighting  
✅ **Auto-conversion** - HTML ↔ readable format  

### Buffer-local Keymaps
- `<leader>cs` - Save to Confluence
- `<leader>cr` - Reload from server
- `<leader>cq` - Close buffer

### Write/Read Behavior
- **Confluence buffers**: `:w` saves to Confluence API, `:e!` reloads from server
- **Normal files**: `:w` and `:e!` work as expected (not affected)

## Authentication

The plugin uses a configurable **token supplier** function for authentication. This keeps secrets outside your Neovim config.

### Gopass Example (Recommended)

```lua
token_supplier = function()
  local handle = io.popen("gopass show -o confluence/api-token")
  local token = handle:read("*l")
  handle:close()
  return token and token:gsub("%s+", "") or nil
end
```

### Environment Variable Example

```lua
token_supplier = function()
  return os.getenv("CONFLUENCE_API_TOKEN")
end
```

### File-based Example

```lua
token_supplier = function()
  local file = io.open(os.getenv("HOME") .. "/.confluence-token", "r")
  if not file then return nil end
  local token = file:read("*l")
  file:close()
  return token
end
```

## Format Conversion

The plugin automatically converts between Confluence's storage format (HTML) and a more readable format:

**Confluence HTML** → **Editable Format**
- `<p>text</p>` → `text`
- `<strong>bold</strong>` → `**bold**`
- `<em>italic</em>` → `*italic*`
- `<h1>heading</h1>` → `# heading`
- `<li>item</li>` → `- item`

## Commands

- `:Confluence open <URL>` - Open page in default format
- `:Confluence open --as=orgmode <URL>` - Open page as org-mode
- `:Confluence save` - Save current page to Confluence
- `:Confluence reload` - Reload current page from server
- `:Confluence setup` - Show current configuration

## Format Support

### Confluence Format (Default)
- **Filetype**: `confluence`
- **Conversion**: HTML ↔ readable text
- **Best for**: Quick edits, simple formatting

### Org-mode Format (Pandoc Required)
- **Filetype**: `org`
- **Conversion**: HTML ↔ org-mode via pandoc
- **Best for**: Complex documents, structured content
- **Requirements**: `pandoc` executable, `pandoc.enabled = true`

## Configuration

```lua
require('confluence').setup({
  base_url = "https://your-domain.atlassian.net",  -- Required
  auth = {
    email = "your.email@company.com",              -- Required
    token_supplier = function()                     -- Required
      -- Return your API token
      return "your-api-token"
    end,
  },
  buffer_options = {
    filetype = "confluence",   -- Filetype for syntax highlighting
    wrap = true,              -- Enable line wrapping
    spell = true,             -- Enable spell checking
  },
  retry = {
    max_attempts = 5,         -- Maximum retry attempts (default: 5)
    backoff_type = "exponential", -- "exponential" or "logarithmic" (default: "exponential")
    initial_delay_ms = 1000,  -- Initial delay in milliseconds (default: 1000)
    max_delay_ms = 30000,     -- Maximum delay between retries (default: 30000)
  }
})
```

### Retry Configuration

The plugin includes automatic retry logic with configurable backoff for improved stability:

- **`max_attempts`**: Number of times to retry failed requests (default: 5)
- **`backoff_type`**: Strategy for delay calculation
  - `"exponential"`: Delay doubles each attempt (1s, 2s, 4s, 8s, 16s...)
  - `"logarithmic"`: Delay increases logarithmically (slower growth)
- **`initial_delay_ms`**: Starting delay in milliseconds (default: 1000ms)
- **`max_delay_ms`**: Maximum delay cap (default: 30000ms)

**Retryable conditions:**
- Network timeouts and connection errors
- HTTP 5xx server errors
- Transient failures

This makes `:w` operations more reliable when dealing with network instability or server-side issues.

## API Token Setup

1. Go to Atlassian Account Settings
2. Navigate to Security → API tokens
3. Create new token
4. Store securely (gopass, environment variable, etc.)

## Troubleshooting

### Check Configuration
```vim
:ConfluenceSetup
```

### Debug Authentication
```lua
-- Test your token supplier
print(require('confluence').config.auth.token_supplier())
```

### Common Issues

- **Invalid URL format**: Ensure URL matches pattern with `/wiki/spaces/.../pages/ID/title`
- **Authentication failed**: Verify email and API token
- **Permission denied**: Check Confluence page permissions

---

*Edit Confluence pages like local files, with the power of Neovim.*