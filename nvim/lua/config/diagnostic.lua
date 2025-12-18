local vim = vim --servers to aggregate linter undefined global vim messages

function printFormatOptions()
  -- formatoptions are the secret to Javadoc style comments
  -- print value of vim.opt.formatoptions
  -- Note that when 'paste' is on, Vim does no formatting at all.
  -- used in conjunction with
  --   <cmd>autocmd for file type contexts
  --   vim.opt.textwidth for auto wrapping (default 0, which means 79)
  -- For values that are lists of flags, a set will be returned with the
  -- flags as keys and true as entries.
  --
  -- Equivalent expressions:
  -- 1. vim.opt.formatoptions:append('j')
  -- 2. vim.opt.formatoptions = vim.opt.formatoptions + 'j'
  local letterToSemantics = {
    t = 'Auto-wrap using textwidth',
    c = 'Auto-wrap comments using textwidth, inserting comment leader (prefix)',
    r = 'Automatically insert the current comment leader after pressing <Enter> in Insert mode',
    o =
    'Automatically insert the current comment leader after hitting "o" or "O" in Normal mode.  In case comment is unwanted in a specific place use CTRL-U to quickly delete it.',
    forwardslash = '',
    q = '',
    w = '',
    a = '',
    n = '',
    TWO = '',
    v = '',
    b = '',
    l = '',
    m = '',
    M = '',
    B = '',
    ONE = '',
    CLOSEBACKET = '',
    j = '',
    p = '',
  }
  print("Autoformat options: ")
  vim.pretty_print(vim.opt.formatoptions:get())
end

-- Use this table for
-- vim.diagnostic.config.virtual_text.severity
local all_severities = {
  vim.diagnostic.severity.ERROR,
  vim.diagnostic.severity.WARN,
  vim.diagnostic.severity.INFO,
  vim.diagnostic.severity.HINT,

  -- compare to vim.log.levels
  -- vim.log.levels.INFO
  -- vim.log.levels.WARN
  -- etc.
}

-- :h Diagnostic framework (generated from source using tree-sitter-vimdoc parser)
-- Global Nvim Diagnostic Framework config
--   Note: Not as powerful as overriding handler functions, because it is
--   limited by what the config param supports. Overriding functions gives
--   complete control of execution.
vim.diagnostic.config({
  severity_sort = true, -- influences priorities of signs
  update_on_insert = false,
  underline = true,     -- underline code affected by diagnostic message
  source = true,
  virtual_text = {
    severity = all_severities,
    source = true,
    prefix = "●",
    spacing = 2,
    format =
        function(diagnostic)
          if diagnostic.severity == vim.diagnostic.severity.ERROR then
            return string.format("%s", diagnostic.message)
          end
          return diagnostic.message
        end
  }, -- non-float text shown inline with actual text
  signs = {
    -- Indicator char prefix by line numbers to indicate diagnostics available
    severity = all_severities,
    --priority = 1 --default 10, affected by severity_sort
  },
  float = {
    -- config vim.diagnostic.open_float
    header = "Call :: vim.diagnostic.open_float()",
    severity_sort = true, --default false
    severity = all_severities,
    --header = "Diagnostics:",
    width = 250,
    border = "rounded",
    source = false,
    -- format = function :: diagnostic -> string
    prefix = function(diag, idx, total) --function(diagnostic, i, total)|string|table
      -- source does not show the precise rule that triggered a given diagnostic msg, unfortunately
      return string.format("%s. %5s %11s: ", idx, vim.diagnostic.severity[diag.severity], diag.source)
    end
  },
  ["my/notify"] = { -- configure configure custom handler
    log_level = vim.log.levels.INFO,
  },
})

-- Configure signs
-- sign define DiagnosticSignError text=E texthl=DiagnosticSignError linehl= numhl=
-- sign define DiagnosticSignWarn text=W texthl=DiagnosticSignWarn linehl= numhl=
-- sign define DiagnosticSignInfo text=I texthl=DiagnosticSignInfo linehl= numhl=
-- sign define DiagnosticSignHint text=H texthl=DiagnosticSignHint linehl= numhl=
--vim.fn.sign_define("LspDiagnosticsSignError", { text = "", numhl = "LspDiagnosticsDefaultError" })
--vim.fn.sign_define("LspDiagnosticsSignWarning", { text = "", numhl = "LspDiagnosticsDefaultWarning" })
--vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "", numhl = "LspDiagnosticsDefaultInformation" })
--vim.fn.sign_define("LspDiagnosticsSignHint", { text = "", numhl = "LspDiagnosticsDefaultHint" })

-- Nvim provides these handlers by default: "virtual_text", "signs", and
-- "underline"
-- Handlers get called everytime vim.diagnostic.show gets called
-- called indirectly by vim.diagnostic.open_float
-- Adds key to vim.diagnostics.handlers called "my/notify"
-- It's good practice to namespace custom handlers to avoid collisions
vim.diagnostic.handlers["my/notify"] = {
  -- IF YOU WANT TO DO SOMETHING UPON NEW DIAGNOSTICS USE ME
  --show = function(namespace, bufnr, diagnostics, opts)
  --  -- In our example, the opts table has a "log_level" option
  --  local level = opts["my/notify"].log_level

  --  local name = vim.diagnostic.get_namespace(namespace).name
  --  local msg = string.format("%d diagnostics in buffer %d from %s",
  --    #diagnostics,
  --    bufnr,
  --    name)
  --  -- adds note for every dianostics response from all lsp servers in buffer
  --  vim.notify(msg, level)
  --end,
}
-- -- Create a custom namespace. This will aggregate signs from all other
-- -- namespaces and only show the one with the highest severity on a
-- -- given line
-- local ns = vim.api.nvim_create_namespace("my_namespace")
--
-- -- Get a reference to the original signs handler
-- local orig_signs_handler = vim.diagnostic.handlers.signs
--
-- -- Override built-in signs handler (1 of 3 builtin: signs, virtual-text, underline)
-- vim.diagnostic.handlers.signs = {
--   show = function(_, bufnr, _, opts)
--     -- Get all diags from the whole buffer rather than those passed to handler
--     local diagnostics = vim.diagnostic.get(bufnr)
--
--     -- Order by severity worst to better (TODO...below just calcs max)
--     local max_severity_per_line = {}
--     for _, d in pairs(diagnostics) do
--       local m = max_severity_per_line[d.lnum]
--       if not m or d.severity < m.severity then
--         max_severity_per_line[d.lnum] = d
--       end
--   end
-- }

-- Example of overriding functions (that does nothing to the original except add a useless stack frame)
-- vim.diagnostic.open_float = (function(orig)
--   return function(opts)
--     return orig(opts)
--   end
-- end)(vim.diagnostic.open_float)

-- This technique overrides the declarative approach if not carefully written
-- OVERRIDE vim.diagnostic.open_float with higher-order function
-- wrap open_float to inspect diagnostics and use the severity color for border
-- https://neovim.discourse.group/t/lsp-diagnostics-how-and-where-to-retrieve-severity-level-to-customise-border-color/1679
vim.diagnostic.open_float = (function(original_function)
  return function(bufnr, opts)
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    local opts = opts or {}
    -- A more robust solution would check the "scope" value in `opts` to
    -- determine where to get diagnostics from, but if you're only using
    -- this for your own purposes you can make it as simple as you like
    local diagnostics = vim.diagnostic.get(opts.bufnr or 0, { lnum = lnum })

    -- Determine most severe message
    local max_severity = vim.diagnostic.severity.HINT
    for _, d in ipairs(diagnostics) do
      -- Equality is "less than" based on how the severities are encoded
      if d.severity < max_severity then
        max_severity = d.severity
      end
    end

    -- Border color determined by most sever message at instant
    local border_color = ({
      [vim.diagnostic.severity.HINT]  = "DiagnosticHint",
      [vim.diagnostic.severity.INFO]  = "DiagnosticInfo",
      [vim.diagnostic.severity.WARN]  = "DiagnosticWarn",
      [vim.diagnostic.severity.ERROR] = "DiagnosticError",
    })[max_severity]
    -- overrides existing opts.border
    opts.border = {
      { "╔", border_color },
      { "═", border_color },
      { "╗", border_color },
      { "║", border_color },
      { "╝", border_color },
      { "═", border_color },
      { "╚", border_color },
      { "║", border_color },
    }
    original_function(bufnr, opts)
  end
end)(vim.diagnostic.open_float)

local M = {}

---@enum DiagnosticSeverity
M.severity = {
  ERROR = 1,
  WARN = 2,
  INFO = 3,
  HINT = 4,
}

local errlist_type_map = {
  [M.severity.ERROR] = 'E',
  [M.severity.WARN] = 'W',
  [M.severity.INFO] = 'I',
  [M.severity.HINT] = 'N',
}

-- Diagnostics for diagnostics on save function
-- @output nil
-- effect: set quickfix list to a set of filtered diagnostics
M.get_diagnostics = function(config)
  -- TODO Sort by severity descending
  --if M.is_empty_table(config) then
  --  config.as_qflist = true
  --end
  --if config.as_qflist == true then

  -- This is a table of tables whereby each conforms to a diagnostic-structure
  local current_diagnostics_tbl = vim.diagnostic.get()

  --for _idx, tbl in pairs(current_diagnostics_tbl) do
  local filtered_table = require('config.functions').filter(current_diagnostics_tbl,
    function(t)
      if t.message:find("is defined but never used") then
        return true
        --if (t.source == 'eslint') then
        --  return true
      else
        return t.severity < M.severity.WARN
      end
    end)
  --end

  local filtered_diags_tbl = filtered_table

  local current_diag_sorted_by_severity = M.toqflist_custom(filtered_diags_tbl)

  --vim.diagnostic.setqflist(current_diag_sorted_by_severity, 'r')
  vim.fn.setqflist({}, ' ', { title = "vim.diagnostic", items = current_diag_sorted_by_severity, context = 'r' })
  if #current_diag_sorted_by_severity ~= 0 then
    vim.api.nvim_command('botright copen')
  end


  --vim.diagnostic.toqflist(sorted_by_severity_current_diagnostics_tbl) --sorts by bufnr internally. Not what we want.
  --return vim.diagnostic.toqflist(vim.diagnostic.get())
  --end
  return nil
end
--- Convert a list of diagnostics to a list of quickfix items that can be
--- passed to |setqflist()| or |setloclist()|.
---
---@param diagnostics table List of diagnostics |diagnostic-structure|.
---@return table[] of quickfix list items |setqflist-what|
function M.toqflist_custom(diagnostics)
  vim.validate({
    diagnostics = {
      diagnostics,
      vim.tbl_islist,
      'a list of diagnostics',
    },
  })

  local list = {}
  for _, v in ipairs(diagnostics) do
    local item = {
      bufnr = v.bufnr,
      lnum = v.lnum + 1,
      col = v.col and (v.col + 1) or nil,
      end_lnum = v.end_lnum and (v.end_lnum + 1) or nil,
      end_col = v.end_col and (v.end_col + 1) or nil,
      text = v.message,
      type = errlist_type_map[v.severity] or 'E',
    }
    table.insert(list, item)
  end
  -- Sort by severity (integer)
  table.sort(diagnostics, function(a, b)
    if a.severity == b.severity then
      return a.lnum < b.lnum
    else
      return a.severity > b.severity
    end
  end)
  return list
end

M.open_diagnostics = function()
  local content = vim.diagnostic.get()
  local convert_diag_table_to_quickfix_list = vim.diagnostic.toqflist
  local set_quickfix_list_to = vim.diagnostic.setqflist
  --vim.diagnostic.setqflist(vim.diagnostic.toqflist(vim.diagnostic.get()))
  set_quickfix_list_to(convert_diag_table_to_quickfix_list(content))
end
return M
