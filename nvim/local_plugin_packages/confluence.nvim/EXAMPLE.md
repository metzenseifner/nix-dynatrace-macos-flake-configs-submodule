# Confluence.nvim Usage Example

## Quick Start

1. **Configure the plugin** in your `lua/plugins/confluence.lua`
2. **Open a Confluence page** with `:ConfluenceOpen <URL>`
3. **Edit like a normal file** with Neovim's full power
4. **Save with `:w`** to push changes back to Confluence

## Example Session

```vim
" Open a Confluence page
:ConfluenceOpen https://dt-rnd.atlassian.net/wiki/spaces/~712020a30e03943f474896bf2d9bf8a1a2b23a/pages/691273899/TC+Handover

" Edit the content normally
" The HTML content is converted to a readable format:
" <p>Hello <strong>world</strong></p>  becomes:  Hello **world**

" Save changes back to Confluence
:w

" Or use the explicit command
:ConfluenceSave

" Reload latest version from Confluence (if someone else edited it)
:e!

" Or use the explicit command  
:ConfluenceReload

" Close the buffer
<leader>cq
```

## URL Format

The plugin supports standard Confluence URLs:
```
https://domain.atlassian.net/wiki/spaces/SPACE_KEY/pages/PAGE_ID/Page+Title
```

Example:
```
https://dt-rnd.atlassian.net/wiki/spaces/~712020a30e03943f474896bf2d9bf8a1a2b23a/pages/691273899/TC+Handover
```

## Gopass Integration

Store your Confluence API token securely:

```bash
# Store your token in gopass
gopass insert dt/confluence/api-token

# The plugin will retrieve it automatically
```

## Format Conversion Examples

**Confluence Storage → Editable Format:**

| Confluence HTML | Editable Format |
|-----------------|-----------------|
| `<h1>Title</h1>` | `# Title` |
| `<p>Paragraph</p>` | `Paragraph` |
| `<strong>Bold</strong>` | `**Bold**` |
| `<em>Italic</em>` | `*Italic*` |
| `<code>code</code>` | `` `code` `` |
| `<li>Item</li>` | `- Item` |

## Keymaps

**Global keymaps (configured in your plugin config):**
- `<leader>co` - Open Confluence page (prompts for URL)

**Buffer-local keymaps (only in Confluence buffers):**
- `<leader>cs` - Save page to Confluence
- `<leader>cr` - Reload page from server  
- `<leader>cq` - Close Confluence buffer

## Advanced Configuration

```lua
require('confluence').setup({
  base_url = "https://dt-rnd.atlassian.net",
  auth = {
    email = "your.email@company.com",
    token_supplier = function()
      -- Multiple fallback sources
      local token = os.getenv("CONFLUENCE_TOKEN")
      if token then return token end
      
      -- Try gopass
      local handle = io.popen("gopass show -o dt/confluence/api-token")
      if handle then
        local result = handle:read("*l")
        handle:close()
        return result and result:gsub("%s+", "") or nil
      end
      
      error("No Confluence token found")
    end,
  },
  buffer_options = {
    filetype = "confluence",
    wrap = true,
    spell = true,
  }
})
```

## Troubleshooting

### Check Configuration
```vim
:ConfluenceSetup
```

### Test Token Supplier
```lua
:lua print(require('confluence').config.auth.token_supplier())
```

### Debug URL Parsing
```lua
:lua local conf = require('confluence'); local info = conf._parse_url("your-url-here"); print(vim.inspect(info))
```

---

*Happy Confluence editing!*