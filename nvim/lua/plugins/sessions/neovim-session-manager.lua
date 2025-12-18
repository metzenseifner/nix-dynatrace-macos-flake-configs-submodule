return {
  "Shatur/neovim-session-manager",
  config = function(_, opts)
    -- local my_save_session = function()
    --   for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    --     -- Don't save while there's any 'nofile' buffer open.
    --     if vim.api.nvim_get_option_value("buftype", { buf = buf }) == 'nofile' then
    --       return
    --     end
    --   end
    --   vim.notify("Saving session using neovim-session-manager")
    --   require 'session_manager'.save_current_session()
    -- end
    --
    -- vim.api.nvim_create_user_command("SessionSave", my_save_session, {})
    --
    -- -- Auto save session
    -- vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    --   callback = my_save_session
    -- })


    require 'session_manager'.setup(opts)

    local session_group = vim.api.nvim_create_augroup('MySessionGroup', {})

    local make_lifecycle_listener = function(event, func)
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = event,
        group = session_group,
        callback = func
      })
    end

    make_lifecycle_listener("SessionLoadPre", function() vim.notify("Loading Session") end)
    make_lifecycle_listener("SessionLoadPost", function()
      vim.notify("Session loaded: " .. vim.loop.cwd())
      vim.cmd(":Neotree show")
    end)
  end
}
