#!/usr/bin/env zsh
#export PATH=$HOME/.local/share/nvm/versions/node/v$NODE_VERSION/bin:"$PATH"
#nvm use $MY_NODE_VERSION
export DEBUG_PRINT_LIMIT=100000

function npm() {
  unset -f npm
  load_nvm
  nvm use "$NVM_NODE_VERSION"   # Redefine so it is not needed to call nvm use
  npm "$@"
}
