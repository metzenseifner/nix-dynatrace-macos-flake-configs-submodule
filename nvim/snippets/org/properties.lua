return {
  s({ trig = ":PROPERTIES:" }, fmt([[
  :PROPERTIES:
  :<key>: <value>
  :END:
  ]], { key = i(1), value = i(2) }, { delimiters = "<>" }))
}
