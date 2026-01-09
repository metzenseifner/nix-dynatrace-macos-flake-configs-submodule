-- Argo Workflows filetype plugin
-- Inherits from YAML with additional configuration

-- Set comment string for Argo YAML files
vim.bo.commentstring = "# %s"

-- Enable folding based on indent
vim.wo.foldmethod = "indent"
vim.wo.foldlevel = 99

-- Add YAML language server schema hint as modeline equivalent
-- This tells yamlls to use the Argo Workflows schema
vim.b.yaml_schema = "https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"

