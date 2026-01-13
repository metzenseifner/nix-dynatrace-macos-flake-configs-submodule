# Python venv path is managed by home.sessionPath in home.nix
# Nix manages Python installations - no need to activate venv at startup
# Use `source ~/.local/share/python/venvs/py3.12.2/bin/activate` manually if needed

# Save PS1 before virtualenv activation and restore after
_SAVED_PS1="$PS1"
export VIRTUAL_ENV_DISABLE_PROMPT=1
source ~/.local/share/python/venvs/py3.12.2/bin/activate
PS1="$_SAVED_PS1"
unset _SAVED_PS1


### # The following on-demand activation does not work with shebangs
### # Point to your venv's activate script and derive its bin dir
### typeset -g VENV_ACTIVATE="$HOME/.local/share/python/venvs/py3.12.2/bin/activate"
### typeset -g VENV_BIN="${VENV_ACTIVATE:h}"
### 
### __venv_call() {
###   # emulate zsh Resets Zsh’s option set (behavior flags) to the defaults for “native zsh.” 
###   # -L Makes any option changes local to this function call.
###   # -o no_aliases disables alias expansion inside the function
###   emulate -L zsh -o no_aliases
###   local exe="$1"; shift
###   # If some other venv is already active, respect it
###   if [[ -n $VIRTUAL_ENV ]]; then
###     command "$exe" "$@"
###     return
###   fi
###   # Otherwise, route to your fixed venv if the tool exists there
###   if [[ -n $VENV_BIN && -x "$VENV_BIN/$exe" ]]; then
###     command "$VENV_BIN/$exe" "$@"
###   else
###     echo "Using native system's python"
###     command "$exe" "$@"
###   fi
### }
### 
### # Route common Python tools through the nearest venv if present
### python()  { __venv_call python  "$@"; }
### python3() { __venv_call python3 "$@"; }
### pip()     { __venv_call pip     "$@"; }
### pip3()    { __venv_call pip3    "$@"; }
### pytest()  { __venv_call pytest  "$@"; }
