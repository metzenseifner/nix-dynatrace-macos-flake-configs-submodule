# QEMU (macOS Homebrew specific - HVF is macOS hypervisor framework)
if [[ $(uname) == "Darwin" ]]; then
  export PATH=/opt/homebrew/opt/qemu-hvf/bin:"$PATH"
fi
