return {
  "startup-nvim/startup.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim", "nvim-telescope/telescope-file-browser.nvim" },
  config = function()
    local user_bookmarks = vim.g.startup_bookmarks

    local bookmark_texts = { "Bookmarks", "" }
    local user_bookmark_mappings = {}

    if not user_bookmarks then
      user_bookmarks = {}
      bookmark_texts = {}
    end

    for key, file in pairs(user_bookmarks) do
      bookmark_texts[#bookmark_texts + 1] = key .. " " .. file
    end

    for key, file in pairs(user_bookmarks) do
      user_bookmark_mappings[key] = "<cmd>e " .. file .. "<CR>"
    end

    local conf = {
      custom_header = {
        -- "text" -> text that will be displayed
        -- "mapping" -> create mappings for commands that can be used
        -- use mappings.execute_command on the commands to execute
        -- "oldfiles" -> display oldfiles (can be opened with mappings.open_file/open_file_split)
        type = "text",              -- can be mapping or oldfiles
        oldfiles_directory = false, -- if the oldfiles of the current directory should be displayed
        align = "center",           -- "center", "left" or "right"
        fold_section = false,       -- whether to fold or not
        title = "title",            -- title for the folded section
        -- if < 1 fraction of screen width
        -- if > 1 numbers of column
        margin = 5, -- the margin for left or right alignment
        -- type of content depends on `type`
        -- "text" -> a table with string or a function that requires a function that returns a table of strings
        -- "mapping" -> a table with tables in the format:
        -- {
        --   {<displayed_command_name>, <command>, <mapping>}
        --   {<displayed_command_name>, <command>, <mapping>}
        -- }
        -- e.g. {" Find File", "Telescope find_files", "<leader>ff" }
        -- "oldfiles" -> ""
        content = function()
          --require("startup.functions").quote()
          local clock = " " .. os.date "%H:%M"
          local date = " " .. os.date "%d-%m-%y"
          local portable = require('config.portable')
          local process = portable.safe_popen('sprint_supplier', 'r', 'startup_sprint_supplier')
          local stdout = "N/A"
          if process then
            stdout = process:read('*l') or "N/A"
            process:close()
          end
          local sprint = "Sprint: " .. stdout
          local standup_zoom_url =
          "Standup: https://dynatrace.zoom.us/j/91042876298?pwd=OlgXClad7p2MlbMAm2zkgnbcb8VDF4.1"
          return { "startup.nvim", clock, date, sprint, standup_zoom_url }
        end,
        highlight = "String",      -- highlight group in which the section text should be highlighted
        default_color = "#FF0000", -- a hex color that gets used if you don't specify `highlight`
        oldfiles_amount = 5,       -- the amount of oldfiles to be displayed
      },
      my_keystroke_menu = {
        type = "mapping",
        oldfiles_directory = false,
        align = "center",
        fold_section = false,
        title = "Basic Commands",
        margin = 5,
        content = {
          { "Standup", vim.g.jonathans_special_files .. "/standup.org", "s" },
          { "󰍉 List Projects", ":NeovimProjectDiscover", "<leader>pp" },
          { "  List Recent Projects", ":NeovimProjectHistory", "<leader>pph" },
          { "Interviews in Oil", ":Oil " .. vim.g.jonathans_special_files .. "/Team\\ Captain/Interviews\\ -\\ Candidates\\ or\\ Prospective\\ Employees", "i" },
          { "Special Files in Oil", ":Oil " .. vim.g.jonathans_special_files, "f" },
          --{ " Find File", "Telescope find_files", "<leader>ff" },
          --{ "󰍉 Find Word", "Telescope live_grep", "<leader>lg" },
          --{ " Recent Files", "Telescope oldfiles", "<leader>of" },
          --{ " File Browser", "Telescope file_browser", "<leader>fb" },
          { " Colorschemes", "Telescope colorscheme", "<leader>cs" },
          { " New File", "lua require'startup'.new_file()", "<leader>nf" },
        },
        highlight = "String",
        default_color = "",
        oldfiles_amount = 0,
      },
      --recent_projects = {
      --  type = "text",
      --  align = "left",
      --  content = function()
      --    return { "1", "2" }
      --  end,
      --  highlight = "String",
      --},
      recent_files = {              -- https://github.com/max397574/startup.nvim/blob/master/lua/startup/utils.lua#L259
        type = "oldfiles",
        oldfiles_directory = false, -- implies ~ as root
        align = "left",
        fold_section = false,
        title = "Recently Opened",
        margin = 5,
        content = "",
        highlight = "String",
        oldfiles_amount = 10,
      },
      bookmarks = {
        type = "text",
        align = "left",
        margin = 5,
        content = bookmark_texts,
        highlight = "String",
      },
      custom_footer = {
        type = "text",
        oldfiles_directory = false,
        align = "center",
        fold_section = false,
        title = "Footer",
        margin = 5,
        content = { "startup.nvim" },
        highlight = "Number",
        default_color = "",
        oldfiles_amount = 5,
      },
      options = {
        mapping_keys = true, -- display mapping (e.g. <leader>ff)

        -- if < 1 fraction of screen width
        -- if > 1 numbers of column
        cursor_column = 0.25,

        after = function() -- function that gets executed at the end
          require("startup").create_mappings(user_bookmark_mappings)
          require("startup.utils").oldfiles_mappings()
        end,
        empty_lines_between_mappings = true, -- add an empty line between mapping/commands
        disable_statuslines = true,          -- disable status-, buffer- and tablines
        paddings = { 1, 1, 1, 1 },           -- amount of empty lines before each section (must be equal to amount of sections)
      },
      mappings = {
        execute_command = "<CR>",
        open_file = "o",
        open_file_split = "<c-o>",
        open_section = "<TAB>",
        open_help = "?",
      },
      colors = {
        background = "#1f2227",
        folded_section = "#56b6c2", -- the color of folded sections
        -- this can also be changed with the `StartupFoldedSection` highlight group
      },
      parts = { "custom_header", "my_keystroke_menu", "recent_files", "bookmarks" }
    }
    require "startup".setup(conf)
  end
}
