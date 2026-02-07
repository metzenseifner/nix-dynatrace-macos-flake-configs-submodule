# WezTerm CLI - symlink to ~/.local/bin for PATH access
# WezTerm is installed via Homebrew cask, but CLI needs to be in PATH

WEZTERM_APP="/Applications/WezTerm.app/Contents/MacOS/wezterm"
WEZTERM_SYMLINK="$HOME/.local/bin/wezterm"

if [[ -x "$WEZTERM_APP" ]] && [[ ! -e "$WEZTERM_SYMLINK" ]]; then
  ln -sf "$WEZTERM_APP" "$WEZTERM_SYMLINK"
fi
