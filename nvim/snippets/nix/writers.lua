return {
  s("pkgs-writers-writePython3Bin-derivation", fmt([[
      pkgs.writers.writePython3Bin "my-script" {
        libraries = [ pkgs.python3Packages.requests ];
      } ''
        import requests
        print(requests.get("https://example.com").status_code)
        ''
  ]], {}, { delimiters = "<>" })),
  s("pkgs-writers-writePython2Bin-derivation", fmt([[
    pkgs.writers.writePython2Bin "my-script" { deps = []; } ''
      print "hello"
      ''
  ]], {}, { delimiters = "<>" })),
  s("pkgs-writers-writePerlBin-derivation", fmt([[
    pkgs.writers.writePerlBin "my-script" {
      libraries = [ pkgs.perlPackages.boolean ];
    } ''
      use boolean;
      print "Howdy!\n" if true;
    ''
  ]], {}, { delimiters = "<>" })),
  s("pkgs-writers-writewriteJSBin-derivation", fmt([[
    pkgs.writers.writeJSBin "my-script" {
      libraries = [ pkgs.nodePackages.lodash ];
    } ''
      const _ = require('lodash');
      console.log(_.VERSION);
    ''
  ]], {}, { delimiters = "<>" })),
  s("pkgs-writers-makeScriptWriter-derivation", fmt([[
    # Generic interpreter (e.g. any Python build)
    pkgs.writers.makeScriptWriter {
      interpreter = "${pkgs.python3}/bin/python";
    } "my-script" "print('hello')"
  ]], {}, { delimiters = "<>" })),
  s("pkgs-writers-makeBinWriter-derivation", fmt([[
    # Compiled (e.g. C via gcc)
    pkgs.writers.makeBinWriter {
      compileScript = "${pkgs.gcc}/bin/gcc -o $out $contentPath";
    } "hello" ./main.c
  ]], {}, { delimiters = "<>" })),
}
