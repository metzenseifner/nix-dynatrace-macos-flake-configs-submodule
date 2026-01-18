return {
  jsonls = {
    filetypes = { 'json' },
    settings = {
      json = {
        trace = {
          server = 'on'
        },
        validate = { enable = true },
        cmd = { "vscode-json-languageserver", "--stdio" },
        schemas = {
          --require('schemastore').json.schemas(),
          {
            -- git clone --depth 1 ssh://git@bitbucket.lab.dynatrace.org/rx/configuration-core.git ~/devel/dynatrace_bitbucket/
            description = 'Dynatrace Settings 2.0 Schema',
            fileMatch = { '/settings-2.0/*.schema.json' }, -- array of filepath names separated by /, * glob supported
            url = 'file://' ..
                vim.fn.expand('~') ..
                '/devel/dynatrace_bitbucket/configuration-core/core-schema/src/main/resources/1/schema_strict_static.json'
          },
          {
            description = 'TypeScript compiler configuration file',
            fileMatch = { 'tsconfig.json', 'tsconfig.*.json' },
            url = 'http://json.schemastore.org/tsconfig'
          },
          {
            description = 'Lerna config',
            fileMatch = { 'lerna.json' },
            url = 'http://json.schemastore.org/lerna'
          },
          {
            description = 'Babel configuration',
            fileMatch = { '.babelrc.json', '.babelrc', 'babel.config.json' },
            url = 'http://json.schemastore.org/lerna'
          },
          {
            description = 'ESLint config',
            fileMatch = { '.eslintrc.json' },
            url = 'http://json.schemastore.org/eslintrc'
          },
          {
            description = 'Bucklescript config',
            fileMatch = { 'bsconfig.json' },
            url = 'https://bucklescript.github.io/bucklescript/docson/build-schema.json'
          },
          {
            description = 'Prettier config',
            fileMatch = { '.prettierrc', '.prettierrc.json', 'prettier.config.json' },
            url = 'http://json.schemastore.org/prettierrc'
          },
          {
            description = 'Vercel Now config',
            fileMatch = { 'now.json' },
            url = 'http://json.schemastore.org/now'
          },
          {
            description = 'Stylelint config',
            fileMatch = { '.stylelintrc', '.stylelintrc.json', 'stylelint.config.json' },
            url = 'http://json.schemastore.org/stylelintrc'
          }
        }
      }
    }
  }
}
