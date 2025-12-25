# Optimize compinit with caching - only regenerate once per day
# Skip security checks (-C) and stat calls for maximum speed
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Enable completion system
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Shell aliases
alias devel="cd ~/devel"
alias info="info --vi-keys"
alias haskell="cd ~/devel/haskell_projects/scripts"
alias api="cd ~/devel/dynatrace_bitbucket/12_DYNATRACE_API"
alias care="cd ~/devel/dynatrace_bitbucket/15_TEAM_CARE_PROJECTS"
alias wh="which"

# Environment variables
export LC_ALL=en_US.UTF-8
export EDITOR=nvim
export VIMCONFIG=~/.local/share/nvim/site
export GPG_TTY=$(tty)
export BROWSER="firefox developer edition"

# Load modular zsh configs from ~/.config/zsh/zshrc.d/
if [ -d ~/.config/zsh/zshrc.d ]; then
  for file in ~/.config/zsh/zshrc.d/*.zsh(N); do
    source "$file"
  done
  
  # Load autocompletion configs
  if [ -d ~/.config/zsh/zshrc.d/autocompletion.d ]; then
    for file in ~/.config/zsh/zshrc.d/autocompletion.d/*.zsh(N); do
      source "$file"
    done
  fi
fi

# Defer heavy integrations for faster startup
# Direnv - load after prompt with chpwd hook for better startup time
if (( $+commands[direnv] )); then
  _direnv_hook() {
    trap -- "" SIGINT
    eval "$("${pkgs.direnv}/bin/direnv" export zsh)"
    trap - SIGINT
  }
  typeset -ag precmd_functions
  if [[ -z "''${precmd_functions[(r)_direnv_hook]+1}" ]]; then
    precmd_functions=(_direnv_hook $precmd_functions)
  fi
  typeset -ag chpwd_functions
  if [[ -z "''${chpwd_functions[(r)_direnv_hook]+1}" ]]; then
    chpwd_functions=(_direnv_hook $chpwd_functions)
  fi
fi

# Defer syntax highlighting and autosuggestions for faster startup
# Load them asynchronously after the prompt is displayed
if (( $+commands[zinit] )); then
  # Use zinit turbo mode for deferred loading
  zinit ice wait lucid atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay"
  zinit light zdharma-continuum/fast-syntax-highlighting
  
  zinit ice wait lucid atload"!_zsh_autosuggest_start"
  zinit light zsh-users/zsh-autosuggestions
else
  # Fallback to nix-managed plugins if zinit not available
  source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh &!
  source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh &!
fi
