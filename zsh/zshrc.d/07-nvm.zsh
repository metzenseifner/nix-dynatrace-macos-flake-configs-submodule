# Node.js is managed by Nix (nodejs_22 in flake.nix)
# NVM is not needed - Nix provides node, npm, npx directly
# If you need project-specific Node versions, use direnv with nix-shell
export DEBUG_PRINT_LIMIT=100000

# Uncomment below only if you need NVM for legacy projects not using Nix
# NVM_NODE_VERSION=22.15.0
# function load_nvm() {
#   export NVM_DIR=$HOME/.local/share/nvm
#   [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh" --no-use
#   [ -s "${NVM_DIR}/etc/bash_completion.d/nvm" ] && \. "${NVM_DIR}/etc/bash_completion.d/nvm"
# }
# function nvm() { unset -f nvm node npm npx; load_nvm; nvm "$@"; }
