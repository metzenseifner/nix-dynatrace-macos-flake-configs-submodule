local function show_yaml_schemas()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "yamlls" })
  local client = clients and clients[1]
  if not client then
    vim.notify("yamlls is not attached to this buffer")
    return
  end

  local uri = vim.uri_from_bufnr(bufnr)
  client.request('yaml/get/all/jsonSchemas', { uri = uri }, function(err, result)
    if err or not result then
      vim.notify("No schema info available")
      return
    end
    local lines = {}
    for _, s in ipairs(result) do
      local name = s.name or s.uri or "unknown schema"
      local uri_text = s.uri and (" (" .. s.uri .. ")") or ""
      table.insert(lines, name .. uri_text)
    end
    if #lines == 0 then
      lines = { "No schemas applied" }
    end
    -- Show popup; see Neovim’s LSP floating preview docs
    vim.lsp.util.open_floating_preview(lines, "markdown", { border = "rounded", title = "YAML Schemas" })
  end, bufnr)
end

vim.api.nvim_create_user_command("YamlSchemas", show_yaml_schemas, {})

return {
  yamlls = {
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    settings = {
      yaml = {
        trace = {
          server = true
        },
        completion = true,
        format = {
          enable = true
        },
        schemas = {
          -- (schema, path match globPattern) tuples associate application of schema to specific buffers based on their paths
          -- schema can be local or remote
          --["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.2-standalone-strict/all.json"] = "*.{yml,yaml}", -- leads to multiple
          kubernetes = '*.{configmap,deployment,secret}.{yml,yaml}', -- leads to "matches multiple schemas" error when no patched, use 'diogo464/kubernetes.nvim'
          --
          -- only match '*.<resource>.yaml' files. ex: 'app.deployment.yaml', 'app.argocd.yaml',
          --[require('kubernetes').yamlls_schema()] = require('kubernetes').yamlls_filetypes(),
          --
          ["https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json"] =
          "*.{yml,yaml}",
          ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
          ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
          ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
          ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
          ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
          ["https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/ansible.json#/$defs/playbook"] =
          "*playbook.{yml,yaml}",
          ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
          ["https://json.schemastore.org/dependabot-v2"] = ".github/dependabot.{yml,yaml}",
          ["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
          ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] =
          "*api*.{yml,yaml}",
          ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] =
          "*docker-compose*.{yml,yaml}",
          ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = {
            "*workflow*.{yml,yaml}",
            "**/templates/*workflow*.{yml,yaml}",
          },
        }
      }
    }
  },
}
