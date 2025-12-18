-- 1. The "Vim API" inherited from Vim: Ex-commands and builtin-functions as
-- well as user-functions in Vimscript. These are accessed through vim.cmd()
-- and vim.fn respectively
local ls = require("luasnip")
ls.setup_snip_env()
local ms = ls.multi_snippet

local sn = ls.snippetNode
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local telescope = require("telescope.builtin")


local function telescope_choices(prompt, choices)
  return f(function(_, snip)
    local choice = vim.fn.input(prompt .. ": ")
    return choice
  end, {})
end
return {
  s("merge-tables", fmt([[
    -- recursive merge
    vim.tbl_deep_extend("<merge_strategy>", <table1>, <table2>)
  ]],
    { merge_strategy = d(1, function()
      return sn()
     {  t"force",  t"keep",  t"error" }
    end, {}), table1 = i(2), table2 =
    i(3) }, { delimiters = "<>" })),
  s(":", fmt([[
    -- This executes an Ex-command as opposed to a builtin-function
    -- :help Ex-commands
    vim.cmd(<command>)
  ]], { command = i(1) }, { delimiters = "<>" })),
  s("vim.fn", fmt([[
    -- This executes a built-in function as opposed to Ex-command
    -- :help function-list
    vim.fn(<value>);
  ]], { value = i(1, "expand('~')") }, { delimiters = "<>" })),
  --  WARNING DO NOT LEAVE ENABLED or else the a and b keys in insert mode will behavior strangely!
  --  ms({
  -- 	{trig = "a", condition = function(ltc) return ltc ~= "a" end, snippetType = "autosnippet"},
  -- 	{trig = "b", condition = function(ltc) return ltc ~= "b" end},
  -- 	"c"
  -- }, {t"a or b"}),
  --  ms({"a", "b"}, {t"a or b"})
}
