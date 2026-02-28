-- Nix language server configuration
-- Gracefully handles when nil is not installed
return {
  nil_ls = {
    mason = false,
    -- Check if nil is available in PATH before attempting to start
    autostart = vim.fn.executable('nil') == 1,
    on_init = function(client)
      if vim.fn.executable('nil') ~= 1 then
        vim.notify(
          "nil (Nix language server) not found in PATH. Install via: programs.nixLsp.enable = true;",
          vim.log.levels.WARN
        )
        return false
      end
      vim.notify("nil (Nix language server) initialized successfully", vim.log.levels.INFO)
      return true
    end,
  }
}
