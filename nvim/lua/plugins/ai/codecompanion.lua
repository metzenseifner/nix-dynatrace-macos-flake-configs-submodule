return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    -- NOTE: The log_level is in `opts.opts`
    opts = {
      log_level = "DEBUG", -- or "TRACE"
    },
    -- Route every interaction through the Claude Code ACP adapter. It spawns
    -- the `claude-agent-acp` bridge and authenticates against the Claude
    -- subscription via $CLAUDE_CODE_OAUTH_TOKEN (mint one with `claude setup-token`).
    -- No token is stored here; the adapter reads it from the environment.
    interactions = {
      chat = { adapter = "claude_code" },
      inline = { adapter = "claude_code" },
      cmd = { adapter = "claude_code" },
    },
  },
}
