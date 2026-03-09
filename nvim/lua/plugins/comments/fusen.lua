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

    -- Custom fusen marks picker with annotation as quickfix text
    vim.keymap.set("n", "<leader>pm", function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local finders = require("telescope.finders")
      local pickers = require("telescope.pickers")
      local conf = require("telescope.config").values
      local entry_display = require("telescope.pickers.entry_display")
      local previewers = require("telescope.previewers")
      
      local marks = require("fusen.marks")
      local fusen_config = require("fusen.config").get()
      local all_marks = marks.get_marks()
      
      if #all_marks == 0 then
        vim.notify("No marks found", vim.log.levels.INFO)
        return
      end
      
      table.sort(all_marks, function(a, b)
        if a.file == b.file then
          return a.line < b.line
        end
        return a.file < b.file
      end)
      
      local displayer = entry_display.create({
        separator = " ",
        items = {
          { width = 3 },
          { width = 40 },
          { width = 5 },
          { remaining = true },
        },
      })
      
      local function make_display(entry)
        local mark = entry.value
        return displayer({
          { fusen_config.mark.icon, fusen_config.mark.hl_group },
          { mark.annotation or "(no annotation)", "TelescopeResultsComment" },
          { tostring(mark.line), "TelescopeResultsNumber" },
          { vim.fn.fnamemodify(mark.file, ":."), "TelescopeResultsIdentifier" },
        })
      end
      
      pickers.new({}, {
        prompt_title = "Fusen Marks",
        finder = finders.new_table({
          results = all_marks,
          entry_maker = function(mark)
            return {
              value = mark,
              display = make_display,
              ordinal = string.format("%s:%d %s", mark.file, mark.line, mark.annotation or ""),
              filename = mark.file,
              lnum = mark.line,
              col = 1,
              text = mark.annotation or "",
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_buffer_previewer({
          title = "Mark Preview",
          get_buffer_by_name = function(_, entry)
            return entry.filename
          end,
          define_preview = function(self, entry, status)
            local bufnr = self.state.bufnr
            local mark = entry.value
            
            conf.buffer_previewer_maker(entry.filename, bufnr, {
              bufname = self.state.bufname,
              winid = status.preview_win,
            })
            
            vim.defer_fn(function()
              if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_win_is_valid(status.preview_win) then
                local line_count = vim.api.nvim_buf_line_count(bufnr)
                local target_line = math.min(mark.line, line_count)
                
                if target_line > 0 and target_line <= line_count then
                  vim.api.nvim_win_call(status.preview_win, function()
                    pcall(vim.fn.clearmatches)
                    vim.fn.matchadd("IncSearch", "\\%" .. target_line .. "l", 10)
                  end)
                  
                  pcall(vim.api.nvim_win_set_cursor, status.preview_win, { target_line, 0 })
                  vim.api.nvim_win_call(status.preview_win, function()
                    vim.cmd("normal! zz")
                  end)
                end
              end
            end, 100)
          end,
        }),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              vim.cmd(string.format("edit +%d %s", selection.lnum, selection.filename))
            end
          end)
          
          -- Custom <C-q> to use annotation as quickfix text
          local send_to_qf = function()
            local picker = action_state.get_current_picker(prompt_bufnr)
            local manager = picker.manager
            local selections = picker:get_multi_selection()
            
            local qf_entries = {}
            if #selections > 0 then
              -- Send only explicitly selected items
              for _, selection in ipairs(selections) do
                table.insert(qf_entries, {
                  filename = selection.filename,
                  lnum = selection.lnum,
                  col = selection.col or 1,
                  text = selection.text,
                })
              end
            else
              -- Send all filtered items (current picker results)
              for entry in manager:iter() do
                table.insert(qf_entries, {
                  filename = entry.filename,
                  lnum = entry.lnum,
                  col = entry.col or 1,
                  text = entry.text,
                })
              end
            end
            
            if #qf_entries > 0 then
              vim.fn.setqflist(qf_entries, 'r')
              actions.close(prompt_bufnr)
              vim.cmd('copen')
            else
              vim.notify('No entries to send to quickfix', vim.log.levels.WARN)
            end
          end
          
          map('i', '<C-q>', send_to_qf)
          map('n', '<C-q>', send_to_qf)
          
          -- Delete mark functionality
          local delete_mark = function()
            local selection = action_state.get_selected_entry()
            if selection then
              local bufnr = nil
              for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(buf_id) then
                  local buf_name = vim.api.nvim_buf_get_name(buf_id)
                  if buf_name == selection.value.file then
                    bufnr = buf_id
                    break
                  end
                end
              end
              
              if bufnr then
                marks.remove_mark(bufnr, selection.value.line)
                local ui = require("fusen.ui")
                ui.refresh_all_buffers()
                local storage = require("fusen.storage")
                storage.save()
                vim.notify(
                  string.format("Removed mark at %s:%d", selection.value.file, selection.value.line),
                  vim.log.levels.INFO
                )
                
                actions.close(prompt_bufnr)
                vim.schedule(function()
                  vim.cmd("normal! <leader>pm")
                end)
              else
                vim.notify(string.format("Buffer not found for %s", selection.value.file), vim.log.levels.WARN)
              end
            end
          end
          
          local telescope_config = fusen_config.telescope or {}
          local telescope_keymaps = telescope_config.keymaps or {}
          local delete_key_insert = telescope_keymaps.delete_mark_insert or "<C-d>"
          local delete_key_normal = telescope_keymaps.delete_mark_normal or "<C-d>"
          
          map("i", delete_key_insert, delete_mark)
          map("n", delete_key_normal, delete_mark)
          
          return true
        end,
      }):find()
    end, { desc = "Pick (fusen) marks" })

    require('fusen').setup(opts)
  end
}
