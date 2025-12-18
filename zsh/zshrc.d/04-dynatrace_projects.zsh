BITBUCKET_DIR="$HOME/devel/dynatrace_bitbucket"
PLATINUM_PROJECTS="$BITBUCKET_DIR/02_TEAM_PLATINUM_PROJECTS/worktrees"
ACE_MONACO_DIR="$BITBUCKET_DIR/00_DYNATRACE_CLOUD_APP_INFRA/com-dynatrace-ace-monitoring-configuration/branches"

function bitbucket() {
  cd "$BITBUCKET_DIR"
}
function wts() {
  cd "$PLATINUM_PROJECTS"
}

function mon() {
  cd "$ACE_MONACO_DIR"
}
