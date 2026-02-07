--------------------------------------------------------------------------------
--                             Completion Engine                              --
--------------------------------------------------------------------------------
-- local safe_jump = function(direction)
--   local ls = require "luasnip"
--   local current_node = ls.session.current_nodes[vim.api.nvim_get_current_buf()]
--   local snippet = current_node.parent.snippet
--   local total_nodes = #snippet.nodes
--
--   if direction == 1 and ls.jumpable(direction) and current_node.next.pos < (total_nodes-1) then
--     ls.jump(direction)
--   elseif direction == -1 and jumpable(direction) then
--     ls.jump(direction)
--   end
-- end

local check_back_space = function()
  local col = vim.fn.col '.' - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
end
return {
  {
    -- completion engine 'cmp' only
    "hrsh7th/nvim-cmp",
    event = "VeryLazy",
    config = function()
      local cmp = require("cmp")
      local types = require('cmp.types')
      local select_opts = { behavior = cmp.SelectBehavior.Select }
      cmp.setup({
        ---enabled = true,
        --performance = {
        --debounce
        --}
        snippet = {
          -- the snippet.expand function integrates snippet managers by querying them
          expand = function(args)                    -- args: cmp.SnippetExpansionParams (defines how nvim-cmp integrates with snippet engine)
            require("luasnip").lsp_expand(args.body) -- inject luasnip snippets
          end,
        },
        sorting = {
          -- final_score = orig_score + ((#sources - (source_index - 1)) * sorting.priority_weight)
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            --require "cmp-under-comparator".under,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        -- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/mapping.lua
        mapping = cmp.mapping.preset.insert({
          -- ["<Tab>"] = function() -- DOES NOT WORK WITH TMUX /WEZTERM SETUP FOR UNKNOWN REASON
          --    cmp.select_next_item({behavior=cmp.SelectBehavior.Select}) --cmp.mapping.select_prev_item(),
          -- end,
          -- Contextual mappings for the nvim-cmp floating pop-up window
          ["<C-n>"] = function()
            if require 'luasnip'.choice_active() then
              vim.notify("Changing choice")
              require "luasnip".change_choice(1)
            elseif cmp.visible() then
              vim.notify("nvim-cmp selecting next item")
              cmp.select_next_item(select_opts)
            else
              vim.notify("nvim-cmp triggering completion")
              cmp.complete()
            end
          end,
          ["<C-e>"] = function()
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert })
          end,
          ["<C-b>"] = function(fallback)
            -- if require 'luasnip'.choice_active() then
            require "luasnip".change_choice(-1)
            -- else
            --   cmp.select_prev_item(select_opts)
            -- end
          end,

          ["<C-y>"] = function(fallback)
            local ls = require 'luasnip'
            if ls.choice_active() then
              -- When choice is active, jump forward to finalize the selection
              if ls.jumpable(1) then
                ls.jump(1)
              else
                fallback()
              end
            else
              cmp.confirm({
                -- behavior = cmp.ConfirmBehavior.Insert,
                select = true,
              })
            end
          end,
          --["<C-o>"] = cmp.mapping.complete(select_opts), -- overrides builtin <C-o> which enteres normal mode for one command and switches back. this is control + space on VS Code (triggers the autocompletion menu)
          -- ["<C-o>"] = function()
          --   if cmp.visible_docs() then
          --     cmp.close_docs()
          --   else
          --     cmp.open_docs()
          --   end
          -- end,
          ["<C-f>"] = function()
            local ls = require "luasnip"
            if ls.jumpable(1) then
              ls.jump(1)
            end
          end,
          ["<C-d>"] = function()
            local ls = require "luasnip"
            if ls.jumpable(-1) then
              ls.jump(-1)
            end
          end
          -- ["<CR>"] = function()
          --   cmp.mapping.confirm({
          --     behavior = cmp.ConfirmBehavior.Insert,
          --     select = false, -- Do not auto select first item
          --   })
          -- end,
          -- ["<C-s>"] = cmpcomplete({ reason = cmp.ContextReason.Auto }),
          -- ["<C-a>"] = cmpcomplete({ reason = cmp.ContextReason.Auto }),
          -- ["<ALT-r>"] = cmp.mapping.complete({ reason = cmp.ContextReason.Auto }),
        }),

        -- preferred way to set keymaps within config function scope dynamically for better comments, explicit mode
        -- Opens completion menu for suggestions
        vim.api.nvim_set_keymap('i', '<C-x>', '',
          {
            callback = function()
              local cmp = require("cmp")
              if cmp.visible() then
                require("notify")("visible")
                cmp.abort()
              else
                require("notify")("not visible")
                cmp.complete() -- query completion engine for suggestions
              end
            end,
            desc =
            "Toggle nvim-cmp completion menu for suggestions from sources."
          }),

        -- Format of what is shown in pop-up selection menu using lspkind
        formatting = {
          format = require("lspkind").cmp_format({
            with_text = true,
            menu = {
              buffer = "[buf]",
              nvim_lsp = "[LSP]",
              path = "[path]",
            },
          }),
        },
        completion = {
          -- adds autocompletion suggestions menu while typing
          keyword_length = 3, -- num of keystrokes or chars required to trigger suggestions
          --keyword_pattern = ".*",
          completeopt = "menu,menuone,noselect",
        },
        --views = { -- what does this do?
        --  entries = "custom",
        --},
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        sources = { -- view sources attached to buffer :CmpStatus
          -- bottlenecks for slugging neovim behavior can be found here
          -- lua table with name prop whose value is id of plugin that provides data
          -- Order also defines order (weight) in completion results, whereby top comes first
          -- This is how you can influence order of popup completion menu float
          -- final_score = orig_score + ((#sources - (source_index - 1)) * sorting.priority_weight)
          -- see help: sources[n].priority sources[n].name sources[n].option
          -- group_index is a mutually-exclusive setting (if >0 for group_index=1, then all in 2 will not be shown)
          { -- a contributing culprit to slow typing /sluggish in typescript and markdown filetypes
            name = "nvim_lsp",
            group_index = 1,
            priority = 10,
            --option = { keyword_length = 0 }, -- possible reason for sluggish behavior, but also slow LSPs themselves
            --entry_filter = function(entry, context)
            --  --return require('cmp.types').lsp.CompleteionItemKind[entry:get_kind()] ~= 'KeepingHereAsExample'
            --  return true
            --end
          },
          { name = "lazydev", group_index = 1, priority = 9 },
          { name = "nvim_lsp_signature_help", group_index = 1, priority = 8, option = { keyword_length = 0 } },
          { -- Ruled out as culprit for slow typing in markdown and typescript filetypes
            name = "luasnip",
            group_index = 1,
            priority = 5,
            option = { keyword_length = 1 },
            entry_filter =
                function(entry, context)
                  return true
                end
          },
          { name = "org" },
          { name = "path",                    group_index = 1, priority = 3 },
          { name = "buffer",                  group_index = 1, priority = 2, option = { keyword_length = 2 } }

          -- { name = 'nvim_lsp' },
          -- { name = 'vsnip' }, -- For vsnip users.
          -- { name = 'luasnip' }, -- For luasnip users.
          -- { name = 'ultisnips' }, -- For ultisnips users.
          -- { name = 'snippy' }, -- For snippy users.
        },
        experimental = {
          ghost_text = false, -- true might have caused glitches
        },
      })
    end,
    dependencies = {
      { "onsails/lspkind.nvim" },
      { "L3MON4D3/LuaSnip" },
      { "saadparwaiz1/cmp_luasnip" }, -- "A completion 'source' adapter for nvim-cmp" Will integrate choice nodes with https://github.com/saadparwaiz1/cmp_luasnip/issues/43

      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },      -- source for file system paths
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      { "hrsh7th/cmp-nvim-lua" },     --, after = 'nvim-cmp'
      { "hrsh7th/cmp-buffer" },       --, after="cmp-nvim-lua" -- already had it
      { "hrsh7th/cmp-nvim-lsp" },     -- new

      { "hrsh7th/cmp-nvim-lua" },     -- lua NEW
      { "saadparwaiz1/cmp_luasnip" }, -- for autocompletion
      { "onsails/lspkind.nvim" },     -- vs-code like pictograms,
      { "folke/lazydev.nvim" },
    }
  },
  { import = "plugins.nvim-cmp.lua" }
}
