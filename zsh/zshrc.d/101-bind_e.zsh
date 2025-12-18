# enables emacs emulation keymap for ops by the current command to map literal ^A sent by tmux into a CTRL-A command sequence
# emacs mode is the default mode for bash shells see `man -P 'less -p"^ +Readline Notation"' bash``
# fixes C-a and C-e readline control sequences while in tmux
# providing a readline-compatible environment
# see man zshzle
# bindkey [ options ] [ in-string ]
# translates to 
# bindkey -e ^A
bindkey -e
