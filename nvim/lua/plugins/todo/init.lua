return {
  "arnarg/todotxt.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim" },
  config = function(_, opts)
    -- Create todo.txt directory if it doesn't exist
    local todo_dir = vim.fn.stdpath("data") .. "/todotxt"
    local todo_file = todo_dir .. "/todo.txt"
    
    if vim.fn.isdirectory(todo_dir) == 0 then
      vim.fn.mkdir(todo_dir, "p")
    end
    
    -- Create empty todo.txt if it doesn't exist
    if vim.fn.filereadable(todo_file) == 0 then
      local file = io.open(todo_file, "w")
      if file then
        file:close()
      end
    end
    
    local conf = {
      todo_file = todo_file,
      sidebar = {
        width = 40,
        position = "right", --"left" | "right" | "bottom" | "top", -- default: "right"
      },
      capture = {
        prompt = "> ",
        -- Percentage is percentage of width of the whole editor
        -- Integer is number of columns
        width = "75%", -- | 50,
        position = "50%",
        -- Styled after https://swiftodoapp.com/todotxt-syntax/priority/
        -- With this, if you include any of the below keywords it will
        -- automatically use the associated priority and remove that
        -- keyword from the final task.
        alternative_priority = {
          A = "now",
          B = "next",
          C = "today",
          D = "this week",
          E = "next week",
        },
      },
      -- Highlights used in both capture prompt and tasks sidebar
      -- Each highlight type can be a table with 'fg', 'bg' and 'style'
      -- options or a string referencing an existing highlight group.
      -- highlights = {
      --   project = "Identifier",
      -- }
      highlights = {
        project = {
          fg = "magenta",
          bg = "NONE",
          style = "NONE",
        },
        context = {
          fg = "cyan",
          bg = "NONE",
          style = "NONE",
        },
        date = {
          fg = "NONE",
          bg = "NONE",
          style = "underline",
        },
        done_task = {
          fg = "gray",
          bg = "NONE",
          style = "NONE",
        },
        priorities = {
          A = {
            fg = "red",
            bg = "NONE",
            style = "bold",
          },
          B = {
            fg = "magenta",
            bg = "NONE",
            style = "bold",
          },
          C = {
            fg = "yellow",
            bg = "NONE",
            style = "bold",
          },
          D = {
            fg = "cyan",
            bg = "NONE",
            style = "bold",
          },
        },
      },
      -- Keymap used in sidebar split
      keymap = {
        quit = "q",
        toggle_metadata = "m",
        delete_task = "dd",
        complete_task = "<space>",
        edit_task = "ee",
      },
    }
    vim.keymap.set('n', "<leader><leader>tt", function() require("todotxt-nvim").toggle_task_pane() end,
      { desc = "ToDoTxtTasksToggle Open tasks in pane." })
    vim.keymap.set('n', "<leader><leader>ta", function() require("todotxt-nvim").capture() end,
      { desc = "ToDoTxtCapture Add a task." })
    require("todotxt-nvim").setup(conf)
  end
}
