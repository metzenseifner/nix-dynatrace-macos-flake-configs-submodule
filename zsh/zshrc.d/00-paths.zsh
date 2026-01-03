# Minimal PATH setup - Nix manages most paths via home.sessionPath
# Only add paths for non-Nix managed tools

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
