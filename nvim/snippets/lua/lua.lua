local func_template_sample = [[
-- this does something
-- @param param any
function name(param)
  function body
 end
]]

local func_template = [[
-- {desc}
-- {dynamic}
local {symbol} = function({params})
  {body}
end
]]

return {
  s("func", fmt(func_template, {
    desc = i(1, "this does some function"),
    dynamic = d(5, function(values)
      local param_str = values[1][1]
      param_str = param_str:gsub(" ", "")
      if param_str == "" then
        return sn(nil, { t("") })
      end
      local params = vim.split(param_str, ",")
      local nodes = {}
      for idx, param in ipairs(params) do
        table.insert(nodes, sn(idx, fmt('\n\n-- @param {} {} {}', { t(param), i(1, 'any'), i(2, 'description') })))
      end
      return sn(nil, nodes)
      -- local doc_comments = {""}
      -- for _, param in ipairs(params) do
      --   table.insert(doc_comments, string.format("-- @param %s any <some description>", param))
      -- end
      -- return doc_comments
    end, { 3 }),
    symbol = i(2, 'name'),
    params = i(3),
    body = i(4)
  })),


  s({ trig = "M|module", regTrig = true, wordtrig = false },
    fmt([[
    local [mod] = {}
    return [mod]
  ]], { mod = f(function(_, snip) return snip.captures[1] end) }, { delimiters = "[]", repeat_duplicates = true })),
  s({ trig = "conf|opts", regTrig = true, wordTrig = true },
    fmt([[
        opts = opts or {}
        local config = vim.tbl_deep_extend("force", {}, default_config, opts) -- force means right takes precedence (right overrides left)
        ]], {}, { delimiters = "<>" })),

  s("module_template", fmt([[
    local M = {}

    M.setup = function(opts)
      print("Options: ", opts)
    end

    M.example = function()
      print("hello")
    end

    return M
  ]], {}, { delimiters = "<>" })),

  s("autocmd", fmt([[
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("ls", { clear = true }),
      pattern = {
        "api/actions/*.test.ts",
        "api/public/*.spec.ts",
        "api/actions/*.test.ts",
        "api/public/*.spec.ts",
      },
      callback = function()
      end
    })
  ]], {}, { delimiters = "<>" })),

  s("autocmd-bufnr-file-match-example", fmt([[
    vim.api.nvim_create_autocmd("BufWritePost", {
       group = vim.api.nvim_create_augroup('testjunk', {clear=true}),
       pattern = '*',
       callback = function()
           local data = {
               buf = vim.fn.expand("<abuf>"),
               file = vim.fn.expand("<afile>"),
               match = vim.fn.expand("<amatch>"),
           }
           vim.schedule(function()
               print(vim.inspect(data))
           end)
       end
    })
  ]], {}, { delimiters = "[]" })),

}
