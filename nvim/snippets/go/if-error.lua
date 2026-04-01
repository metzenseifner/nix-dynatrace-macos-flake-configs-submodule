return {
  s("if", fmt([[
    if err != nil {
      return err
    }
  ]], {}, { delimiters = "<>" }))
}
