local writers = {
  "writePython3Bin",
  "writePython2Bin",
  "writePerlBin",
  "writeJSBin",
}

return {
  s("pkgs-writeShellScriptBin-derivation", fmt([[
      pkgs.writeShellScriptBin "my-script" ''
        # Nix overwrites the shebang with a default shell - injects the bash shebang, nothing else. You're on your own for error handling.
        set -euo pipefail
        # hermetically sealed dependencies (only ref the Nix Store) - from alchemist Hermes Trismegistus, meaning airtight
        ${pkgs.curl}/bin/curl -s "https://example.com/api" | ${pkgs.jq}/bin/jq '.data'
      '';
  ]], {}, { delimiters = "<>" })),
  s("pkgs-writeShellApplication-derivation", fmt([[
      pkgs.writeShellApplication {
        # injects set -euo pipefail automatically, plus runs shellcheck on your script at build time. The most opinionated/safe option.
        name = "my-script";
        # hermetically sealed dependencies (only ref the Nix Store) - from alchemist Hermes Trismegistus, meaning airtight
        runtimeInputs = [ pkgs.curl pkgs.jq ];
        text = ''
          curl -s "https://example.com/api" | jq '.data'
        '';
      };
  ]], {}, { delimiters = "<>" })),
  s("pkgs-mkDerivation-derivation", fmt([[
    home.packages = [
      pkgs.stdenv.mkDerivation {
        # the builder uses set -e by default (via the generic builder), but not -u or pipefail.
        # hermetically sealed dependencies (only ref the Nix Store) - from alchemist Hermes Trismegistus, meaning airtight
        name = "my-script";
        src = ./scripts;
        installPhase = ''
          mkdir -p $out/bin
          cp my-script.sh $out/bin/my-script
          chmod +x $out/bin/my-script
        '';
      };
  ]], {}, { delimiters = "<>" })),
  s("pkgs-writeTextFile-derivation", fmt([[
      pkgs.writeTextFile {
        # hermetically sealed dependencies (only ref the Nix Store) - from alchemist Hermes Trismegistus, meaning airtight
        name = "config";
        destination = "/bin/config";
        text = ''
          ${pkgs.bash}/bin/bash
          set -eou pipefail
          cd "${configRoot}"
        '';
      };
  ]], {}, { delimiters = "<>" }))
}
