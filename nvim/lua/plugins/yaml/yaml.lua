return {
  "cuducos/yaml.nvim",
  ft = { "yaml" },   -- optional
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",   -- optional
  },
  keys = {
    {
      "<leader>yp",
      function()
        local yaml = require('yaml_nvim')
        local path = yaml.get_yaml_key()
        if path then
          vim.fn.setreg('+', path)
          require('osc52').copy(path)
          print('Copied YAML path to register @ and system clipboard: ' .. path)
        else
          vim.notify('No YAML key found under cursor', vim.log.levels.WARN)
        end
      end,
      desc = "Copy YAML path in dot notation to clipboard and register",
      ft = { "yaml" },
    },
  },
}
