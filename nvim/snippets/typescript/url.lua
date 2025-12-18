return {
  s("url-path-base", fmt([=[
    new URL('[path]', '[base]');
  ]=], {path = i(2, 'path'), base = i(1, 'base')}, {delimiters="[]"}))
}
