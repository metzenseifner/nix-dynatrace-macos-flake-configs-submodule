### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Run following after sourcing zinit.zsh because loaded zinit.sh after enabling compinit
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

PLUGINS_FILE=~/.config/zsh/zshrc.d/autocompletion.d/zinit.plugins
SNIPPETS_FILE=~/.config/zsh/zshrc.d/autocompletion.d/zinit.snippets

typeset -g ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE='20'

# (@f) are "parameter expansion flags". f splits the result into separate "words" at line breaks
# @ ensures that the result of expansion is split into separate words even when quoted.
# The quoting itself ensures that empty strings '' are not dropped, so you usually want both @ and the quoting.
# To elide empty lines, simply remove the @
# The $(<file) syntax is an extension of command substitution syntax that simply reads the contents of a file, like $(cat file) but without spawning external process.
typeset -a plugins=("${(@f)"$(<$PLUGINS_FILE)"}")
for plugin in "${plugins[@]}"; do
  # Skip empty lines and comments
  [[ -z "$plugin" || "$plugin" =~ ^[[:space:]]*# ]] && continue
  # Load with turbo mode for deferred loading
  zinit ice wait lucid
  zinit load "$plugin"
done

typeset -a snippets=("${(@f)"$(<$SNIPPETS_FILE)"}")
for snippet in "${snippets[@]}"; do
  # Skip empty lines and comments
  [[ -z "$snippet" || "$snippet" =~ ^[[:space:]]*# ]] && continue
  zinit snippet "$snippet"
done

#typeset -a snippets=("${(@f)}"$(<zinit.snippets)"}")
#for snippet in "${snippets}"; do
#  zinit snippet "${snippet}"
#done

#zinit load felixr/docker-zsh-completion
#zinit load xlshiz/gitfast-zsh-plugin
#zinit load completion/git-completion.zsh
#
#
#

