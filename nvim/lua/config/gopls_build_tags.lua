-- Auto-configure gopls with build tags when opening Go files
local M = {}

local function update_gopls_build_tags()
  local go_tags = require("utils.go_build_tags")
  local tags = go_tags.get_tags_from_buffer()
  
  if #tags == 0 then
    return
  end
  
  -- Find gopls client
  local clients = vim.lsp.get_clients({ bufnr = 0, name = "gopls" })
  if #clients == 0 then
    return
  end
  
  local client = clients[1]
  local build_flags = go_tags.format_build_flags(tags)
  
  -- Update settings
  if not client.config.settings then
    client.config.settings = {}
  end
  if not client.config.settings.gopls then
    client.config.settings.gopls = {}
  end
  
  client.config.settings.gopls.buildFlags = build_flags
  
  -- Notify gopls of configuration change
  client.notify("workspace/didChangeConfiguration", {
    settings = client.config.settings
  })
  
  vim.notify(string.format("Updated gopls with build tags: %s", table.concat(tags, ", ")), vim.log.levels.INFO)
end

function M.setup()
  -- Create autocmd to update gopls when opening Go files with build tags
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("GoplsBuildTags", { clear = true }),
    pattern = "*.go",
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "gopls" then
        -- Defer to give buffer time to load
        vim.defer_fn(update_gopls_build_tags, 100)
      end
    end,
  })
end

return M
