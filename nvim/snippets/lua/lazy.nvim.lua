return {
  s("keymap", fmt([[
        { "<keystrokes>", function() <functiondef> end, desc = "<description>" },
  ]], { keystrokes = i(2, "keystrokes"), functiondef = i(3, ""), description = i(1, "description") },
    { delimiters = "<>" }))
}
