-- golangci-lint v2 diagnostics via none-ls
-- Uses the golangci-lint from nix flake environment

local null_ls = require("null-ls")

-- Find golangci-lint in PATH, preferring nix store version
local function find_golangci_lint()
  local path_entries = vim.split(vim.env.PATH, ":", { plain = true })
  
  -- First, look for nix store version (v2.x)
  for _, path_entry in ipairs(path_entries) do
    if path_entry:match("/nix/store/.*golangci%-lint") then
      local candidate = path_entry .. "/golangci-lint"
      if vim.fn.executable(candidate) == 1 then
        return candidate
      end
    end
  end
  
  -- Fallback to default PATH search
  return "golangci-lint"
end

return null_ls.builtins.diagnostics.golangci_lint.with({
  command = find_golangci_lint(),
  -- golangci-lint will automatically find .golangci.yaml in the project root
  -- The builtin now supports v2 since PR #265
})
