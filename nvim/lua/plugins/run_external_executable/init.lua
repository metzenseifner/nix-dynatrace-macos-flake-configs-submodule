return {
  dir = vim.fn.stdpath('config') .. "/local_plugin_packages/run_external_executable.nvim",
  config = function()
    require'ipc'
  end
}
