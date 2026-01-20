# Minimal PATH setup - Nix manages most paths via home.sessionPath
# Only add paths for non-Nix managed tools

# Ensure GNU stat takes precedence over zsh builtin stat
# Disable the stat builtin if loaded, and create a hash to prefer external command
disable stat 2>/dev/null
alias stat='command stat'
hash -d stat 2>/dev/null

# Cargo/Rust (user-installed, not managed by Nix)
path=(~/.local/share/cargo/bin $path)

# Go binaries (user-installed packages)
path=($HOME/go/bin $path)

# Rancher Desktop (if installed)
path=($HOME/.rd/bin $path)

# TexLive (system-wide installation)
if [[ $(uname) == "Darwin" ]]; then
  [[ -d /usr/local/texlive/current/bin/universal-darwin ]] && path=(/usr/local/texlive/current/bin/universal-darwin $path)
fi

export PATH
