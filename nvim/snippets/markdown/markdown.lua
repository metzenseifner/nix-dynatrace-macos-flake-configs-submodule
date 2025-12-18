return {
  s("link-markdown", fmt([[
    [<label>](<url>)
  ]], { label = i(1, "label"), url = i(2, "url") }, {delimiters="<>"})),

  s("[", fmt([[
    [<label>](<url>)
  ]], { label = i(1, "label"), url = i(2, "url") }, {delimiters="<>"})),

  s("task", fmt([[
    - [ ] <>
  ]], {i(1)}, {delimiters="<>"})),

}
