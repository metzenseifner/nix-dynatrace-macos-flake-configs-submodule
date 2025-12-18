return {
  "artemave/workspace-diagnostics.nvim",

  config = function(_, user_opts)
    -- assumes user_opts (opts defined by user) is within closure
    local default_conf = {}
    local conf = vim.tbl_deep_extend("force", {}, default_conf, user_opts) -- force means right takes precedence (right overrides left)
    require "workspace-diagnostics".setup(conf)

    vim.api.nvim_set_keymap('n', '<leader>x', '', {
      desc = "Get diagnostics for entire workspace",
      noremap = true,
      callback = function()
        for _, client in ipairs(vim.lsp.buf_get_clients()) do
          -- if client ~= "ts_ls" then
            vim.notify("Populating Workspace Diagnostics from: ", client.name)
            require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
          -- end
        end
      end
    })
  end
}
