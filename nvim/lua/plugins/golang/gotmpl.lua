-- Not working
return {
  "ngynkvn/gotmpl.nvim",
  init = function()
    require 'nvim-treesitter.parsers'.get_parser_configs().gotmpl = {
      install_info = {
        url = "https://github.com/ngalaiko/tree-sitter-go-template",
        files = { "src/parser.c" },
        branch = "main",
      },
      filetype = "gotmpl",
    }
  end,
}
