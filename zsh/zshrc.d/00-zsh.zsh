# Order matters: Put your fpath, autoload, and compdef lines before compinit (or re-run compinit once you’ve added them).
completions=~/.config/zsh/completions
fpath=($completions $fpath)

# Enable Autocompletion
autoload -Uz compinit && compinit


# if test -d ~/.config/zsh/zsh.d/autocompletion.d; then
#   for script in ~/.config/zsh/zshrc.d/*.zsh; do
#     test -r "$script" && . "$script"
#   done
#   unset script
# fi


#  enable_color = "\033[$INFOm"
#  disable_color = $reset
declare -A colors
colors=(
  [red]='\u001b[31m'
  [green]='\u001b[32m'
)
reset='\033[0m'

function log() {
  msg=$1
  level=${2-INFO}
  green=$colors[green]
  echo -e "${green}==> $reset$msg"
}
