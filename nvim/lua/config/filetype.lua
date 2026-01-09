-- Filename: filetype.lua
-- Last Change: Wed, 25 Oct 2023 - 05:49

-- lua file detection feature:
-- https://github.com/neovim/neovim/pull/16600#issuecomment-990409210

-- filetype.lua is sourced before filetype.vim so any filetypes defined in
-- filetype.lua will take precedence.

-- on my init.lua i make a require to this file, so then I can place
-- it on my ~/.config/nvim/lua/core/ folder

vim.g.do_filetype_lua = 1
--vim.g.did_load_filetypes = 0 --disable filetype detection

-- local match_shebang = function(pattern)
--   return function(path, bufnr)
--     if string.find("stack", vim.api.nvim_buf_get_lines(bufnr, 0, 1, true)[1]) ~= 0 then
--       vim.notify("Filetype set to haskell, matched pattern: " .. pattern)
--       return "haskell"
--     end
--   end
-- end
-- 
-- local extensionless_file = "[%a-_]*"
-- vim.filetype.add({
--   -- char classes in lua https://www.lua.org/manual/5.3/manual.html#6.4.1
--   -- regex in lua https://www.lua.org/pil/20.2.html
--   pattern = {
--     [extensionless_file] = match_shebang("stack"),
--   },
--   filename = {
--     [".git/config"] = "gitconfig",
--     ["~/.config/mutt/muttrc"] = "muttrc",
--     ["README$"] = function(path, bufnr)
--       if string.find("#", vim.api.nvim_buf_get_lines(bufnr, 0, 1, true)) then
--         return "markdown"
--       end
--       -- no return means the filetype won't be set and to try the next method
--     end,
--   },
-- })

vim.filetype.add({
  pattern = {
    [".*/charts/.*.ya?ml"] = function(path, bufnr)
      -- Check if file contains Argo Workflows specific content
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 100, false)
      local has_helm = false
      local has_argo = false
      
      for _, line in ipairs(lines) do
        -- Check for Helm templating
        if line:match("{{") or line:match("}}") then
          has_helm = true
        end
        -- Check for Argo Workflows kinds
        if line:match("kind:%s*WorkflowTemplate") or 
           line:match("kind:%s*Workflow") or
           line:match("kind:%s*ClusterWorkflowTemplate") or
           line:match("kind:%s*CronWorkflow") then
          has_argo = true
        end
      end
      
      -- Prioritize yaml for LSP support even if Helm templating exists
      if has_argo then
        return "yaml.argo"
      elseif has_helm then
        return "yaml"  -- Use yaml instead of helm for LSP support
      end
      return "yaml"
    end,
  },
})
