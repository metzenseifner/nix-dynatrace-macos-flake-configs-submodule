function node() {
  unset -f node
  load_nvm
  nvm use "$NVM_NODE_VERSION"   # Make it unnecessary to call nvm use
  node "$@"
}
