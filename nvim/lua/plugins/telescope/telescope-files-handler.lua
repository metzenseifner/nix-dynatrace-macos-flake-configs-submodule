return {
  dir = vim.fn.stdpath("config") .. "/local_plugin_packages/telescope-files-handler.nvim",

  config = function(_, _)
    local conf = {
      -- ["/path/to/directory1"] = {
      --   keymap = {
      --     mode = "n",
      --     lhs = "<leader>fb",
      --     desc = "Open file browser",
      --   },
      --   extension = {
      --     name = "file_browser",
      --     func = "file_browser",
      --     opts = {},
      --   },
      -- },
      [vim.fn.expand("~") .. "/devel/dynatrace_bitbucket/15_TEAM_CARE_PROJECTS"] = {
        keymap = {
          mode = "n",
          lhs = "<leader>pp",
          desc = "Project picker",
        },
        extension = {
          name = "find_files",
          func = "find_files",
          opts = {},
        },
      },
    }
    require('telescope_files_handler').setup(conf)
  end
}
