function update_local_chart_cache() {
  helm repo update
}
function list_all_available_charts() {
  helm search repo
  # also helm search repo <search-string>
}
function list_all_available_chart_versions() {
  helm search repo -l
}
function list_avail_charts_on_repo_bitname() {
  helm search repo bitnami -l
}
function list_latest_charts_on_repo_bitname() {
  helm search rpeo bitnami
}

function list_all_config_properties() {
  local chart=$1
  helm show values $chart
  unset chart
}
