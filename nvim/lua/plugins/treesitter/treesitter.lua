-- Locate nvim-treesitter (and its grammar pack) supplied by the Nix
-- wrapper via wlib's `specs.nvim-treesitter` (see modules/neovim/
-- flake.nix). The wrapper installs both as pack plugins:
--
--   pack/<vendor>/start/nvim-treesitter/         -- plugin source
--   pack/<vendor>/start/COLLATED_TS_GRAMMARS/    -- parser/*.so + queries
--
-- The grammars are a sibling pack plugin because modern nvim-treesitter
-- (main branch / v1.x) no longer bundles parsers in-tree. Neovim's pack
-- auto-loader puts the start/* dirs on rtp, but lazy.nvim aggressively
-- normalises rtp during startup and will (a) clone its own copy of
-- nvim-treesitter unless `dir =` points at the wrapper path, and
-- (b) leave the grammar-pack dir off rtp because no lazy spec names it.
--
-- Algebraic shape:
--   find_pack_plugin : Name -> Maybe Path
--
-- Plain English: scan every entry in &packpath for
-- `pack/*/start/<name>` and return the first hit. nil if not present
-- (e.g. when running this config outside the Nix wrapper, in which
-- case lazy falls back to cloning nvim-treesitter and grammars must be
-- installed via `:TSInstall`).
local function glob_first_dir(pattern)
  for _, hit in ipairs(vim.fn.glob(pattern, false, true)) do
    if vim.fn.isdirectory(hit) == 1 then return hit end
  end
  return nil
end

local function find_pack_plugin(name)
  -- 1. Standard: anywhere on &packpath under pack/*/start/<name>.
  for _, base in ipairs(vim.split(vim.o.packpath, ',')) do
    if base ~= '' then
      local hit = glob_first_dir(base .. '/pack/*/start/' .. name)
      if hit then return hit end
    end
  end
  -- 2. wlib / nixpkgs neovim wrapper fallback. The wrapper script execs
  -- into the unwrapped binary, so vim.v.progpath points at the *base*
  -- store path (no nvim-packdir). The wrapper exports
  --   NVIM_SYSTEM_RPLUGIN_MANIFEST=<wrapper-prefix>/nvim-rplugin.vim
  -- which gives us the wrapper prefix; its sibling `nvim-packdir/`
  -- holds the actual pack tree (start/<plugin>, opt/<plugin>).
  local manifest = vim.env.NVIM_SYSTEM_RPLUGIN_MANIFEST
  if manifest and manifest ~= '' then
    local wrapper_prefix = vim.fn.fnamemodify(manifest, ':h')
    local hit = glob_first_dir(wrapper_prefix .. '/nvim-packdir/pack/*/start/' .. name)
    if hit then return hit end
  end
  -- 3. Last resort: anything currently on rtp whose basename matches.
  for _, p in ipairs(vim.api.nvim_list_runtime_paths()) do
    if vim.fn.fnamemodify(p, ':t') == name and vim.fn.isdirectory(p) == 1 then
      return p
    end
  end
  return nil
end

local nvim_ts_dir = find_pack_plugin('nvim-treesitter')
local grammars_dir = find_pack_plugin('COLLATED_TS_GRAMMARS')

-- Force the grammar pack onto rtp so vim.treesitter.language.add can
-- find `parser/<lang>.so`. Prepend so it wins over any stale entries.
if grammars_dir then
  vim.opt.runtimepath:prepend(grammars_dir)
end

return
{
  --{ import = "plugins.treesitter.treesitter-custom-queries" },
  {
    "nvim-treesitter/nvim-treesitter",
    dir = nvim_ts_dir,
    lazy = false,
    enable = true,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      --{ "nvim-treesitter/nvim-tree-docs" },
    },
    keys = {
    },
    config = function()
      -- Modern nvim-treesitter (v1.0+) works automatically when parsers are installed
      -- No setup() call needed - highlighting, indentation, etc. work out of the box
      -- Just install parsers with :TSInstall <language>

      -- The old APIs are removed:
      -- - nvim-treesitter.configs (removed)
      -- - require('nvim-treesitter.parsers').get_parser_configs() (removed)
      -- - Manual parser configuration (no longer needed)

      -- Modern treesitter automatically handles:
      -- ✓ TSX/JSX files (via typescript and tsx parsers)
      -- ✓ Syntax highlighting
      -- ✓ Indentation
      -- ✓ Folding
      -- ✓ Incremental selection

      -- To install parsers: :TSInstall javascript typescript tsx python lua
      -- To update parsers: :TSUpdate
      -- To check status: :TSInstallInfo
      
      -- Folds coupled to treesitter parser availability.
      --
      -- Algebraic shape:
      --   has_ts_parser : Buffer -> Bool
      --   apply_ts_folds : Buffer -> IO ()
      --
      -- Plain English: when a buffer's filetype has a treesitter parser
      -- registered (i.e. nvim-treesitter installed a grammar for it),
      -- enable folds buffer-locally using treesitter's foldexpr. Buffers
      -- without a parser keep Neovim's default fold behaviour, so we
      -- never set a foldexpr that would error on evaluation.
      --
      -- Sensible defaults:
      --   foldenable    = true   (folds active)
      --   foldlevel     = 99     (everything open on entry, no surprise folding)
      --   foldlevelstart= 99     (same, for new windows)
      --   foldmethod    = expr   (delegated to treesitter)
      --   foldexpr      = vim.treesitter.foldexpr()
      vim.opt.foldlevelstart = 99

      local function has_ts_parser(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == "" then return false end
        local lang = vim.treesitter.language.get_lang(ft) or ft
        local ok, _ = pcall(vim.treesitter.language.add, lang)
        return ok
      end

      -- Fold options are window-local, not buffer-local. We resolve the
      -- window currently displaying `bufnr` and target it explicitly.
      local function apply_ts_folds(bufnr)
        if not has_ts_parser(bufnr) then return end
        local winid = vim.fn.bufwinid(bufnr)
        if winid == -1 then return end
        vim.api.nvim_set_option_value("foldmethod", "expr", { scope = "local", win = winid })
        vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.treesitter.foldexpr()", { scope = "local", win = winid })
        vim.api.nvim_set_option_value("foldenable", true, { scope = "local", win = winid })
        vim.api.nvim_set_option_value("foldlevel", 99, { scope = "local", win = winid })
      end

      local group = vim.api.nvim_create_augroup("treesitter_folds", { clear = true })

      -- `FileType` is the canonical entry point. `BufWinEnter` is the
      -- guard against auto-session: sessionoptions includes "folds" and
      -- "localoptions", so a session restore writes the saved (possibly
      -- foldexpr=0) values back into the buffer *after* our FileType ran.
      -- Re-running on BufWinEnter overrides that. `SessionLoadPost`
      -- catches the bulk restore for already-listed buffers.
      vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
        group = group,
        desc = "Enable treesitter folds for buffers with a registered parser",
        callback = function(args) apply_ts_folds(args.buf) end,
      })

      vim.api.nvim_create_autocmd("SessionLoadPost", {
        group = group,
        desc = "Re-apply treesitter folds after auto-session restore",
        callback = function()
          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) then
              apply_ts_folds(bufnr)
            end
          end
        end,
      })

      -- Lazy.nvim runs this `config` after FileType has already fired for
      -- the buffer opened on the command line. Catch up by applying folds
      -- to every loaded buffer that already has a filetype.
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          apply_ts_folds(bufnr)
        end
      end
    end,
    -- build = "TSUpdate",
    -- {'do': ':TSUpdate'}
    -- see :TSInstallInfo
  },
  --{
  --  "nvim-treesitter/nvim-treesitter-textobjects",
  --  dependencies = {
  --    { 'nvim-treesitter/nvim-treesitter' }-- should load after treesitter
  --  },
  --  config = function(_, opts)
  --    require 'nvim-treesitter.configs'.setup {
  --      textobjects = {
  --        select = {
  --          enable = true,

  --          -- Automatically jump forward to textobj, similar to targets.vim
  --          lookahead = true,

  --          keymaps = {
  --            -- You can use the capture groups defined in textobjects.scm
  --            ["af"] = "@function.outer",
  --            ["if"] = "@function.inner",
  --            ["ac"] = "@class.outer",
  --            -- You can optionally set descriptions to the mappings (used in the desc parameter of
  --            -- nvim_buf_set_keymap) which plugins like which-key display
  --            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
  --            -- You can also use captures from other query groups like `locals.scm`
  --            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
  --          },
  --          -- You can choose the select mode (default is charwise 'v')
  --          --
  --          -- Can also be a function which gets passed a table with the keys
  --          -- * query_string: eg '@function.inner'
  --          -- * method: eg 'v' or 'o'
  --          -- and should return the mode ('v', 'V', or '<c-v>') or a table
  --          -- mapping query_strings to modes.
  --          selection_modes = {
  --            ['@parameter.outer'] = 'v', -- charwise
  --            ['@function.outer'] = 'V',  -- linewise
  --            ['@class.outer'] = '<c-v>', -- blockwise
  --          },
  --          -- If you set this to `true` (default is `false`) then any textobject is
  --          -- extended to include preceding or succeeding whitespace. Succeeding
  --          -- whitespace has priority in order to act similarly to eg the built-in
  --          -- `ap`.
  --          --
  --          -- Can also be a function which gets passed a table with the keys
  --          -- * query_string: eg '@function.inner'
  --          -- * selection_mode: eg 'v'
  --          -- and should return true of false
  --          include_surrounding_whitespace = true,
  --        },
  --      },
  --    }
  --  end
  --}
}
