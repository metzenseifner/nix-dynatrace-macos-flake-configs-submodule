return {
  "Exafunction/codeium.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "InsertEnter",
  config = function()
    require("codeium").setup({
      -- Ghost-text only (Copilot-style). We deliberately do NOT register a
      -- nvim-cmp source so Codeium stays out of the pop-up menu, which is
      -- already crowded with LSP/luasnip/buffer sources.
      enable_cmp_source = false,
      virtual_text = {
        enabled = true,
        manual = false,
        -- <Tab> is unusable under the tmux/wezterm setup (see nvim-cmp/init.lua),
        -- and <C-x> is already bound there to toggle the cmp menu — so accept
        -- and cycle live on free chords.
        key_bindings = {
          accept = "<C-g>",
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      -- Use the Nix-built (already patchelf'd) server instead of letting the
      -- plugin download a dynamically-linked binary that fails on NixOS. Path
      -- is injected by modules/neovim/flake.nix via NIX_CODEIUM_SERVER.
      tools = {
        language_server = vim.env.NIX_CODEIUM_SERVER,
      },
    })
  end,
}
