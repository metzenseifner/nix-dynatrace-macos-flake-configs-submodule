return {
  groovyls = {
    cmd = { "java", "-jar",
      vim.fs.normalize("~/.local/share/groovy-language-server/groovy-language-server-all.jar") },
    filetypes = { "groovy" },

    --root_dir = function(startpath)
    --return M.search_ancestors(startpath, matchervim.stdpath)
    --end
  }
}
