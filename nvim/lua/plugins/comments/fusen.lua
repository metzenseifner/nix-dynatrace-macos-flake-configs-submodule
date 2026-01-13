return {
  "walkersumida/fusen.nvim",
  version = "*",
  event = "VimEnter",
  opts = {
    save_file = vim.fn.expand("$HOME") .. "/my_fusen_marks.json",
    -- telescope = {
    --   keymaps = {
    --     delete_mark_insert = "<C-x>", -- Custom key for insert mode
    --     delete_mark_normal = "dd",    -- Custom key for normal mode
    --   },
    -- },
    -- Sign column priority
    sign_priority = 10,
    -- Annotation display settings
    annotation_display = {
      mode = "float", -- "eol", "float", "both", "none"
      spacing = 2,    -- Number of spaces before annotation in eol mode

      -- Float window settings
      float = {
        delay = 100,
        border = "rounded",
        max_width = 50,
        max_height = 10,
      },
    },
  },
  config = function(_, opts)
    local has_telescope, telescope = pcall(require, 'telescope')
    if has_telescope then
      local has_extension = pcall(function()
        telescope.load_extension('fusen')
      end)
      if not has_extension then
        vim.notify("Could not load Telescope fusen extension.", vim.log.levels.WARN)
      end
    end

    vim.keymap.set("n", "<leader>pm", ":Telescope fusen marks<CR>", { desc = "Pick (fusen) marks" })

    require('fusen').setup(opts)
  end
}
