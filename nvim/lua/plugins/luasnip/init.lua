return {
  "L3MON4D3/LuaSnip",
  event = "VeryLazy",
  build = "make install_jsregexp",
  --dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    -- see https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
    ls = require("luasnip")

    ls.filetype_extend("typescript", { "typescriptreact" })
    ls.filetype_extend(
      'typescriptreact',
      { 'javascriptreact', 'typescript', 'javascript' }
    )

    types = require("luasnip.util.types")
    --load_ft_func

    -- don't pass any arguments, luasnip will find the collection because it is
    -- (probably) in rtp.
    --require("luasnip.loaders.from_vscode").lazy_load()
    -- specify the full path...
    require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath('config') .. "/snippets" })
    --require("luasnip.loaders.from_lua").lazy_load({ paths = vim.tbl_extend('force', vim.api.nvim_list_runtime_paths(), {vim.fn.stdpath("config") .. "/snippets,"})})
    require('luasnip.loaders.from_vscode').lazy_load() --for rafamadriz/friendly-snippets


    -- Experiments for dynatrace_from_lua_snippets
    --load_ft_func = require('luasnip_snippets.common.snip_utils').load_ft_func,
    --ft_func = require('luasnip_snippets.common.snip_utils').ft_func,


    --require("luasnip.loaders.from_vscode").load({ paths = vim.fn.stdpath("config") .. "/snippets_vscode" })
    --require("luasnip.loaders.from_snipmate").load({ paths = vim.fn.stdpath("config") .. "/snippets_snipmate" })

    -- useful for quickly editing snippets
    -- require("luasnip.loaders").edit_snippet_files(nil)

    ls.config.set_config({
      cut_selection_keys = "<Tab>",
      -- Remember last snippet
      history = false, -- performance
      -- updates as you type
      update_events = "TextChanged,TextChangedI", -- performance
      -- Autosnippets:
      enable_autosnippets = true,
      -- Crazy Highlights
      ext_opts = {
        [types.choiceNode] = {
          active = {
            virt_text = { { "←", "Error" } },
          },
        },
      },
    })

    -- snippet factory
    local snip = ls.s

    -- formats a node
    local fmt = require("luasnip.extras.fmt").fmt

    -- repeats a node
    local rep = require("luasnip.extras").rep

    local partial = require("luasnip.extras").partial

    -- static text node
    local text = ls.text_node

    -- insert node
    local i = ls.insert_node

    local f = ls.function_node

    local c = ls.choice_node

    local function firstCharToUpperCase(strs, parent_node, user_args)
      return (strs[1][1]:gsub("^%l", string.upper))
    end

    -- snippets are added via ls.add_snippets(filetype, snippets[, opts]), where
    -- opts may specify the `type` of the snippets ("snippets" or "autosnippets",
    -- for snippets that should expand directly after the trigger is typed).
    --
    -- opts can also specify a key. By passing an unique key to each add_snippets, it's possible to reload snippets by
    -- re-`:luafile`ing the file in which they are defined (eg. this one).
    -- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
    local get_file_name = function()
      return vim.fn.expand("%:t:r")
    end
    --vim.keymap.set({ "i", "s" }, "<Tab>", function() -- do not bind tab key in insert mode! caveat is a useful key
    --  if require 'luasnip'.expand_or_jumpable() then
    --    require 'luasnip'.expand_or_jump()
    --  end
    --end, { desc = "Snippet expand key or next argument", silent = true })
  end,
} -- snippet engine used by nvim-cmp. Snippets provide small previews. See capabilities snippetSupport in nvim-lspconfig, nvim-cmp, using LSP CompletionItemSetting.SnippetSupport Property
