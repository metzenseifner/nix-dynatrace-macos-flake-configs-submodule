return {
  "sindrets/diffview.nvim",
  dependencies = "nvim-lua/plenary.nvim",

  config = function(_, _)
    local config = {
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
          winbar_info = true,
        },
      },
      keymaps = {
        view = {
          { "n", "<leader>p", require('diffview.actions').prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
          { "n", "<leader>n", require('diffview.actions').next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
        }
      },
      hooks = {
        diff_buf_read = function(bufnr)
          -- Change local options in diff buffers
          vim.opt_local.wrap = false
          vim.opt_local.list = false
          vim.opt_local.colorcolumn = { 80 }
        end,
        view_opened = function(view)
          vim.opt_local.foldenable = false
          print(
            ("A new %s was opened on tab page %d!")
            :format(view.class:name(), view.tabpage)
          )
        end,
      },
    }
    require("diffview").setup(config)
  end
}
