return {
  s("editorconfig",
    fmta([==[
      root = true

      [*]
      charset = utf-8
      end_of_line = lf
      insert_final_newline = true
      indent_style = space
      indent_size = 2
      trim_trailing_whitespace = true

      [*.{json,yml,yaml,md,html,css,js,ts,tsx}]
      indent_size = 2

      [*.{bat,ps1}]
      end_of_line = crlf
    ]==], {})
  ),

  s("eslintrcreact",
    fmta([==[
      // npm install --save-dev @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint typescript
      // npm install --save-dev eslint-config-prettier eslint-plugin-prettier
      // npm install --save-dev eslint-plugin-redos
      // npm install --save-dev eslint-plugin-no-secrets
      // npm install --save-dev eslint-plugin-xss
      // npm install --save-dev eslint-plugin-lwc
      // npm install --save-dev eslint-plugin-no-unsanitized
      {
        "root": true,
        "parser": "@typescript-eslint/parser",
        "parserOptions": {
          "project": [
            // put all paths to tsconfig.json here
            "./**/tsconfig.json",
          ]
        },
        "plugins": [
          "react",
          "@typescript-eslint",
          "react-hooks",
          "prettier",
          "testing-library",
          "import",
          "sonarjs",
          "no-secrets",
          "redos",
          "@lwc/eslint-plugin-lwc",
          "no-unsanitized",
          "jsx-a11y",
          "xss"
        ],
        "extends": [
          "eslint:recommended",
          "plugin:@typescript-eslint/recommended",
          "plugin:@typescript-eslint/strict",
          "plugin:@typescript-eslint/recommended-requiring-type-checking",
          "airbnb-typescript",
          "plugin:react/recommended",
          "plugin:react-hooks/recommended",
          "plugin:testing-library/react",
          "prettier",
          "plugin:sonarjs/recommended",
          "plugin:jsx-a11y/recommended",
          "plugin:xss/recommended"
        ],
        "rules": {
          "camelcase": [2, {"properties": "never"}],
          "prettier/prettier": "error",
          "lines-between-class-members": "off",
          "no-underscore-dangle": ["error", {"allowAfterThis": true}],

          "react-hooks/rules-of-hooks": "error",
          "react-hooks/exhaustive-deps": "warn",
          "react/no-unescaped-entities": "warn",
          "react/jsx-no-leaked-render": "warn",
          "react/prop-types": "warn",
          "react/no-danger": "error",
          "react/no-unsafe": "error",
          "react/no-typos": "warn",
          "react/no-invalid-html-attribute": "warn",
          "react/jsx-no-script-url": "error",
          "react/jsx-no-target-blank": [
            "error", {
              "allowReferrer": false,
              "enforceDynamicLinks": "always",
              "warnOnSpreadAttributes": true
            }
          ],
          "@typescript-eslint/no-inferrable-types": "off",
          "@typescript-eslint/array-type": "off",
          "@typescript-eslint/ban-ts-comment": "off",
          "@typescript-eslint/no-misused-promises": ["error", {
            "checksVoidReturn": {
              "attributes": false
            }
          }],
          "import/prefer-default-export": "off",
          "import/no-extraneous-dependencies": [
            "error",
            {
              "devDependencies": [
                "src/jest*",
                "/e2e/**/*ts",
                "/api-test/**",
                "**/*.test.tsx",
                "**/*.test.ts",
                "**/*.spec.ts",
                "**/*.spec.tsx",
                "/src/testing/**",
                "/widgets/testing/**",
                "**/setupJest.ts",
                "**/setupJest.js",
                "**/*.stories.tsx"
              ]
            }
          ],
          "import/no-duplicates": ["error"],
          "import/order": [
            "error",
            {
              "alphabetize": {
                "order": "asc",
                "caseInsensitive": true
              },
              "groups": [
                "builtin",
                "external",
                "internal",
                "index",
                "parent",
                "sibling",
                "object",
                "type"
              ]
            }
          ],
          "no-param-reassign": 0,
          "@typescript-eslint/restrict-template-expressions": "error",
          "@typescript-eslint/no-unused-vars": [
            "error", {
              "argsIgnorePattern": "^_",
              "caughtErrorsIgnorePattern": "^_",
              "destructuredArrayIgnorePattern": "^_"
            }
          ],
          "@typescript-eslint/no-redeclare": ["error", {"builtinGlobals": false}],
          "@typescript-eslint/lines-between-class-members": [
            "error",
            "always",
            {
              "exceptAfterSingleLine": true,
              "exceptAfterOverload": true
            }
          ],

          "@lwc/lwc/no-inner-html": "error",
          "no-unsanitized/method": "error",
          "no-unsanitized/property": "error",

          "no-secrets/no-secrets": [
            "error",
            {
              "additionalRegexes": {
                "Dynatrace Token SSO": "dt0[a-zA-Z]{1}[0-9]{2}\\.[A-Z0-9]{8}\\.[A-Z0-9]{64}",
                "Dynatrace Token SSO Internal services": "dt0[a-zA-Z]{1}[0-9]{2}\\.[A-Za-z0-9\\-]+\\.[A-Z0-9]{64}",
                "Dynatrace Token Agents ODIN Agent Token v1": "dt0[a-zA-Z]{1}[0-9]{2}\\.[a-z0-9-]+\\.[A-Fa-f0-9]{64}",
                "Dynatrace Token Agents Tenant Token": "dt0[a-zA-Z]{1}[0-9]{2}\\.[a-zA-Z0-9]{24}",
                "Dynatrace Token Custer REST APIs": "dt0[a-zA-Z]{1}[0-9]{2}\\.[A-Z0-9]{24}\\.[A-Z0-9]{64}"
              }
            }
          ],
          "redos/no-vulnerable": "error",
          "no-alert": "warn",
          "no-eval": "error"
        },
        "overrides": [
          {
            "files": [
              "src/jest*",
              "**/__tests__/**/*.[jt]s?(x)",
              "**/?(*.)+(spec|test).[jt]s?(x)"
            ],
            "extends": [
              "plugin:testing-library/react"
            ]
          },
          {
            "files": [
              "src/jest*",
              "**/e2e/**/*ts",
              "**/*.spec.ts",
              "**/*.spec.tsx",
              "**/*.test.ts",
              "**/*.test.tsx",
              "__setup__/**/*.ts",
              "**/testing/**/*.ts",
              "**/testing/**/*.tsx"
            ],
            "rules": {
              "@typescript-eslint/no-unsafe-argument": "off",
              "@typescript-eslint/no-unsafe-call": "off",
              "@typescript-eslint/no-unsafe-member-access": "off",
              "@typescript-eslint/no-unsafe-assignment": "off",
              "@typescript-eslint/no-unsafe-return": "off",
              "@typescript-eslint/await-thenable": "warn",
              "@typescript-eslint/restrict-template-expressions": "off",

              "sonarjs/no-duplicate-string": "warn",
              "redos/no-vulnerable": "off",
              "no-alert": "warn",
              "no-eval": "error",
              "xss/no-mixed-html": "off"
            }
          },
          {
            "files": [
              "**/*.mock.*"
            ],
            "rules": {
              "sonarjs/no-duplicate-string": "off"
            }
          }
        ],
        "settings": {
          "react": {
            "pragma": "React",
            "version": "detect"
          }
        },
        "ignorePatterns": [
          "src/jest*",
          "**/setupJest.ts",
          "**/setupJest.js",
          "**/jest.config.js",
          ".ci/**",
          ".vscode/**",
          ".dtp-cli/**",
          ".git/**",
          "screenshots/**",
          "dist/**",
          "reports/**",
          "node_modules"
        ]
      }
    ]==], {})
  ),
  s("prettierrc",
    fmta([==[
      {
        "arrowParens": "always",
        "bracketSameLine": false,
        "bracketSpacing": true,
        "embeddedLanguageFormatting": "auto",
        "htmlWhitespaceSensitivity": "strict",
        "insertPragma": false,
        "jsxSingleQuote": true,
        "printWidth": 120,
        "proseWrap": "preserve",
        "quoteProps": "consistent",
        "requirePragma": false,
        "semi": true,
        "singleQuote": true,
        "tabWidth": 2,
        "trailingComma": "all",
        "useTabs": false
      }
      ]==], {})
  ),
  s("result",
    fmt([=[
      export type Success<A,> = { _tag: 'success'; value: A }
      export type Failure = { _tag: 'failure', exception: string }
      export type Result<A> = Success<A> | Failure
      export type Input = { content: string }
      export type Output<A> = Result<A>;
    ]=], {}, { delimiters = '[]' })
  ),
}
