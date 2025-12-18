-- vim.notify("Custom " .. vim.fn.stdpath("config") .. "/ftplugin loading.")

--local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
--local workspace_dir = vim.fn.stdpath('data') .. '/java/' .. project_name

-- local config = {
--   cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/jdtls") },
--   root_dir = vim.fs.dirname(vim.fs.find({ ".gradlew", ".git", "mvn" }, { upward = true })[1])
-- }
-- 
-- -- We do this manually without LSP attach functions because of extra features unsupported by LSP yet
-- require("jdtls").start_or_attach(config)
