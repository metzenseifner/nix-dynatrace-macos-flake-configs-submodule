function webenv() {
  echo "Also see: npm exec wave-cli -- info"
  echo "Node.js version: $(node --version)"
  echo "NPM version: $(npm --version)"
  echo "OS version: $(sw_vers)"
  echo "Kernel: $(uname -v)"
}
# Or npm exec wave-cli -- info
# equiv npx wave-cli info
