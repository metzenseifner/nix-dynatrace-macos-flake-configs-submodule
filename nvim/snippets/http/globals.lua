return {
  s("global", t([[@varName = someValue ]])),
  s("global-use-in-script", t([[request.variables.get("varName") or "empty"]])),
}
