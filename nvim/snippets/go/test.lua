return {
  s("Test", fmt([[
		Test_<what>(t *testing: T) {
      t.Run("that <behavior>", func(t *testing.T) {
        panic("not yet implemented")
      }
    })
		]], { what = i(1, "Func"), behavior = i(2, "behavior") }, { delimiters = "<>" })),
  s("test-help", fmt([[
      // The higher order function "f" received a NEW 't' *testing.T instance. This implies it can pass/fail independently of parent
      // The testing framework builds a tree of tests for parent and children.
      func (t *Testing) Run(name string, f func(t *testing.T)) bool
    ]], {}, { delimiters = "<>" }))
}
