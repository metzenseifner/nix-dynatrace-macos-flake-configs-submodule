return {
  s("execute-tests", fmt([[
  This dir passed to go toolchain on CLI has a main file is in a folder that’s the module root.
  There’s a sibling package at ./test with package test that defines:
  
  type Params struct { ... }
  func ExecuteTestCommand(Params) error

  go run . test
  ]], {}, {delimiters="[]"}))
}
