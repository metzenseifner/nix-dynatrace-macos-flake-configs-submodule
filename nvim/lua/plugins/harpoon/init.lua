return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim"
  },
  keys = {
    -- LazyKeysSpec
    {
      "<leader>ha",
      function()
        local harpoon = require("harpoon")
        harpoon:list():add()
        vim.notify("Added harpoon mark")
      end,
      desc =
      "Add file to Harpoon."
    },
    {
      "<leader>hm",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc =
      "Open Harpoon menu."
    },
    {
      "<C-j>",
      function()
        local harpoon = require("harpoon")
        harpoon:list():next()
        local current = harpoon:list():get(harpoon:list()._index)
        if current then
          vim.notify(string.format("Harpoon [%d]: %s", harpoon:list()._index, current.value))
        end
      end,
      desc =
      "Harpoon cycle to next mark."
    },
    {
      "<C-k>",
      function()
        local harpoon = require("harpoon")
        harpoon:list():prev()
        local current = harpoon:list():get(harpoon:list()._index)
        if current then
          vim.notify(string.format("Harpoon [%d]: %s", harpoon:list()._index, current.value))
        end
      end,
      desc =
      "Harpoon cycle to previous mark."
    },
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup({})
  end,

}
