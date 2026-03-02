return {
  -- panic is a "bottom type"/type without values: preferred over return errors.New("not yet implemented") because it is agnostic to return types
  s("not-yet-implemented", fmt([[
    panic("not yet implemented")
  ]], {}, {}))
}
