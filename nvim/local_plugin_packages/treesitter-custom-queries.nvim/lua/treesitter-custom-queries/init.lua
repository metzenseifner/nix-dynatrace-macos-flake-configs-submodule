local M = {}
-- TODO something
M.query_todo = function()
  vim.notify("QUERY TODO for fu for funn")
  local query_string = '((comment)) @comment (#match? @comment "TODO")'
  local parser = require("nvim-treesitter.parsers").get_parser()
  vim.treesitter.query.parse(parser:lang(), query_string)
  local ok, query = pcall(vim.treesitter.query.parse, parser:lang(), query_string)
  if not ok then
    vim.notify("Could not parse query", vim.log.levels.ERROR)
    return
  end
  local tree = parser:parse()[1]
  local qf_list = {}
  for id, node in query:iter_captures(tree:root(), 0) do
    local name = query.captures[id]
    local type = node:type() -- type of captured node
    local text = vim.treesitter.get_node_text(node, 0)
    local lnum, col = node:range()
    table.insert(qf_list, {
      bufnr = vim.api.nvim_get_current_buf(),
      text = text,
      lnum = lnum + 1,
      col = col + 1
    })
  end
  vim.fn.setqflist(qf_list)
  vim.cmd.copen()
end

M.query_comment = function(keyword)
  local query_string = string.format('(((comment)+ @comment) (#match? @comment %s))', keyword)
  local parser = require("nvim-treesitter.parsers").get_parser()
  vim.treesitter.query.parse(parser:lang(), query_string)
  local ok, query = pcall(vim.treesitter.query.parse, parser:lang(), query_string)
  if not ok then
    vim.notify("Could not parse query", vim.log.levels.ERROR)
    return
  end
  local tree = parser:parse()[1]
  local qf_list = {}
  for id, node in query:iter_captures(tree:root(), 0) do
    local name = query.captures[id]
    local type = node:type() -- type of captured node
    local text = vim.treesitter.get_node_text(node, 0)
    local lnum, col = node:range()
    table.insert(qf_list, {
      bufnr = vim.api.nvim_get_current_buf(),
      text = text,
      lnum = lnum + 1,
      col = col + 1
    })
  end
  vim.fn.setqflist(qf_list)
  vim.cmd.copen()
end

return M
