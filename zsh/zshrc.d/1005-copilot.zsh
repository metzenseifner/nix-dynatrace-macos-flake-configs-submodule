copi() {
  str='copilot --allow-all-paths --allow-all-tools --no-color "$@"'
  echo -n "Executing: $str"
  eval "$str"
}
