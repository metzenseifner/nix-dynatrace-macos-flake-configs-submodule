return {
  disabled = false,
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/orgmode-preview.nvim",
  ft = "org",
  config = function()
    local orgmode_preview = require('orgmode-preview')

    local config = {
      css_file = vim.fn.stdpath('config') .. '/local_plugin_packages/orgmode-preview.nvim/latex.css',
      auto_refresh = false,
    }

    orgmode_preview.setup(config)

    local augroup = vim.api.nvim_create_augroup('OrgmodePreviewAutoRefresh', { clear = true })
    local autocmd_id = nil

    local function enable_auto_refresh()
      if autocmd_id then
        vim.notify("Live preview already enabled", vim.log.levels.INFO)
        return
      end

      autocmd_id = vim.api.nvim_create_autocmd('BufWritePost', {
        group = augroup,
        pattern = '*.org',
        callback = function()
          local outfile = vim.fn.expand('%:r') .. '.html'
          if vim.fn.filereadable(outfile) == 1 then
            orgmode_preview.preview()
          end
        end,
        desc = 'Auto-refresh org preview on save'
      })
      vim.notify("Live preview enabled - will auto-refresh on save", vim.log.levels.INFO)
    end

    local function disable_auto_refresh()
      if autocmd_id then
        vim.api.nvim_del_autocmd(autocmd_id)
        autocmd_id = nil
        vim.notify("Live preview disabled", vim.log.levels.INFO)
      else
        vim.notify("Live preview already disabled", vim.log.levels.INFO)
      end
    end

    vim.keymap.set('n', '<leader><leader>o', function()
      orgmode_preview.preview()
    end, {
      buffer = true,
      desc = 'Preview Org in browser with CSS (Pandoc)',
      silent = true,
    })

    vim.api.nvim_create_user_command('OrgPreviewLiveOn', enable_auto_refresh, {
      desc = 'Enable live preview mode (auto-refresh on save)'
    })

    vim.api.nvim_create_user_command('OrgPreviewLiveOff', disable_auto_refresh, {
      desc = 'Disable live preview mode'
    })

    if config.auto_refresh then
      enable_auto_refresh()
    end
  end,
}
