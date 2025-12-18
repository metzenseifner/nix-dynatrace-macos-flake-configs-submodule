local M = {}

local default_conf = {
  namespace = vim.api.nvim_create_namespace("live-tests"),
  json_file_name = "jest_test_results.json",
  extra_args = {
    "--testLocationInResults",
    "--json",
    "--outputFile=jest_test_results.json",
  },
  output_buffer_prefix = "out-",
  group =
      vim.api.nvim_create_augroup("joko-autotest", { clear = true })
}

M.setup = function(config)
  config = config or {}
  local conf = vim.tbl_deep_extend("force", {}, default_conf, config) -- force means right takes precedence (right overrides left)

  -- Try and stick to the CTRF Reporter for cross-language support
  -- WIP
  --local parseCTRF = function(data)
  --  local state = {}
  --  -- Iterate stream by line break
  --  for _, line in ipairs(data) do
  --    local decoded = vim.json.decode(line)
  --    if decoded.Action == "run" then
  --      print("run")
  --    elseif decoded.Action == "output" then
  --      if not decoded.Test then
  --        return
  --      end
  --      add_output(state, decoded)
  --    elseif decoded.Action == "pass" or decoded.Action == "fail" then
  --      mark_success(state, decoded)
  --      local test = state.tests[make_key(decoded)]
  --      if test.success then
  --        local text = { "✔︎" }
  --        -- TODO separation of concerns: the what to do from the how to parse
  --        vim.api.nvim_buf_set_extmark(bufnr, ns, test.line, 0, { virt_text = { text } })
  --      end
  --    elseif decoded.Action == "pause" or decoded.Action == "cont" then
  --      -- do nothing
  --    else
  --      error("Failed to handle" .. vim.inspect(data))
  --    end
  --  end

  --  return state -- some structure
  --end

  local parseJestJSON = function(jsonString)
    vim.notify("parseJestJSON received string: " .. jsonString, vim.log.levels.DEBUG)
    local state = { tests = {} }

    local acquire_key = function(decodedTest)
      assert(decodedTest.ancestorTitles,
        "Test object must have ancestorTitles key, but was given: " .. vim.inspect(decodedTest))
      assert(decodedTest.title, "Test object must have title key, but was given: " .. vim.inspect(decodedTest))
      return string.format("%s/%s", table.concat(decodedTest.ancestorTitles, "/"), decodedTest.title)
    end
    -- each item is an object has assertionResults list
    -- of test objects.
    -- Test object: {ancestorTitles == Suite Name, failureMessages, failureDetails, fullName == includes describe name, title, location: {column: 3, line: 16}, status==passed|}
    local add_jest_test_entry_in_state = function(decodedTest)
      state.tests[acquire_key(decodedTest)] = {
        name = decodedTest.title,
        line = decodedTest.location.line - 1,
        column = decodedTest.location.column,
        output = {},
      }
    end
    local add_jest_output = function(decodedTest)
      table.insert(state.tests[acquire_key(decodedTest)].output,
        vim.trim(table.concat(decodedTest.failureMessages, "\n")))
    end
    local add_test_status_to_state = function(decodedTest)
      state.tests[acquire_key(decodedTest)].success = decodedTest.status == "passed"
    end

    --------------------------------------------------------------------------------
    --                             Main Logic (high level)                        --
    --------------------------------------------------------------------------------

    local decoded = vim.json.decode(jsonString)
    vim.notify(vim.inspect(decoded), vim.log.levels.DEBUG)

    --assert(decoded.success, "Decoded JSON must have top-level success key, but was given: ") -- .. vim.inspect(decoded)) --culprit of long messages
    if decoded.testResults then
      for _, decodedTestResults in ipairs(decoded.testResults) do
        for _, decodedTest in ipairs(decodedTestResults.assertionResults) do
          vim.notify("Test Case: " .. decodedTest.title, vim.log.levels.DEBUG)
          add_jest_test_entry_in_state(decodedTest)
          add_jest_output(decodedTest)
          if decodedTest.status == "passed" or decodedTest.status == "failed" then
            add_test_status_to_state(decodedTest)
            -- Here is where TJ Devries mixes the Effect with the pure state creation logic. effect is lsp stuff.
            --local test = state.tests[make_key(decodedTest)]
          else
            error("Failed to handle test " .. vim.inspect(decodedTest))
          end
        end
      end
    else
      vim.notify("Test run itself failed.", vim.log.levels.ERROR)
    end
    vim.notify("Internal Testing State: " .. vim.inspect(state), vim.log.levels.DEBUG)
    return state
  end

  local integrateWithNeovimDiagnostics = function(bufnr, ns, state)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1) -- clear existing
    local failed = {}
    vim.notify("Test Diagnostics got " .. vim.inspect(state), vim.log.levels.DEBUG)
    for testName, testState in pairs(state.tests) do
      if testState.success then
        local text = { "✅ PASS" }
        vim.notify(
          string.format("Exec: vim.api.nvim_buf_set_extmark(%s, %s, %s, 0, { virt_text = { %s } })", bufnr, ns,
            testState.line,
            text), vim.log.levels.DEBUG)
        vim.api.nvim_buf_set_extmark(bufnr, ns, testState.line, 0, { virt_text = { text } })
      else
        table.insert(failed, {
          bufnr = bufnr,
          lnum = testState.line,
          col = testState.column,
          severity = vim.diagnostic.severity.ERROR,
          source = "jest",
          message = "❌ FAIL",
          user_data = {},
        })
      end
    end
    vim.diagnostic.set(ns, bufnr, failed, {})
  end

  --------------------------------------------------------------------------------
  --                           Important Abstraction                            --
  --                    Parameterizes the bufnr and command                     --
  --------------------------------------------------------------------------------
  local attach_to_buffer = function(bufnr, command)
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("joko-automagic", { clear = true }),
      pattern = { "*.ts", "*.tsx" },

      callback = function()
        local acquire_output_buffer = function(input)
          local newbufname = conf.output_buffer_prefix .. input.parent_bufnr
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_name(buf):sub(-string.len(newbufname)) == newbufname then
              return buf
            end
          end
          local newbufnr = vim.api.nvim_create_buf(true, true)
          vim.api.nvim_buf_set_name(newbufnr, newbufname)
          vim.api.nvim_buf_set_option(newbufnr, 'modifiable', true)
          vim.notify(string.format("Output buffer(bufnr: %s, name: %s)", newbufnr, newbufname))

          if input.clear then
            vim.api.nvim_buf_set_lines(newbufnr, 0, -1, false, {})
          end
          -- not sure how to make it readonly for insert mode but allow writing via api
          if input.init_lines then
            for idx, line in ipairs(input.init_lines) do
              vim.api.nvim_buf_set_lines(newbufnr, idx - 1, -1, false, { line })
            end
          end
          return newbufnr
        end

        -- Just make a buffer available. Consider split view
        local test_bufnr = acquire_output_buffer({ parent_bufnr = bufnr, init_lines = { table.concat(command, " ") .. " output:" }, clear = true })

        local write_data_to_buffer = function(_, data)
          if data then
            vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
          end
        end

        --Define how to process stdout ahead of time for now
        local process_stdout = function(_, data)
          --if not data then
          --  return
          --end
          if data then
            vim.api.nvim_buf_set_lines(
              acquire_output_buffer({ parent_bufnr = bufnr, init_lines = { table.concat(command, " ") .. " output:" } }),
              -1, -1, false, data)
          end
        end

        local process_stderr = function(_, data)
          --if not data then
          --  return
          --end
          if data then
            vim.api.nvim_buf_set_lines(
              acquire_output_buffer({ parent_bufnr = bufnr, init_lines = { table.concat(command, " ") .. " output:" } }),
              -1, -1, false, data)
          end
        end


        --|
        -- Start Parsing and push results to Diagnostics API
        --
        -- We can assume that our test output file has been written.
        --|
        local handle_exit = function()
          local testOutputFile = vim.uv.cwd() .. "/" .. conf.json_file_name
          local isOk, result = pcall(vim.fn.readfile, testOutputFile)
          if not isOk then
            vim.notify("Could not read JSON config file at " .. testOutputFile, vim.log.levels.ERROR)
          end
          for _, elem in ipairs(result) do -- expect only 1 elem TODO add check
            vim.notify("Reading Jest Test JSON, got: " .. elem, vim.log.levels.DEBUG)
            local resultState = parseJestJSON(elem)
            integrateWithNeovimDiagnostics(bufnr, conf.namespace, resultState)
          end
        end

        vim.notify("Executing async job: " .. vim.iter(command):join(" "))
        -- Start the async external process (run the command)
        local portable_ok, portable = pcall(require, 'config.portable')
        if portable_ok then
          portable.safe_jobstart(command, {
            stdout_buffered = true, -- buffer by LF
            on_stdout = process_stdout,
            on_stderr = process_stderr,
            on_exit = handle_exit,
          }, "TestRunner")
        else
          -- Fallback if portable module not available
          if type(command) == "table" and #command > 0 then
            if vim.fn.executable(command[1]) == 1 then
              vim.fn.jobstart(command, {
                stdout_buffered = true,
                on_stdout = process_stdout,
                on_stderr = process_stderr,
                on_exit = handle_exit,
              })
            else
              vim.notify("TestRunner: Command not found: " .. command[1], vim.log.levels.WARN)
            end
          end
        end
      end,
    })
    --vim.api.nvim_buf_create_user_command(bufnr, "TestLineDiag", function()
    --  local line = vim.fn.line "." - 1
    --  for _, test in pairs(state.tests) do
    --    if test.line == line then
    --      vim.cmd.new()
    --      vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, test.output)
    --    end
    --  end
    --end, {})
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = conf.group,
      pattern = "*.go",
      callback = function()
        vim.api.nvim_buf_clear_namespace(bufnr, conf.namespace, 0, -1)
      end
    })
  end

  --------------------------------------------------------------------------------
  --                            Function Components                             --
  --------------------------------------------------------------------------------
  --local add_new_test = function(state, entry)
  --  state.tests[make_key(entry)] = {
  --    name = entry.Test,
  --    line = find_test_line(state.bufnr, entry.Test),
  --    output = {},
  --  }
  --end

  --local make_key = function(entry)
  --  assert(entry.Package, "Must have Package:" .. vim.inspect(entry))
  --  assert(entry.Test, "Must have Test:" .. vim.inspect(entry))
  --  return string.format("%s/%s", entry.Package, entry.Test)
  --end

  --local add_output = function(state, entry)
  --  assert(state.tests, vim.inspect(state))
  --  table.insert(state.tests[make_key(entry)].output, vim.trim(entry.Output))
  --end

  --local mark_success = function(state, entry)
  --  state.tests[make_key(entry)].success = entry.Action == "pass"
  --end


  --------------------------------------------------------------------------------
  --           Registers Event Listener Exposes User Command (global)           --
  --           Wraps attach_to_buffer and uses nvim_get_current_buf()           --
  --               to make the buffer ID scalable for any buffer                --
  --------------------------------------------------------------------------------


  vim.api.nvim_create_user_command("TestOnSaveJest", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local isOk, result = pcall(vim.fn.readfile, 'package.json')
    if not isOk then
      vim.notify("Could not read package.json config file at " .. vim.uv.cwd() .. '/package.json', vim.log.levels.ERROR)
    end
    local rawContent = ""
    for _, elem in ipairs(result) do -- expect only 1 elem (if newlines removed) TODO add check
      vim.notify("Reading package.json, got: " .. elem, vim.log.levels.DEBUG)
      rawContent = rawContent .. elem
      --integrateWithNeovimDiagnostics(bufnr, conf.namespace, resultState)
    end
    local decoded_package_json = vim.json.decode(rawContent)
    --local decoded_package_json = vim.json.decode(package_json)
    --local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local finders = require "telescope.finders"
    local sorters = require "telescope.sorters"
    local make_entry = require "telescope.make_entry"
    local pickers = require "telescope.pickers"
    local utils = require "telescope.utils"
    local package_scripts_to_tbl = function(package_scripts)
      local items = {}
      for symbol, script in pairs(package_scripts) do
        table.insert(items, { symbol, script })
      end
      return items
    end

    local entry_maker = function(entry)
      return {
        value = entry,
        display = entry[1],
        ordinal = entry[1],
      }
    end

    local string_to_table = function(value)
      local result = {}
      for token in string.gmatch(value, "[%w%p]+") do
        table.insert(result, token)
      end
      return result
    end

    -- return a new array containing the concatenation of all of its
    -- parameters. Scalar parameters are included in place, and array
    -- parameters have their values shallow-copied to the final array.
    -- Note that userdata and function values are treated as scalar.
    local function array_concat(...)
      local t = {}
      for n = 1, select("#", ...) do
        local arg = select(n, ...)
        if type(arg) == "table" then
          for _, v in ipairs(arg) do
            t[#t + 1] = v
          end
        else
          t[#t + 1] = arg
        end
      end
      return t
    end

    local enter = function(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      local package_script_prefix = { "npm", "exec" }
      local extras = conf.extra_args -- vim.iter(ipairs(conf.extra_args)):totable()
      local defaultCommand = array_concat(package_script_prefix, string_to_table(selection.value[2]), extras,
        { require 'plenary.path'.new(vim.api.nvim_buf_get_name(bufnr)).filename })
      vim.schedule(function()
        vim.split(
          vim.fn.input("command line args: ", vim.iter(defaultCommand):join(" ")), " ")
      end)
      local command = defaultCommand
      attach_to_buffer(bufnr, command)
      actions.close(prompt_bufnr)
    end

    local opts = {
      bufnr = vim.api.nvim_get_current_buf(),
      entry_maker = entry_maker,
      sorter = sorters.get_generic_fuzzy_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        map("i", "<CR>", enter)
        return true
      end,
      --attach_mappings = function(prompt_bufnr)
      --      actions.select_default:replace(function()
    }

    pickers
        .new(opts, {
          prompt_title = "package.json scripts",
          finder = finders.new_table {
            results = package_scripts_to_tbl(decoded_package_json.scripts),
            entry_maker = opts.entry_maker,
          },
          --previewer = conf.qflist_previewer(opts),
          sorter = opts.sorter
          --  tag = "type",
          --  sorter = conf.generic_sorter(opts),
          --},
        })
        :find()
  end, {})


  vim.api.nvim_create_user_command("TestOnSaveManual", function()
    local defaultCommand = { "npx", "jest", "--config", "src/jest.ui.config.js", "--", table.concat(conf.extra_args, ', '),
      vim.fn.expand('%:p:t') }
    --local defaultCommandCTRFReport = { "npm", "exec", "jest", "--", "--testLocationInResults", "--reporters", "default", "--reporters", "ctrf-json-reporter" }
    local command = vim.split(vim.fn.input("command line args: ", vim.iter(defaultCommand):join(" ")), " ")
    attach_to_buffer(vim.api.nvim_get_current_buf(), command)
  end, {})
end

return M
