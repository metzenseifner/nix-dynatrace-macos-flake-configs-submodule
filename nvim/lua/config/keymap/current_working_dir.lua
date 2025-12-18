vim.keymap.set("n", "<leader>cwd",
  function()
    require 'config.functions'.set_current_working_directory_to({ path = buffer_parent_dir })
  end,
  { desc = "Set current working directory to directory." })

vim.keymap.set("n", "<leader>cwdy",
  function()
    local buffer_parent_dir = vim.fn.expand("%:p:h")
    require 'config.functions'.copy(buffer_parent_dir)
    require 'config.functions'.set_current_working_directory_to({ path = buffer_parent_dir })
  end,
  { desc = "Set current working directory to directory." })

-- vim.keymap.set("n", "<leader>scwd",
--   function()
--     local buffer_path = vim.fn.expand("%:p")
--     require 'config.functions'.set_current_working_directory_to_top_dir({ path = buffer_path })
--   end,
--   { desc = "Set current working directory to nearest parent dir with a git repo." })
