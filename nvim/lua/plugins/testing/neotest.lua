return {
  {
    "nvim-neotest/neotest",
    lazy = true,
    event = { "LspAttach", "DirChanged" },

    dependencies = {
      { "nvim-neotest/nvim-nio" },
      { "nvim-lua/plenary.nvim" },
      { "antoinemadec/FixCursorHold.nvim" },
      { "nvim-treesitter/nvim-treesitter" }, -- important for detecting tests

      -- Load adapter plugins from separate files
      { import = "plugins.testing.adapters.golang" },
      { import = "plugins.testing.adapters.ginkgo" },
    },
    config = function()
      -- Dynamically load adapters
      local adapters = {}

      -- Go adapter
      local ok_go, neotest_go = pcall(require, "neotest-golang")
      if ok_go then
        -- neotest-golang needs to be called as a function to initialize
        table.insert(adapters, neotest_go({
          -- Let neotest-golang auto-detect build tags from files
          dap_go_enabled = false, -- Disable DAP integration if not needed
        }))
      end

      -- Ginkgo adapter (if enabled)
      -- local ok_ginkgo, ginkgo = pcall(require, "nvim-ginkgo")
      -- if ok_ginkgo then
      --   table.insert(adapters, ginkgo)
      -- end

      require("neotest").setup({
        log_level = 3,
        quickfix = {
          enabled = true,
          open = false,
        },
        adapters = adapters,
        -- output_panel = {
        --   enabled = true,
        --   open = true,
        -- },
        highlights = {
          test = "NeotestBorder"
        }
        --config = {
        --  output_panel = { open_on_run = true },
        --  diagnostics = true,
        --}

      })
    end,
    keys = {
      {
        "<leader><leader>tn",
        function()
          require("neotest").run.run()
          require("neotest").summary.open()
        end,
        desc = "Neotest run nearest test. (test nearest)"
      },
      {
        "<leader><leader>tb",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
          require("neotest").summary.open()
        end,
        desc = "Neotest run current file (buffer). (test buffer)"
      },
      {
        "<leader><leader>tnd",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Neotest run nearest test in debug mode."
      },
      {
        "<leader><leader>tns",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop nearest test."
      },
      {
        "<leader><leader>tna",
        function()
          require("neotest").run.attach()
        end,
        desc = "Attach to nearest test."
      },
      { "<leader><leader>tam",  function() require("neotest").summary.run_marked() end,   desc = "Neotest run all marked tests in summary." },
      { "<leader><leader>tw",   function() require("neotest").watch.watch() end,          desc = "Watch files for changes and run tests." },
      { "<leader><leader>tus",  function() require("neotest").summary.toggle() end,       desc = "Neotest Toggle Test Summary Window" },
      { "<leader><leader>tuo",  function() require("neotest").output_panel.open() end,    desc = "Neotest Open Test Output Panel Window" },
      { "<leader><leader>tuoc", function() require("neotest").output_panel.close() end,   desc = "Neotest Close Test Output Panel Window" },
      { "<leader><leader>tuot", function() require("neotest").output_panel.toggle() end,  desc = "Neotest Toggle Test Output Panel Window" },
      { "<leader><leader>tcm",  function() require("neotest").summary.clear_marked() end, desc = "Neotest Clear marked to tests in summary." },
    }
  },
}
