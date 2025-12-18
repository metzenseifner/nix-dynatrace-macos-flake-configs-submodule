return {
  golangci_lint_ls = {
    filetypes = { "go", "gomod" },
    cmd = { 'golangci-lint-langserver' },
    root_dir = require("lspconfig").util.root_pattern('.git', 'go.mod'),
    init_options = {
     command = { "golangci-lint", "run", "--output.json.path", "stdout", "--show-stats=false", "--issues-exit-code=1" },
    }
  },
}
