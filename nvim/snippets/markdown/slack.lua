return {
  s("link-slack", fmt([[
    <{URL}|{LABEL}>{EOL}
  ]], { URL = i(1, "URL"), LABEL = i(2, "Label"), EOL = i(0) }, { delimiters = "{}" }))
}
