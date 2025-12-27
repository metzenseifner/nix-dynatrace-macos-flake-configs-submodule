# Order matters: Put your fpath, autoload, and compdef lines before compinit (or re-run compinit once you’ve added them).
#completions=~/.config/zsh/completions
#fpath=($completions $fpath)
#zstyle ':completion:*' menu select
#zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Optimization: Add caching with dump file check (regeneration once per day)
# how it works: compinit is ZSH checking the cached .zcompdump to see if it needs regenerating.
# so we do it once per day only
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  # Skip security checks (-C) and stat calls for maximum speed
  compinit -C
fi

# if test -d ~/.config/zsh/zsh.d/autocompletion.d; then
#   for script in ~/.config/zsh/zshrc.d/*.zsh; do
#     test -r "$script" && . "$script"
#   done
#   unset script
# fi


#  enable_color = "\033[$INFOm"
#  disable_color = $reset
