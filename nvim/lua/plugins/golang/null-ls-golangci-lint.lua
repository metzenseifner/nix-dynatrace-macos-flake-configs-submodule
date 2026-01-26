-- golangci-lint v2 diagnostics via none-ls
-- Uses the golangci-lint from nix flake environment
-- CUSTOM implementation for v2.x which has different CLI flags than v1.x

local null_ls = require("null-ls")
local h = require("null-ls.helpers")

-- Find golangci-lint in PATH, preferring nix store version
local function find_golangci_lint()
  local path_entries = vim.split(vim.env.PATH, ":", { plain = true })

  -- First, look for nix store version (v2.x)
  for _, path_entry in ipairs(path_entries) do
    if path_entry:match("/nix/store/.*golangci%-lint") then
      local candidate = path_entry .. "/golangci-lint"
      if vim.fn.executable(candidate) == 1 then
        vim.notify(string.format("Using golangci-lint from Nix Store: %s", candidate), vim.log.levels.INFO)
        return candidate
      end
    end
  end

  -- Fallback to default PATH search
  local cmd = "golangci-lint"
  if vim.fn.executable(cmd) == 1 then
    vim.notify(string.format("Using golangci-lint from PATH: %s", vim.fn.exepath(cmd)), vim.log.levels.INFO)
  else
    vim.notify("golangci-lint not found in PATH", vim.log.levels.WARN)
  end
  return cmd
end

-- Custom output handler for golangci-lint v2 JSON format
local handle_golangci_output = function(params)
  local output = params.output

  -- Log the raw command execution
  vim.notify(string.format("[golangci-lint] Running on: %s", params.bufname), vim.log.levels.DEBUG)

  if not output or output == "" then
    vim.notify("[golangci-lint] No output received (file may be clean)", vim.log.levels.DEBUG)
    return {}
  end

  -- Log raw output for debugging
  vim.notify(string.format("[golangci-lint] Raw output:\n%s", output), vim.log.levels.DEBUG)

  local ok, decoded = pcall(vim.json.decode, output)
  if not ok then
    vim.notify(string.format("[golangci-lint] Failed to decode JSON. Error: %s\nOutput: %s", decoded, output),
      vim.log.levels.ERROR)
    return {}
  end

  if not decoded or not decoded.Issues then
    vim.notify("[golangci-lint] No issues found in output", vim.log.levels.DEBUG)
    return {}
  end

  local diagnostics = {}
  local diagnostics_by_file = {}

  for _, issue in ipairs(decoded.Issues) do
    -- Default to ERROR for typecheck and other critical linters, otherwise WARN
    local severity = vim.diagnostic.severity.WARN
    if issue.Severity == "error" then
      severity = vim.diagnostic.severity.ERROR
    elseif issue.Severity == "" or issue.Severity == nil then
      -- Empty severity: treat typecheck, gosec, staticcheck as errors, others as warnings
      local error_linters = { "typecheck", "gosec", "staticcheck" }
      for _, linter in ipairs(error_linters) do
        if issue.FromLinter == linter then
          severity = vim.diagnostic.severity.ERROR
          break
        end
      end
    end

    -- Construct absolute path for the diagnostic
    local filename = issue.Pos.Filename
    if not filename:match("^/") then
      -- Relative path, make it absolute using cwd
      filename = vim.fn.getcwd() .. "/" .. filename
    end

    -- Get or create buffer for this file to ensure diagnostics are registered
    local bufnr = vim.fn.bufnr(filename)
    if bufnr == -1 then
      -- Buffer doesn't exist, create it without loading
      bufnr = vim.fn.bufadd(filename)
    end

    local diagnostic = {
      bufnr = bufnr,
      lnum = issue.Pos.Line - 1,  -- neovim uses 0-indexed lines
      col = issue.Pos.Column - 1, -- neovim uses 0-indexed columns
      end_lnum = issue.Pos.Line - 1,
      end_col = issue.Pos.Column - 1,
      source = "golangci-lint",
      message = string.format("%s (%s)", issue.Text, issue.FromLinter),
      severity = severity,
    }

    -- Group diagnostics by file for proper registration
    if not diagnostics_by_file[bufnr] then
      diagnostics_by_file[bufnr] = {}
    end
    table.insert(diagnostics_by_file[bufnr], diagnostic)

    -- Also add to main list for null-ls compatibility
    table.insert(diagnostics, {
      row = issue.Pos.Line,
      col = issue.Pos.Column,
      source = "golangci-lint",
      message = string.format("%s (%s)", issue.Text, issue.FromLinter),
      severity = severity,
      filename = filename,
    })

    -- Debug log each diagnostic
    vim.notify(
    string.format("[golangci-lint] Diagnostic: %s:%d:%d (buf:%d) - %s", filename, issue.Pos.Line, issue.Pos.Column, bufnr,
      issue.Text), vim.log.levels.TRACE)
  end

  -- Register diagnostics with neovim's diagnostic system for each file
  -- Clear old diagnostics first to ensure stale diagnostics are removed
  local namespace = vim.api.nvim_create_namespace("golangci-lint")
  
  -- Clear all existing diagnostics in this namespace for all loaded buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "go" then
      vim.diagnostic.reset(namespace, bufnr)
    end
  end
  
  -- Now set the new diagnostics
  for bufnr, diags in pairs(diagnostics_by_file) do
    vim.diagnostic.set(namespace, bufnr, diags, {})
  end

  vim.notify(string.format("[golangci-lint] Found %d issue(s)", #diagnostics), vim.log.levels.INFO)
  return diagnostics
end

-- Custom golangci-lint v2 source
local golangci_lint_v2 = h.make_builtin({
  name = "golangci_lint_v2",
  meta = {
    url = "https://golangci-lint.run/",
    description = "A Go linters aggregator (v2.x compatible with build-tags support).",
  },
  method = null_ls.methods.DIAGNOSTICS_ON_SAVE, -- control whether on save or realtime, see debounce
  filetypes = { "go" },
  generator_opts = {
    command = find_golangci_lint(),
    args = function(params)
      -- Run golangci-lint on the entire package, not just the current file
      -- This allows workspace diagnostics to see all issues
      local package_path = "./..."
      local args = {
        "run",
        "--build-tags", "containers_image_openpgp",
        "--output.json.path", "stdout",
        "--issues-exit-code=0",
        "--show-stats=false", -- Disable stats summary to output pure JSON
        "--timeout", "10m0s", -- Match your command line timeout
        "--path-prefix", "",
        "--verbose",          -- Enable verbose output
        "--max-issues-per-linter", "0", -- Show all issues (default 50)
        "--max-same-issues", "0",       -- Show all instances (default 3)
        package_path,         -- Lint entire workspace instead of single file
      }
      vim.notify(string.format("[golangci-lint] Command: %s %s", find_golangci_lint(), table.concat(args, " ")),
        vim.log.levels.DEBUG)
      return args
    end,
    format = "raw",
    timeout = 620000, -- 10 minutes + 20 seconds buffer in milliseconds
    to_stdin = false,
    from_stderr = false,
    on_output = handle_golangci_output,
    cwd = h.cache.by_bufnr(function(params)
      local cwd = vim.fn.getcwd()
      vim.notify(string.format("[golangci-lint] Working directory: %s", cwd), vim.log.levels.DEBUG)
      return cwd
    end),
  },
  factory = h.generator_factory,
})

return golangci_lint_v2
