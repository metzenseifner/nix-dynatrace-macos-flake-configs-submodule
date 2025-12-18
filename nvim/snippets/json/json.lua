return {
  s("tsconfig-dynatrace-action", fmt([[
    {
      "compileOnSave": false,
      "compilerOptions": {
        "allowJs": true,
        "strict": true,
        "baseUrl": ".",
        "declaration": true,
        "emitDecoratorMetadata": true,
        "esModuleInterop": true,
        "experimentalDecorators": true,
        "importHelpers": false, /* Import emit helpers from 'tslib'. */
        "jsx": "react",
        "lib": [
          "DOM",
          "DOM.Iterable",
          "esnext"
        ],
        "module": "ESNext",
        "moduleResolution": "node",
        "skipDefaultLibCheck": true,
        "skipLibCheck": true, /* Skip type checking of declaration files. */
        "sourceMap": true,
        "target": "ESNext",
        "types": [
          "node",
          "jest"
        ],
        "typeRoots": [
          "../../../node_modules/@types",
          "../../../node_modules/@dynatrace"
        ]
      },
    }
  ]], {}, {delimiters="<>"})),
}
