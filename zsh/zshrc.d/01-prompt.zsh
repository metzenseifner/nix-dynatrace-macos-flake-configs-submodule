# Optimized git prompt - cached to avoid repeated git calls
typeset -g _git_prompt_cache=""
typeset -g _git_prompt_pwd=""

git_branch() {
  # Cache git branch per directory to avoid repeated calls
  if [[ "$PWD" != "$_git_prompt_pwd" ]]; then
    _git_prompt_pwd="$PWD"
    _git_prompt_cache=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  fi
  printf "$_git_prompt_cache"
}

render_git_branch() {
  local branch=$(git_branch)
  [[ -n "$branch" ]] && printf "$BRANCH_SYMBOL $branch " || printf ""
}

render_worktree_root() {
  # Simplified check to avoid subprocess overhead
  if [[ "${PWD:h:t}" == "branches" ]]; then
    echo " ⌅ ${PWD:h:h:t} "
  fi
}

setup_zsh_shell() {
  setopt interactivecomments PROMPT_SUBST

  # Cache user ID check at startup
  if [[ $(id -u) == 0 ]]; then
    EFFECTIVE_USER_COLOR=red
    EFFECTIVE_USER_WEIGHT=%B
  else
    EFFECTIVE_USER_COLOR=5
    EFFECTIVE_USER_WEIGHT=""
  fi

  USER_FORMAT="${EFFECTIVE_USER_WEIGHT}%F{${EFFECTIVE_USER_COLOR}}"
  
  # Top-level Abstraction - cache static values
  MYUSER="$USER_FORMAT%n($(id -u))%f%b"
  HOSTNAME="%F{green}%m%f"
  TIMESTAMP="%B%F{blue}%D{%H:%M:%S}%f%b"
  TTY="%y%f"
  DIR="%1d"
  END="%B%F{green}$%f%b "
  BRANCH_SYMBOL=$'\U2387'
  NEWLINE=$'\n'
  
  PS1='$TTY $TIMESTAMP $MYUSER@$HOSTNAME$(render_worktree_root)$(render_git_branch) $DIR $NEWLINE$END'
}

if [[ "$SHELL" == "/bin/zsh" ]]; then
  setup_zsh_shell
fi
