return {
  "lewis6991/hover.nvim",
  opts = {
    --- List of modules names to load as providers.
    --- @type (string|Hover.Config.Provider)[]
    providers = {
      'hover.providers.diagnostic',
      'hover.providers.lsp',
      'hover.providers.dap',
      'hover.providers.man',
      'hover.providers.dictionary',
      -- Optional, disabled by default:
      -- 'hover.providers.gh',
      -- 'hover.providers.gh_user',
      -- 'hover.providers.jira',
      -- 'hover.providers.fold_preview',
      -- 'hover.providers.highlight',
    },
    preview_opts = {
      border = 'single'
    },
    -- Whether the contents of a currently open hover window should be moved
    -- to a :h preview-window when pressing the hover keymap.
    preview_window = false,
    title = true,
    mouse_providers = {
      'hover.providers.lsp',
    },
    mouse_delay = 1000
  },
  config = function(mod, opts)
    require("hover").setup(opts)
    
    -- Fix for hover.nvim newline bug
    -- Wrap open_floating_preview to split any lines containing newlines
    local hover_util = require('hover.util')
    local original_open = hover_util.open_floating_preview
    
    hover_util.open_floating_preview = function(contents, bufnr, syntax, opts_inner)
      -- If contents provided, ensure no embedded newlines
      if contents and type(contents) == 'table' then
        local fixed_contents = {}
        for _, line in ipairs(contents) do
          if type(line) == 'string' and line:find('\n') then
            -- Split lines with embedded newlines
            local split_lines = vim.split(line, '\n', { plain = true, trimempty = false })
            for _, split_line in ipairs(split_lines) do
              table.insert(fixed_contents, split_line)
            end
          else
            table.insert(fixed_contents, line)
          end
        end
        contents = fixed_contents
      end
      
      return original_open(contents, bufnr, syntax, opts_inner)
    end
    -- Setup keymaps
    vim.keymap.set('n', 'K', function()
      require('hover').open()
    end, { desc = 'hover.nvim (open)' })

    vim.keymap.set('n', 'gK', function()
      require('hover').enter()
    end, { desc = 'hover.nvim (enter)' })

    vim.keymap.set('n', '<C-p>', function()
      require('hover').switch('previous')
    end, { desc = 'hover.nvim (previous source)' })

    vim.keymap.set('n', '<C-n>', function()
      require('hover').switch('next')
    end, { desc = 'hover.nvim (next source)' })

    -- Mouse support
    vim.keymap.set('n', '<MouseMove>', function()
      require('hover').mouse()
    end, { desc = 'hover.nvim (mouse)' })

    vim.o.mousemoveevent = true
  end
}
