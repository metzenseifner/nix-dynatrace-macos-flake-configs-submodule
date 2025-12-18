return {
  s("config", fmt([[
    -- assumes user_opts (opts defined by user) is within closure
    local default_conf = {}
    local conf = vim.tbl_deep_extend("force", {}, default_conf, user_opts) -- force means right takes precedence (right overrides left)
  ]], {}, { delimiters = "[]" }))
}
