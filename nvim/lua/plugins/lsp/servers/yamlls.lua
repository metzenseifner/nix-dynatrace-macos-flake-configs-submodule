return {
  yamlls = {
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    settings = {
      --root_dir = util.find_git_ancestor,
      yaml = {
        trace = {
          server = true
        },
        cmd = { "yaml-language-server", "--stdio" },
        single_file_support = true,
        filetypes = { "yaml", "yml" },
        completion = true,
        format = {
          enable = true
        },
        --schemaStore = {
        --  -- JSON Schema Store
        --  -- https://github.com/SchemaStore/schemastore/tree/master/src/schemas/json
        --  enable = false, -- pulls all avail schemas from JSON schema store
        --  -- url =
        --},
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
          ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] =
          "*flow*.{yml,yaml}",
        }
      }
    }
  },
}
