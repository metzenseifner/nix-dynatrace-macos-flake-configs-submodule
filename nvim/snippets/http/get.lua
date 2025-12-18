local c = require("luasnip").choice_node
return {
  s("GET", fmt([[
###
# @name <name>
@var=123
GET <path_segment>
HOST: <host>
Content-Type: application/json
Authorization: Basic {{BASE64_USERNAME_TOKEN}}
  ]], { name=i(1), path_segment = i(2, "/api/{{var}}"), host = i(3, "https://") }, { delimiters = "<>" })),

  s("script", c(1, {
    sn(nil, fmt([=[
# https://www.jetbrains.com/help/idea/http-client-in-product-code-editor.html#using-response-handler-scripts
# @lang=lua
< {%
client.global.set("version", client.global.get("version"))
%}
  ]=], {}, { delimiters = "[]" })),
    sn(nil, fmt([[
# https://www.jetbrains.com/help/idea/http-client-in-product-code-editor.html#using-response-handler-scripts
> /path/to/file
  ]], {}, { delimiters = "[]" }))
  })
  )
}
