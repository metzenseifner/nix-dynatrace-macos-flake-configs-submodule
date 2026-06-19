return
{
  {
    "chrisgrieser/nvim-origami",
    event = "VeryLazy",
    opts = {
      foldtext = {
        lineCount = {
          template = " %d"
        }
      }
    }, -- required even when using default config

    -- recommended: disable vim's auto-folding
    init = function()
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99

      -- vim.opt.statuscolumn = "%!v:lua.StatusCol()"
      -- vim.opt.statuscolumn = "%l%C "

      local fold_util = require("utils.code_folds")

      vim.keymap.set("n", "<CR>", "za", { noremap = true, silent = true })
      vim.keymap.set("n", "[[", fold_util.goto_previous_fold, { noremap = true, silent = true })
      vim.keymap.set("n", "]]", "zj", { noremap = true, silent = true })

      vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "LspAttach" }, {
        callback = function(opts)
          fold_util.update_ranges(opts.buf)
        end,
      })

      local last_row = nil
      vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function(opts)
          local row = vim.api.nvim_win_get_cursor(0)[1]
          if row ~= last_row then
            last_row = row

            fold_util.update_current_fold(row, opts.buf)
          end
        end,
      })

      vim.api.nvim_create_autocmd({ "BufUnload", "BufWipeout" }, {
        callback = function(opts)
          fold_util.clear(opts.buf)
        end,
      })

      vim.opt.statuscolumn = "%!v:lua.StatusCol()"
      function _G.StatusCol()
        return fold_util.statuscol()
      end
    end
  },
  {
    "luukvbaal/statuscol.nvim",
    opts = function()
      local builtin = require("statuscol.builtin")
      vim.opt.foldcolumn = "1"
      vim.opt.fillchars = {
        foldopen = "⌄", -- chevron-down
        foldclose = "›", -- chevron-right
        foldsep = " ",
      }
      return {
        setopt = true,
        ft_ignore = { "oil" },
        segments = {
          {
            text = { builtin.lnumfunc, '' },
            condition = { true, builtin.not_empty },
            click = 'v:lua.ScLa'
          },
          {
            text = { builtin.foldfunc, ' ' },
            click =
            'v:lua.ScFa'
          },
        }
      }
    end,
    config = function()
      require("statuscol").setup({
      })
    end,
  }
}
