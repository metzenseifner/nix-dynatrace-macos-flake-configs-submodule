#
# Key optimizations to employ
# 
#  - No external git calls in the prompt. Reads .git/HEAD directly with zsh builtins.
#  - Uses EUID instead of id -u (no subprocess).
#  - Replaces $(render_...) in PS1 with cached variables updated via precmd/chpwd hooks (avoids subshells on every prompt render).
#  - Only recomputes the branch when the .git/HEAD mtime changes (via zsh/stat if available)
#
#
#
#
#### # Optimized git prompt - cached to avoid repeated git calls
#### typeset -g _git_prompt_cache=""
#### typeset -g _git_prompt_pwd=""
####
#### git_branch() {
####   # Cache git branch per directory to avoid repeated calls
####   if [[ "$PWD" != "$_git_prompt_pwd" ]]; then
####     _git_prompt_pwd="$PWD"
####     _git_prompt_cache=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
####   fi
####   printf "$_git_prompt_cache"
#### }
#### 
#### render_git_branch() {
####   local branch=$(git_branch)
####   [[ -n "$branch" ]] && printf "$BRANCH_SYMBOL $branch " || printf ""
#### }
#### 
#### render_worktree_root() {
####   # Simplified check to avoid subprocess overhead
####   if [[ "${PWD:h:t}" == "branches" ]]; then
####     echo " ⌅ ${PWD:h:h:t} "
####   fi
#### }
#### 
#### setup_zsh_shell() {
####   setopt interactivecomments PROMPT_SUBST
#### 
####   # Cache user ID check at startup
####   if [[ $(id -u) == 0 ]]; then
####     EFFECTIVE_USER_COLOR=red
####     EFFECTIVE_USER_WEIGHT=%B
####   else
####     EFFECTIVE_USER_COLOR=5
####     EFFECTIVE_USER_WEIGHT=""
####   fi
#### 
####   USER_FORMAT="${EFFECTIVE_USER_WEIGHT}%F{${EFFECTIVE_USER_COLOR}}"
####   
####   # Top-level Abstraction - cache static values
####   MYUSER="$USER_FORMAT%n($(id -u))%f%b"
####   HOSTNAME="%F{green}%m%f"
####   TIMESTAMP="%B%F{blue}%D{%H:%M:%S}%f%b"
####   TTY="%y%f"
####   DIR="%1d"
####   END="%B%F{green}$%f%b "
####   BRANCH_SYMBOL=$'\U2387'
####   NEWLINE=$'\n'
####   
####   PS1='$TTY $TIMESTAMP $MYUSER@$HOSTNAME$(render_worktree_root)$(render_git_branch) $DIR $NEWLINE$END'
#### }
#### 
#### if [[ "$SHELL" == "/bin/zsh" ]]; then
####   setup_zsh_shell
#### fi

# Optimized git prompt – no external git calls, cached between prompts/dirs
typeset -g _git_prompt_branch=""
typeset -g _git_prompt_gitdir=""
typeset -g _git_prompt_head_mtime=0
typeset -g PROMPT_GIT=""
typeset -g PROMPT_WTR=""
typeset -g BRANCH_SYMBOL=$'\U2387' # same symbol

# Find the repository’s .git directory (supports worktrees)
__find_git_dir() {
  emulate -L zsh -o no_aliases
  local d=$PWD p
  while [[ $d != / ]]; do
    if [[ -e $d/.git ]]; then
      if [[ -d $d/.git ]]; then
        REPLY=$d/.git; return 0
      else
        read -r p < $d/.git
        p=${p#gitdir: }
        [[ $p != /* ]] && p=$d/$p
        REPLY=$p; return 0
      fi
    fi
    d=${d:h}
  done
  return 1
}

# Update cached branch info; avoids calling `git`
__update_git_prompt() {
  emulate -L zsh -o no_aliases
  local headfile mtime head ref b

  if __find_git_dir; then
    if [[ $_git_prompt_gitdir != $REPLY ]]; then
      _git_prompt_gitdir=$REPLY
      _git_prompt_head_mtime=0
    fi
  else
    _git_prompt_gitdir=""
    _git_prompt_branch=""
    PROMPT_GIT=""
    return 0
  fi

  headfile=$_git_prompt_gitdir/HEAD

  # Cheap mtime check (if zsh/stat is available)
  if zmodload -i zsh/stat 2>/dev/null; then
    local -A S; zstat -H S +mtime -- "$headfile" 2>/dev/null || S[mtime]=-1
    mtime=${S[mtime]}
    if [[ $mtime == $_git_prompt_head_mtime ]]; then
      PROMPT_GIT=${_git_prompt_branch:+$BRANCH_SYMBOL $_git_prompt_branch }
      return 0
    fi
    _git_prompt_head_mtime=$mtime
  fi

  if read -r head < "$headfile"; then
    if [[ $head == ref:\ * ]]; then
      ref=${head#ref: }
      b=${ref:t}
    else
      # Match original behavior: show "HEAD" for detached state
      b="HEAD"
    fi
    _git_prompt_branch=$b
    PROMPT_GIT=${_git_prompt_branch:+$BRANCH_SYMBOL $_git_prompt_branch }
  else
    _git_prompt_branch=""
    PROMPT_GIT=""
  fi
}

# Update worktree root indicator (same functionality)
__update_worktree_root() {
  emulate -L zsh -o no_aliases
  if [[ ${PWD:h:t} == branches ]]; then
    PROMPT_WTR=" ⌅ ${PWD:h:h:t} "
  else
    PROMPT_WTR=""
  fi
}

setup_zsh_shell() {
  setopt interactivecomments PROMPT_SUBST

  # Cache EUID (no subprocess) and colorize root
  local uid=$EUID
  if (( uid == 0 )); then
    EFFECTIVE_USER_COLOR=red
    EFFECTIVE_USER_WEIGHT=%B
  else
    EFFECTIVE_USER_COLOR=5
    EFFECTIVE_USER_WEIGHT=""
  fi

  USER_FORMAT="${EFFECTIVE_USER_WEIGHT}%F{${EFFECTIVE_USER_COLOR}}"
  typeset -g MYUSER="${USER_FORMAT}%n(${uid})%f%b"
  typeset -g HOSTNAME="%F{green}%m%f"
  typeset -g TIMESTAMP="%B%F{blue}%D{%H:%M:%S}%f%b"
  typeset -g TTY="%y%f"
  typeset -g DIR="%1d"
  typeset -g END=$'\n'"%B%F{green}$%f%b "
  typeset -g NEWLINE=$'\n'

  # Compute initial prompt parts
  __update_worktree_root
  __update_git_prompt

  # Hooks: refresh prompt parts only when needed
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd   __update_worktree_root
  add-zsh-hook chpwd   __update_git_prompt
  add-zsh-hook precmd  __update_worktree_root
  add-zsh-hook precmd  __update_git_prompt

  PS1='${TTY}${TIMESTAMP} '"${MYUSER}"'@'"${HOSTNAME}"'${PROMPT_WTR}${PROMPT_GIT} '"${DIR}"' '"${END}"
}

# Initialize only under zsh
if [[ -n ${ZSH_VERSION-} ]]; then
  setup_zsh_shell
fi

