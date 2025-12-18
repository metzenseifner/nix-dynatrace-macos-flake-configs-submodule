local packages = {
  { name = "optparse-applicative", desc = "for applicative arg parsing" },
  { name = "process" },
  { name = "directory" },
  { name = "filepath" },
  { name = "text" },
  { name = "autodocodec" },
  { name = "autodocodec-yaml" },
  { name = "aeson" },
  { name = "bytestring" },
}

local createSnippetsFor = function(packages)
  local snippets = {}
  for _, package in pairs(packages) do
    table.insert(snippets,
      s(string.format("package-%s", package.name, package.desc),
        { t({ string.format("%s -- %s https://hackage.haskell.org/package/%s", package.name, package.desc, package.name) }) }))
  end
  return snippets
end


return createSnippetsFor(packages)
