return {
  s("globals-in-scripts", fmt([[
    # Define a global
    @stage = dev

    ### Test global variable access from within scripts
    # from https://github.com/rest-nvim/rest.nvim/blob/de9726ab956e30202aafbcdea83c1d6bffe54227/lua/rest-nvim/script/lua.lua#L69

    # @lang=lua
    < {%
      request.variables.set("val",  request.variables.get("stage") or "empty")
    %}
    GET www.duckduckgo.com#{{val}}
  ]], {}, { delimiters = "[]" }))
}
