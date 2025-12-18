

local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local l = require("luasnip.extras").lambda
local r = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

local module_path = require'config.functions'.get_module_path()

local scandir = require 'plenary.scandir'
local Path = require 'plenary.path'

local M = {}

M.setup = function(opts)
  --local snippets = {
  --all = require("dynatrace_snippets.dynatrace-bogus")
  --}
  --M.apply_snippets(snippets)

  local module_root_dir = Path:new(module_path)
  local files = scandir.scan_dir(tostring(module_root_dir), { depth = 3 })
end

M.apply_snippets = function(snippet_table)
  for filetype, snippets in pairs(snippet_table) do
    require 'luasnip'.add_snippets(filetype, snippets)
  end
end


return M
