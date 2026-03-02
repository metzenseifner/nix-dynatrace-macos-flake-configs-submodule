return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  init = function()
    -- Disable entire built-in ftplugin mappings to avoid conflicts.
    -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
    vim.g.no_plugin_maps = true

    -- Or, disable per filetype (add as you like)
    -- vim.g.no_python_maps = true
    -- vim.g.no_ruby_maps = true
    -- vim.g.no_rust_maps = true
    -- vim.g.no_go_maps = true
  end,
  config = function()
    local conf = {
      move = {
        -- whether to set jumps in the jumplist
        set_jumps = true,
      }
    }
    require("nvim-treesitter-textobjects").setup(conf)

    -- You can use the capture groups defined in `textobjects.scm`
    vim.keymap.set({ "n", "x", "o" }, "gm", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
    end)
  end
}
