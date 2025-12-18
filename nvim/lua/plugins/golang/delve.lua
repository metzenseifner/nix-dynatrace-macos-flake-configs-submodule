-- go install github.com/go-delve/delve/cmd/dlv@latest
return {
  {
    "leoluz/nvim-dap-go", -- delve integration
    dependencies = "mfussenegger/nvim-dap",
    ft = "go",
    keys = {
      { "<leader>dgt", function() require("dap-go").debug_test() end, desc = "Debug go test (Run go test in debug mode)" },
      { "<leader>dgl", function() require("dap-go").debug_last() end, desc = "Debug last go test" },
    },
    config = function(_, opts)
      require("dap-go").setup(opts)
    end
  },
}
