local finders = require("telescope.finders")      --provides interfaces to fill the picker with items.
local data_provider = require("telescope._extensions.special_files.data_provider")

local finder_elem_to_internal_entry_table = function(finder_elem)
  return {
    value = finder_elem,
    display = finder_elem[1],
    ordinal = finder_elem[1],
    path = finder_elem.path
  }
end

local finder_supplier = function(conf)
  return finders.new_table({
    results = data_provider.provide(conf),
    entry_maker = finder_elem_to_internal_entry_table,
  })
end
return finder_supplier
