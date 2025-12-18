--------------------------------------------------------------------------------
--                             Prerequisite Check                             --
--                   Safely check for telescope dependency                    --
--------------------------------------------------------------------------------
local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This extension requires telescope.nvim')
end

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values

local M = {}

M.list_files = function(opts)
  opts = opts or {}
  local path = opts.path or vim.fn.input('Path: ', '', 'dir')

  local files = {}
  
  -- Check if ls command is available
  if vim.fn.executable('ls') == 1 then
    local ok, handle = pcall(io.popen, 'ls -p ' .. path .. ' | grep -v /')
    if ok and handle then
      local result = handle:read('*a')
      handle:close()
      
      for file in result:gmatch("[^\r\n]+") do
        table.insert(files, path .. '/' .. file)
      end
    else
      vim.notify("Failed to list files in: " .. path, vim.log.levels.WARN)
    end
  else
    -- Fallback: use vim.fn.glob
    local pattern = path .. '/*'
    for _, file in ipairs(vim.fn.glob(pattern, false, true)) do
      if vim.fn.isdirectory(file) == 0 then -- Only files, not directories
        table.insert(files, file)
      end
    end
  end

  --------------------------------------------------------------------------------
  --                                   Picker                                   --
  --------------------------------------------------------------------------------
  pickers.new(opts, {
    prompt_title = 'Files in ' .. path,
    --------------------------------------------------------------------------------
    --                                   Finder                                   --
    --                                  supplier                                  --
    --------------------------------------------------------------------------------
    finder = finders.new_table {
      results = files,
    },
    --------------------------------------------------------------------------------
    --                                   Sorter                                   --
    --                                  optional                                  --
    --------------------------------------------------------------------------------
    sorter = conf.generic_sorter(opts),
    --------------------------------------------------------------------------------
    --                                   Action                                   --
    --------------------------------------------------------------------------------
    attach_mappings = function(prompt_bufnr, map)
      --------------------------------------------------------------------------------
      --               select_default abstracts main action keystroke               --
      --------------------------------------------------------------------------------
      actions.select_default:replace(function()
        -- Close the telescope window/prompt
        actions.close(prompt_bufnr)
        -- Use action_state to get the last known state of the action
        local selection = action_state.get_selected_entry()
        -- Executable to cause effect
        vim.cmd('edit ' .. selection[1])
      end)
      --------------------------------------------------------------------------------
      --                               Other Keymaps                                --
      --------------------------------------------------------------------------------
      map("i", "<UP>", actions.move_selection_next(prompt_bufnr))
      map("i", "<DOWN>", actions.move_selection_previous(prompt_bufnr))

      -- attach_mappings function MUST return true
      return true
    end,
  }):find()
end

return telescope.register_extension {
  exports = {
    list_files = M.list_files,
  },
}
--------------------------------------------------------------------------------
--                         Movement in Prompt Window                          --
--------------------------------------------------------------------------------

-- actions.move_selection_next(prompt_bufnr)
-- actions.move_selection_previous(prompt_bufnr)
