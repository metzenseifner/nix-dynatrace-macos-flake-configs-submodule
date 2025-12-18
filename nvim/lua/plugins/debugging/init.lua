--return {
--  { "mxsdev/nvim-dap-vscode-js", dependencies = { "mfussenegger/nvim-dap" } },
--  { "leoluz/nvim-dap-go",               dependencies = { "mfussenegger/nvim-dap" } }, -- avoid manual integration between nvim-dap <-> go code <-> delve server
--  { "nvim-neotest/nvim-nio" },                                                 -- aims to provide a simple interface to Lua coroutines. A library for asynchronous IO in Neovim, inspired by the asyncio library in Python.
--  { "rcarriga/nvim-dap-ui",      dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } } -- see lazydev.nvim to enable type checking for nvim-dap-ui to get type checking, documentation and autocompletion for all API functions.
--  -- lazydev.nvim is a replacement for neodev.nvim -- Adds full signature help, docs and completion for the NeoVim Lua API
--}
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = { "rcarriga/nvim-dap-ui" },
    init = function()
      -- kept here because it was an interesting approach found https://github.com/dreamsofcode-io/neovim-go-config/blob/main/plugins.lua#L22 but missing core/utils in lua.
      --require("core.utils").load_mappings("dap")
    end,

    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<CR>", desc = "Add breakpoint at line" },
      {
        "<leader>dus",
        function()
          local widgets = require('dap.ui.widgets');
          local sidebar = widgets.sidebar(widgets.scopes);
          sidebar.open()
        end,
        desc = "Open debugging sidebar pane."
      }
    },

    config = function(modname, opts)
      local dap = require("dap")
      require('dap-go').setup(opts)


      dap.configurations.typescriptreact = { -- change to typescript if needed
        {
          type = "chrome",
          request = "attach",
          program = "${file}",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = "inspector",
          port = 9222,
          webRoot = "${workspaceFolder}"
        }
      }

      -- https://github.com/microsoft/vscode-js-debug
      -- requires downloading https://github.com/microsoft/vscode-js-debug/releases >= 1.77.0
      -- Extract to place and point to it
      -- tar -xof js-debug-dap-v1.85.0.tar.gz -C ~/.local/share/js-vscode-dap
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { vim.fn.expand("$HOME/.local/share/js-vscode-dap/js-debug/src/dapDebugServer.js"), "${port}" },
        }
      }
      dap.configurations.typescript = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = "Launch file",
          runtimeExecutable = "deno",
          runtimeArgs = {
            "run",
            "--inspect-wait",
            "--allow-all"
          },
          program = "${file}",
          cwd = "${workspaceFolder}",
          attachSimplePort = 9229,
        },
      }
    end
  },
}
-- BEGIN Debugger Adapter Protocol (DAP)
--Mapper.map('n', '<F5>', ":lua require'dap'.continue()<CR>", opts, 'DAP', 'dap.continue',
--  'DAP continue. Debugger Adapter Protocol.');
--Mapper.map('n', '<F10>', ":lua require'dap'.step_over()<CR>", opts, 'DAP', 'dap.step_over',
--  'DAP step over. Debugger Adapter Protocol.');
--Mapper.map('n', '<F11>', ":lua require'dap'.step_info()<CR>", opts, 'DAP', 'dap.step_into',
--  'DAP step into. Debugger Adapter Protocol.');
--Mapper.map('n', '<F12>', ":lua require'dap'.step_out()<CR>", opts, 'DAP', 'dap.step_out',
--  'DAP step out. Debugger Adapter Protocol.');
--Mapper.map('n', '<leader>b', ":lua require'dap'.toggle_breakpoint()<CR>", opts, 'DAP', 'dap.toggle_breakpoint',
--  'DAP toggle breakpoint. Debugger Adapter Protocol.');
--Mapper.map('n', '<leader>B', ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", opts, 'DAP'
--, 'dap.set_breakpoint', 'DAP set breakpoint(condition). Debugger Adapter Protocol.');
--Mapper.map('n', '<leader>lp', ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", opts
--, 'DAP', 'dap.set_breakpoint(log point message)', 'DAP set breakpoint. Debugger Adapter Protocol.');
--Mapper.map('n', '<leader>dr', ":lua require'dap'.repl.open()<CR>", opts, 'DAP', 'dap.repl.open',
--  'DAP replace open. Debugger Adapter Prococol.')
--Mapper.map('n', '<C-Right>', ":lua vim.cmd('bn')<CR>", opts, 'Buffers', 'vim.cmd.buffernext',
--  'Next active buffer, cycle right.')
--Mapper.map('n', '<C-Left>', ":lua vim.cmd('bp')<CR>", opts, 'Buffers', 'vim.cmd.bufferprev',
--  'Make previous buffer in buffers active, cycle left.')
