function git() {
  [[ ${#} -eq 0 ]] && command git && return
  subcommand=$1
  shift
  case $subcommand in
    tree) command git log --oneline --graph --all --no-decorate "$@" ;;
    branch) command git branch -vv "$@" ;;
    remote) command git remote -v "$@" ;;
    blame) command git blame -l "$@" ;;
    fullclean) command git clean -fdx "$@" ;;
    merge-base) command git merge-base "$@" ;; # Just here to remember
    tagls) command git tag -l --format="%(objectname)  %(align:width=30,left)%(refname:strip=2)%(end)  %(tagger)" "$@" ;;
    logtag) command git log --tags --pretty="format:%H %<(15,trunc)%S %<(30,trunc)%cn %<(30,trunc)%ci" --no-walk "$@" ;;  # --tags: treat refs/tags as <commit>s
    *) command git $subcommand "$@" ;;
  esac
}
#status) command git status -sb "$@";;
#log) command git --no-pager log --date=local --color=always --reverse --pretty=format:'%Cred%<(12,trunc)%ci%Creset::%H::%<(15,trunc)%aN:%Cblue%D%Creset: %Cgreen%s%Creset' "$@" && echo ;;
#diff-tree) command git --no-pager diff-tree --no-commit-id --name-only "$@" ;;
