return {
    'willothy/moveline.nvim',
    -- Only build if cargo is available (requires Rust toolchain)
    -- Falls back to pure Lua implementation if build fails
    build = function()
      if vim.fn.executable('cargo') == 1 then
        return 'make'
      else
        vim.notify("moveline.nvim: cargo not found, skipping native build (falling back to Lua)", vim.log.levels.INFO)
        return nil
      end
    end,
    -- Lazy load to avoid build errors on startup
    event = "VeryLazy",
}
