function npx() {
  unset -f npx
  load_nvm
  npx "$@"
}
