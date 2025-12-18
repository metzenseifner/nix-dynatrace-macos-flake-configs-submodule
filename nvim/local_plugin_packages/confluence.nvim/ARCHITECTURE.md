# Confluence.nvim Architecture

## Plugin Structure

```
confluence.nvim/
├── lua/confluence/
│   ├── init.lua       # Main plugin interface
│   ├── http.lua       # HTTP client using curl
│   ├── api.lua        # Confluence REST API wrapper
│   └── buffer.lua     # Buffer management & format conversion
├── syntax/
│   └── confluence.vim # Syntax highlighting
├── README.md          # Documentation
├── EXAMPLE.md         # Usage examples
└── ARCHITECTURE.md    # This file
```

## Core Components

### 1. Main Interface (`init.lua`)
- **URL parsing** - Extracts page ID from Confluence URLs
- **Plugin setup** - Configuration and command registration
- **Page cache** - Manages buffer-to-page mappings
- **User commands** - `:ConfluenceOpen`, `:ConfluenceSave`

### 2. HTTP Client (`http.lua`)
- **Authentication** - Basic auth with email + API token
- **Async requests** - Non-blocking curl-based HTTP calls
- **Token supplier** - Configurable secrets provider integration
- **Error handling** - Robust HTTP error management

### 3. API Wrapper (`api.lua`)
- **Page content** - Get/update page content via REST API  
- **Version management** - Automatic version incrementing
- **Page metadata** - Title, space, version information
- **Search functionality** - Optional page search capabilities

### 4. Buffer Management (`buffer.lua`)
- **Format conversion** - HTML ↔ Markdown-like format
- **Buffer creation** - Specialized Confluence buffers
- **Auto-save integration** - `:w` triggers Confluence save
- **Local keymaps** - Buffer-specific shortcuts

## Data Flow

### Opening a Page
```
User: :ConfluenceOpen <URL>
  ↓
init.lua: parse_confluence_url()
  ↓
api.lua: get_page_content()
  ↓
http.lua: GET /rest/api/content/{id}
  ↓
buffer.lua: create_confluence_buffer()
  ↓
Format conversion & buffer display
```

### Saving a Page
```
User: :w
  ↓
BufWriteCmd autocmd
  ↓
init.lua: save()
  ↓
buffer.lua: readable_to_storage()
  ↓
api.lua: update_page_content()
  ↓
http.lua: PUT /rest/api/content/{id}
  ↓
Success notification
```

## Security Model

### External Authentication
- **No secrets in config** - Uses configurable token supplier
- **Gopass integration** - Recommended secret storage
- **Multiple fallbacks** - Environment vars, files, etc.
- **Runtime token fetching** - Fresh tokens for each request

### Token Supplier Examples

**Gopass (Recommended):**
```lua
token_supplier = function()
  local handle = io.popen("gopass show -o dt/confluence/api-token")
  local token = handle:read("*l")
  handle:close()
  return token and token:gsub("%s+", "") or nil
end
```

**Environment Variable:**
```lua
token_supplier = function()
  return os.getenv("CONFLUENCE_API_TOKEN")
end
```

## Format Conversion

### Storage → Readable
- `<p>` tags → plain text with double newlines
- `<strong>` → `**bold**`
- `<em>` → `*italic*`
- `<h1-4>` → `# headings`
- `<li>` → `- list items`

### Readable → Storage
- Reverse conversion for saving
- Preserves Confluence-specific formatting
- Maintains compatibility with Confluence editor

## Error Handling

### Network Errors
- **Timeout handling** - Graceful curl timeout
- **Connection failures** - Clear error messages
- **Rate limiting** - Confluence API respect

### Authentication Errors  
- **Token validation** - Tests token supplier
- **Permission errors** - Clear permission messages
- **Configuration validation** - Setup verification

### Content Errors
- **Version conflicts** - Automatic version management
- **Format errors** - Safe format conversion
- **Buffer errors** - Graceful buffer management

## Performance Considerations

### Caching
- **Page cache** - Buffer-to-page data mapping
- **Token caching** - Avoid repeated token fetching
- **HTTP connection reuse** - Efficient curl usage

### Async Operations
- **Non-blocking requests** - vim.fn.jobstart for HTTP
- **Background loading** - Async page content loading
- **Responsive UI** - No blocking operations

## API Compatibility

### Confluence REST API v1
- **Content endpoints** - `/rest/api/content/`
- **Expansion parameters** - `body.storage`, `version`
- **Version management** - Incremental versioning
- **Authentication** - Basic auth with API tokens

### Supported Operations
- ✅ **GET content** - Retrieve page content
- ✅ **PUT content** - Update page content  
- ✅ **Version tracking** - Automatic versioning
- 🚧 **POST content** - Create new pages (future)
- 🚧 **Search** - Page search functionality (future)

---

*Robust, secure, and efficient Confluence integration for Neovim.*