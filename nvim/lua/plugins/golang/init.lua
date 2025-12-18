--I used https://www.youtube.com/watch?v=i04sSQjd-qo because this dev is aligned with my opinion: prefer multiple focused packages than do-it-all packages
return {
  { import = "plugins.golang.gopher" },
  { import = "plugins.golang.delve" },
  -- not working { import = "plugins.golang.gotmpl" }
  --{ import = "plugins.golang.gotests" }
}
