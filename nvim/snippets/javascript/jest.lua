return {
  s("jest-config", fmt([=[
  /**
    * @license
    * Copyright 2022 Dynatrace LLC
    * Licensed under the Apache License, Version 2.0 (the "License");
    * you may not use this file except in compliance with the License.
    * You may obtain a copy of the License at
    *
    * http://www.apache.org/licenses/LICENSE-2.0
    *
    * Unless required by applicable law or agreed to in writing, software
    * distributed under the License is distributed on an "AS IS" BASIS,
    * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    * See the License for the specific language governing permissions and
    * limitations under the License.
    */
   
   /** @type {import('ts-jest/dist/types').InitialOptionsTsJest} */
   module.exports = {
     // References the main jest.config.[ts|js]
     rootDir: '../',
     // References the dirs containing test files (dot relative to this file)
     roots: ['.'],
     preset: 'ts-jest',
     clearMocks: true,
     globals: {
       'ts-jest': {
         // points to tsconfig responsible for managing implicit type injection into test files
         tsconfig: '<<rootDir>>/tsconfig.json',
         isolatedModules: true,
       },
     },
   };

   // TODO: Reference this file in projects array in top-level jest.config.js
   // /** @type {import('ts-jest/dist/types').InitialOptionsTsJest} */
   // module.exports = {
   //   projects: [
   //     'relative/path/to/jest.config.js'
   //   ],
   };

   // TODO Setup tsconfig.json for the tests, especially types: ['jest']
   // {
   //   "extends": "../tsconfig.json",
   //   "compilerOptions": {
   //     "module": "commonjs",
   //     "types": [
   //       "node",
   //       "testcafe",
   //       "jest"
   //     ],
   //     "declaration": false,
   //     "sourceMap": false,
   //     "inlineSourceMap": true,
   //     "allowJs": true,
   //     "resolveJsonModule": true,
   //     "allowSyntheticDefaultImports": true
   //   },
   //   "include": [
   //     "**/*",
   //     "setup.ts"
   //   ],
   // }
  ]=], {}, {delimiters="<>"}))
}
