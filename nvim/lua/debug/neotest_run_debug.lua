-- Debug helper for understanding why :Neotest run fails
local M = {}

function M.debug_run()
  local neotest = require("neotest")
  local file = vim.fn.expand("%:p")
  
  print("=== Debugging Neotest Run ===")
  print("Current file: " .. file)
  print("Current line: " .. vim.fn.line("."))
  
  -- Try to get nearest test
  local success, tree = pcall(neotest.run.get_tree_from_nearest, vim.fn.getpos("."))
  
  if success and tree then
    local data = tree:data()
    print("✅ Found nearest test:")
    print("   Type: " .. data.type)
    print("   Name: " .. data.name)
    print("   Path: " .. data.path)
    print("   Range: " .. vim.inspect(data.range))
  else
    print("❌ No test found")
    print("   Error: " .. tostring(tree))
    
    -- Check if file is in tree
    local all_positions = neotest.state.positions(file)
    if all_positions then
      print("✅ File has positions in state")
      local count = 0
      for _, _ in all_positions:iter() do
        count = count + 1
      end
      print("   Total nodes: " .. count)
    else
      print("❌ File has NO positions in state")
    end
  end
end

return M
