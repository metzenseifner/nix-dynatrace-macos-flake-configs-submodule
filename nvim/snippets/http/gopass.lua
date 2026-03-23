return {
  s("gopass-minimal-example", fmt([[
    ### run request with variable set via pre-request script

    # @lang=lua
    < {%
      local secret = (function(h) local r=h:read("*a"); h:close(); r = r:gsub("^%s+", ""):gsub("%s+$", ""); return r end)(io.popen("gopass show -o path/to/secret"))()
      request.variables.set("secret", secret)
    %}
    ]], {}, { delimiters = "[]" })),
  s("gopass-full-example", fmt([[
    ### run request with variable set via pre-request script

    # @lang=lua
    < {%
      local secret = (function(h) local r=h:read("*a"); h:close(); r = r:gsub("^%s+", ""):gsub("%s+$", ""); return r end)(io.popen("gopass show -o path/to/secret"))()
      request.variables.set("secret", secret)
    %}

    GET /resource
    Host: https://
    Authorization: Token {{secret}}
    accept: application/json
    ]], {}, { delimiters = "[]" }))
}
