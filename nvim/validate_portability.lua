#!/usr/bin/env nvim -l
-- Portability validation script for Neovim config
-- Usage: nvim -l validate_portability.lua

local portable = require('config.portable')

print("🔍 Neovim Config Portability Validation")
print("=" .. string.rep("=", 40))

-- Test portable module functionality
print("\n📦 Testing portable module...")
local test_passed = 0
local test_total = 0

-- Test 1: safe_keymap function exists
test_total = test_total + 1
if type(portable.safe_keymap) == "function" then
  print("✅ safe_keymap function available")
  test_passed = test_passed + 1
else
  print("❌ safe_keymap function missing")
end

-- Test 2: safe_system function exists
test_total = test_total + 1
if type(portable.safe_system) == "function" then
  print("✅ safe_system function available")
  test_passed = test_passed + 1
else
  print("❌ safe_system function missing")
end

-- Test 3: safe_jobstart function exists
test_total = test_total + 1
if type(portable.safe_jobstart) == "function" then
  print("✅ safe_jobstart function available")
  test_passed = test_passed + 1
else
  print("❌ safe_jobstart function missing")
end

-- Test 4: Test with non-existent executable
test_total = test_total + 1
local result = portable.safe_system("definitely-not-a-real-command --version", "validation-test")
if result == "" then
  print("✅ Safe handling of missing executables")
  test_passed = test_passed + 1
else
  print("❌ Failed to handle missing executable safely")
end

-- Test 5: Check common executables and report status
print("\n🔧 Checking external tool availability...")

local common_tools = {
  "git", "date", "yq", "curl", "ls", "grep",
  "xdg-open", "open", "explorer", "gio"
}

local available_tools = {}
local missing_tools = {}

for _, tool in ipairs(common_tools) do
  if portable.has(tool) then
    table.insert(available_tools, tool)
  else
    table.insert(missing_tools, tool)
  end
end

print(string.format("✅ Available tools (%d): %s", #available_tools, table.concat(available_tools, ", ")))
print(string.format("⚠️  Missing tools (%d): %s", #missing_tools, table.concat(missing_tools, ", ")))

-- Test 6: Date utils functionality
print("\n📅 Testing date utilities...")
test_total = test_total + 1
local date_utils_ok, date_utils = pcall(require, 'date_utils')
if date_utils_ok and type(date_utils.timestamp) == "function" then
  local timestamp = date_utils.timestamp()
  if timestamp and timestamp ~= "" then
    print("✅ Date utilities working: " .. timestamp)
    test_passed = test_passed + 1
  else
    print("❌ Date utilities not producing output")
  end
else
  print("❌ Date utilities module failed to load")
end

-- Test 7: Keymap loading
print("\n⌨️  Testing keymap loading...")
test_total = test_total + 1
local keymap_ok = pcall(require, 'config.keymap')
if keymap_ok then
  print("✅ Keymap configuration loads successfully (no Mapper dependency)")
  test_passed = test_passed + 1
else
  print("❌ Keymap configuration failed to load")
end

-- Summary
print("\n" .. string.rep("=", 50))
print(string.format("📊 Test Results: %d/%d passed", test_passed, test_total))

if test_passed == test_total then
  print("🎉 All portability tests passed! Your config should work on any system.")
  os.exit(0)
else
  print("⚠️  Some tests failed. Check the output above for issues.")
  os.exit(1)
end