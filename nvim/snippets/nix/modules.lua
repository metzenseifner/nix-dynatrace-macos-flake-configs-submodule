return {
  s("module", fmt([=[
    # module :: Args → { config, options, lib, pkgs, modulesPath, specialArgs..., _module.args... }
    {...}: {
    }
  ]=], {}, { delimiters = "[]" }))
}
