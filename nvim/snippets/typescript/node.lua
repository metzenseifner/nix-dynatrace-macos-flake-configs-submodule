return {
  s("file-json-update", fmt([[
    node -p const fs = require('fs');let pkg = require('./package.json');pkg.version = process.env['VERSION'];fs.writeFileSync('package.json', JSON.stringify(pkg));
  ]], {}, {delimiters="<>"}))
}
