Snippets should ultimately be grouped by target filetype (language).
The default organization is <filetype>.lua in a flat directory structure.
It would be possible to have a directory structure to spread out snippets 
across multiple files:

see

luasnip.filetype_extend("html", {"jekyll"})

require("luasnip.loaders.from_lua").load({paths = "~/snippets"})


```
.
├── all
├── typescript
└── typescriptreact

```



Slightly less flexible way according to docs: 

require("luasnip").add_snippets(filetype, snippets)
