# Homebrew - Nix manages most GNU tools (coreutils, grep, findutils, etc.)
# Only configure Homebrew for GUI apps and tools not in Nix

# Homebrew base paths for casks and brews
path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
