local ms = require("luasnip").multi_snippet
local fmt = require("luasnip.extras.fmt").fmt

return {
  ms({
      "read-from-external-linux-process",
      "subprocess-read-stdout",
      "process-read-stdout"
    },
    fmt([=[
      function getExternalData()
          local handle = io.popen("gopass show -o dt/bitbucket.lab.dynatrace.org/tokens/http-access-token-admin")
          local result = handle:read("*a")
          handle:close()
          return result
      end
  ]=], {}, {delimiters="<>"}), nil),
  ms({
      -- { trig = "system-exec", snippetType = "snippet" },
      -- { trig = "exec",        snippetType = "snippet" },
      "system-exec",
      "exec"
    },
    fmt([=[
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable", -- latest stable release
          lazypath,
        })
      end
    ]=], {}, { delimiters = "<>" })
    , nil)
}
