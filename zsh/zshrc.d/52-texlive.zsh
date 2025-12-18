# TexLive paths - only if system installation exists
# Binary path is added in 00-paths.zsh
TEXLIVE=/usr/local/texlive/current
[[ -d $TEXLIVE/texmf-dist/doc/man ]] && export MANPATH=$TEXLIVE/texmf-dist/doc/man:$MANPATH
[[ -d $TEXLIVE/texmf-dist/doc/info ]] && export INFOPATH=$TEXLIVE/texmf-dist/doc/info:$INFOPATH
