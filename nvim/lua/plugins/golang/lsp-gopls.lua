return
{ -- official Language Server
  --on_attach is already setup I think?
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  cmd = { "gopls", "--remote=auto" },
  -- NOTE TO SELF: commenting out root_dir to try and get better reliability without missing go.mod
  --root_dir = require 'lspconfig'.util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#gopls
    -- Upstream https://github.com/golang/tools/tree/master/gopls
    -- https://github.com/golang/tools/tree/master/gopls#supported-go-versions
    -- Supports goimports formatting -local string param to separate 3rd-party packages from internal by a string
    --
    -- Features
    --   - Formatting with gofumpt
    gopls = { -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
      hoverKind = "FullDocumentation",
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      --staticcheck = true,
      --gofumpt = true,
      --vulncheck = "imports",
      --completion = true,
      usePlaceholders = true,
      analyses = { -- static analysis options: https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
        unusedparams = true
      },
      codelenses = {
        generate = true,  -- Don't show the `go generate` lens.
        gc_details = true -- Show a code lens toggling the display of gc's choices.
      },
    }
  }
}
