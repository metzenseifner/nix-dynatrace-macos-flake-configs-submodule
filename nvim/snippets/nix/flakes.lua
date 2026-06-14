local fmapSystems = [[
# For each system, create an attribute set with the system name as the key
fmapSystems =
  f:
  nixpkgs.lib.listToAttrs (
    map (system: {
      name = system;
      value = f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
      };
    }) (nixpkgs.lib.systems.flakeExposed)
  );

perSystemOutputs =
  system: pkgs:
  let
    derivationNamedByKeyFactories = {

    };
    # Assume each key in derderivationNamedByKeyFactories is a symbol for a function for this template to serve as an example.
    resolvedDerivations = pkgs.lib.mapAttrs (name: f: f name) derivationNamedByKeyFactories;
  in
  {
    # Create the attrset with all dimensions to project over later
    packages = resolvedDerivations;
    apps =
      let
        mkBinApp = drv: bin: {
          type = "app";
          program = "${drv}/bin/${bin}";
        };
      in
      pkgs.lib.mapAttrs (name: drv: mkBinApp drv name) (
        pkgs.lib.filterAttrs (name: _: name != "default") resolvedDerivations
      );
    devShells = pkgs.mkShell {
      packages = resolvedDerivations;
    };
    checks = null;
  };
# Compute each system's outputs ONCE, then project each field out.
# This is the System↔Output transpose: perSystem is keyed by system,
# the flake schema wants each field keyed by system.
perSystem = fmapSystems perSystemOutputs;
project = field: builtins.mapAttrs (_: out: out.${field}) perSystem;
in {
  # Flake Outputs are projections over Record(system)
  packages = project "packages";
  apps = project "apps";
  devShells = project "devShells";
  # checks = project null;
}
]]

return {
  s("fmapSystems", fmt(fmapSystems, {}, { delimiters = "<>" }))
}
