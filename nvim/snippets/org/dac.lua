local procedure = [=[
*** Procedure

  1. Check if all cluster prerequisites in terms of infrastructure and base platform services are in place (+ healthy and synced)
  - *Q: Is the cluster up and running?*
    - [ ] Check K8s dtp-*-dac Cluster on target ArgoCD is healthy / onboarded. ArgoCD -> Settings -> Clusters -> Search e.g. "dtp-dev104-dac"

      Examples
         - Prod Clusters https://argo-cd.dtp.cd.internal.dynatrace.com/settings/clusters 
         - Hard Clusters  https://argo-cd.dtp.cd.internal.dynatracelabs.com/settings/clusters
         - Dev Clusters  https://argo-cd.dtp.cd.internal.dynatracelabs.com/settings/clusters

  - *Q: Which base platform services must be in place?*
     Check ArgoCD services health: Applications -> Search keywords
    - [ ]  kube-system (cluster-autoscaler (AWS-only), dns-metrics (both AWS and Azure, will be onboarded with promotion)) => if missing, check promotion PR 3.5.1 because it includes kube-system. provided that cluster specific configs are in place => the initial promotion will onboard it.
      - [ ] cluster-autoscaler required before SRE Handover example PR: https://github.com/dynatrace-infrastructure/dtp-state-prod/pull/37411
    - [ ]  Istio Control Plane => missing, but cluster specific configs are in place => so the initial promotion will it onboard
    - [ ]   Istio Gateways => missing, but cluster specific configs are in place => so the initial promotion will it onboard
    - [ ]   Vault / External Secrets (also check if running by opening Web UI, uses istio -> check state repo for URL to get to installations's vault/vault-environment/values-cluster-scoped.yaml)
    - [ ]   Kafka
    - [ ]   RabbitMQ
    - [ ]   Kyverno
    - [ ]   DT SFM (self-monitoring)

  2. run promote-phases to get phased promotion PRs
       opened wtih https://argo-wf.dtp.cd.internal.dynatrace.com/workflows/dtp-gitops-orchestration-workflows/promotephases-bootstrap-workflowtemplate-zzrng?tab=workflow&uid=71d517b8-1ff8-409e-82c3-acfc38e7c855

       - https://github.com/dynatrace-infrastructure/dtp-state-prod/pull/37530 2025-06-24T13:27:36Z "[ASDY-11926] [10 CREATIONS] Promote dtp-prod6 from dtp-prod1: app/dac [PHASE-3.5.3]" dtp-orchestration-prod
       - https://github.com/dynatrace-infrastructure/dtp-state-prod/pull/37529 2025-06-24T13:27:20Z "[ASDY-11926] [7 CREATIONS / 1 UPDATES] Promote dtp-prod6 from dtp-prod1: app/dac [PHASE-3.5.1]" dtp-orchestration-prod
       - https://github.com/dynatrace-infrastructure/dtp-state-prod/pull/37528 2025-06-24T13:27:04Z "[ASDY-11926] [1 CREATIONS / 1 UPDATES] Promote dtp-prod6 from dtp-prod1: infra [PHASE-2.6]" dtp-orchestration-prod
       - https://github.com/dynatrace-infrastructure/dtp-state-prod/pull/37527 2025-06-24T13:26:49Z "[ASDY-11926] [1 UPDATES] Promote dtp-prod6 from dtp-prod1: workflow [PHASE-1.3]" dtp-orchestration-prod

      - via bootstrap workflow as the installation is not yet enabled for the submittable

      - filter for DAC related components in the workflow to only get DAC related changes

  - *Q: Which source is ideal?*
  - [ ] dev6 (or dev3 and note that because dev6 has no phases configured, you can use phases config from dev3)
       (prereq is phases
        configuration--bootstrap workflow could use dev6 as src and ref the
        phases config of dev3 since it does not have one, because dev3 is the
        first with phases the “integration stage”)

  3. merge the promotion PR either manually (there are only 4-5 PRs) or via the phased release workflow

       phase 1 merged with https://argo-wf.dtp.cd.internal.dynatrace.com/workflows/dtp-gitops-orchestration-workflows/phased-release-bootstrap-workflowtemplate-z4787?tab=workflow&uid=5e7d2852-871b-4db0-a305-87ae85899017
       phase 2 merged with 
       phase 3 merged with 


      - infra + argocd apps must be healthy and synced
  - [ ] - *Ensure new apps are in place and running “healthy and synced”.*

  4. prepare PR to enable promotion to the respective target installation
  - [ ] - *Q: How do I know when I am ready to enable auto promotion?*
          If step 2 and 3, then regular promotion can be enabled for auto promotion.*
]=]


return {
  s("dac prerequisites checklist", fmt(procedure, {}, {})),
}
