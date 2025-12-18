return {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  event = "VeryLazy",
  config = function()
    local function hello()
      return [[hello world]]
    end

    require("lualine").setup({
      options = {
        icons_enabled = false,
        theme = "auto",
        component_separators = { left = " ", right = " " },
        section_separators = { left = " ", right = " " },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        -- use output of a function: lualine_c = { hello }
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "location", "[[Char 10]]", "%04b", "[[Char 16]]", "%04B" }, --utils.multibyteCharUnderCursor
        -- vimscript statusline items as lualine component: sections = { lualine_c = {'%=', '%t%m', '%3p'} }
        lualine_x = { "encoding", "fileformat", { "filetype", colored = true, } },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      -- TODO trying out tabby by commenting this out
      tabline = { -- Top bar
        lualine_a = { {
          'filename',
          path = 1,
          newfile_status = false,
        } }, -- buffers -- buffers
        lualine_b = { function() return 'Workspace:' .. vim.loop.cwd():sub(-20, -1) end },
        lualine_c = { function() return 'Buffer ID: ' .. vim.api.nvim_get_current_buf() end },
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'tabs' }
      },
      winbar = {},
      inactive_winbar = {},
      extensions = {
      },
    })
  end,
  --event = "VimEnter",
}
