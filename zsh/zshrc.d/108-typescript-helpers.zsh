#!/usr/bin/env zsh
TSC=/Users/jonathan.komar/.local/share/nvm/versions/node/v16.17.0/bin/tsc

function setup_ts_playground() {
  set -x
  npm init
  npm install --save-dev jest ts-jest @types/jest
  tsc --init
}

function log() {
  local message=$1
  echo "==> $message"
}

function tsc_get_config() {
  $TSC --showConfig -p .
}

function tsc_typecheck() {
  $TSC --noEmit -p .
}

function tsc_test() {
  local FILE=$1
 # -t, --target Set JS language version include compatible lib declarations
 # use esnext. default is es3 (oldest)
 # $TSC -t esnext
 npm exec jest "$FILE" #--config=src/jest.config.ts
}

function tsc_assemble() {

}

function tsc_compile() {
  # -p, --project (rootDir) compile at path or use tsconfig.json
  # --lib list of lib decl files that describe JS runtime makes APIs avail
  # -d (declaration) generate .d.ts files
  # --declarationMap (sourceMap) create sourcemaps for d.ts files
  #
  $TSC -d --declarationMap --lib DOM DOM.Iterable esnext --outDir build -t esnext -p .
}

# log "Create"
# $TSC --init
