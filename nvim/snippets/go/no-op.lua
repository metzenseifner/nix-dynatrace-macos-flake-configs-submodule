return {
  s("no-op", fmt([[
  func(_ ...interface{}) {}
  ]], {}, { delimiters = "[]" }))
}
