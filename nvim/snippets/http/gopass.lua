return {
  s("gopass-minimal-example", fmt([[
    # @lang=lua
    < {%
      local secret = (function(h) local r=h:read("*a"); h:close(); return r end)(io.popen("gopass show -o path/to/secret"))()
    %}
    ]], {}, { delimiters = "[]" })),
  s("gopass-full-example", fmt([[
    # @lang=lua
    < {%
      local secret = (function(h) local r=h:read("*a"); h:close(); return r end)(io.popen("gopass show -o path/to/secret"))()
    %}
    ###

    GET /resource
    Host: https://
    Authorization: Token {{secret}}
    accept: application/json
    ]], {}, { delimiters = "[]" }))
}
