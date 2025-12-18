export KUBECONFIG=~/.config/kubectl/config
function watchPods() {
  # any state change gets a new line like a log
  kubectl get pods -w
}
function install() {
  kubectl create deployment httpenv --image=brewfisher/httpenv
}
#function setReplicas() {
#  kubectl scale deployment httpenv --replicas=10
#}
function getServices() {
  kubectl get service
}
function getAPIresource() {
  kubectl get ingress # ingresses, ingressing
}
