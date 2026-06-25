local dir_reader = [[
{ lib, ... }:
let
  dir = ./.;
  entries = builtins.readDir dir;
  nixFiles = builtins.filter
    (n: n != "default.nix" && lib.hasSuffix ".nix" n)
    (builtins.attrNames entries);
in
{
  imports = map (n: dir + "/${n}") nixFiles;
}
]]
local dir_reader_recursive = [[
lib.filesystem.listFilesRecursive ./repos
]]

return {
  s("nix-files-reader", fmt(dir_reader, {}, { delimiters = "<>" })),
  s("nix-files-reader-recursive", fmt(dir_reader_recursive, {}, { delimiters = "<>" }))
}
