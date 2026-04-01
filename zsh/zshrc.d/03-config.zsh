config() {
  local config_dir="$HOME/.local/share/nix/current-config-dir"
  if [[ -L "$config_dir" ]]; then
    local store_path=$(greadlink -f "$config_dir" 2>/dev/null || readlink -f "$config_dir" 2>/dev/null)
    if [[ -f "$store_path/.git" ]]; then
      local gitdir=$(grep '^gitdir:' "$store_path/.git" | cut -d' ' -f2)
      if [[ -n "$gitdir" ]]; then
        local worktree_path=$(dirname "$gitdir" | sed 's|/.git/worktrees/[^/]*$||')
        cd "$worktree_path/branches/$(basename "$(dirname "$gitdir")")" 2>/dev/null || cd "$store_path"
      else
        cd "$store_path"
      fi
    else
      cd "$store_path"
    fi
  else
    cd "$config_dir"
  fi
}
