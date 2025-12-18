local module = {}
module.links = {
  ["team-wiki"] = "https://dt-rnd.atlassian.net/wiki/spaces/ACE/pages/113909099/Team+Platinum",
}

module.toString = function(value)
  return string.format("%s", value)
end

module.generate_snippets = function(links)
  local snippets = {}
  for k, v in pairs(links) do
    table.insert(snippets, s(module.toString(k), t(module.toString(v))))
  end
  return snippets
end

return module.generate_snippets(module.links)
