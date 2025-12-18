return {
  dir = vim.fn.stdpath("config") ..  "/local_plugin_packages/sources-to-snippets.nvim",
  enabled = false,
  dependencies = {
    "cuducos/yaml.nvim"
  },

  config = function(_, _)
    local conf = {
      sources = {
        {
          -- Identifier of a source
          name = "Dynatrace Links",
          path = vim.fn.expand("~") .. "/.config/yaml-supplier/dynatrace_links.yaml",
          input_type = "yaml"
          -- Function providing snippets
          -- supplier = 
        },
        {
          name = "Team Members",
          path = vim.fn.expand("~") .. "/.config/yaml-supplier/team_members.yaml",
          input_type = "text"
        }
      }
    }
    require("sources-to-snippets").setup(conf)
  end
}
