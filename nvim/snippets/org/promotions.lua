local provision_argocd_application_services_procedure = [=[
* Provision new ArgoCD Application Services on a new Installation
** Documentation of provisioning an installation directory in a state repository - https://dt-rnd.atlassian.net/l/cp/519V3VAf
** Verify complete provisioning of a new installation
   - Check on Argo CD for "Successful" on the relevant clusters (apigw, apprt, grail, plsrv) to ensure that Argo CD can reach cluster at regular intervals.
    - prod: https://argo-cd.dtp.cd.internal.dynatrace.com/settings/clusters
    - dev: https://argo-cd.dtp.cd.internal.dynatracelabs.com/settings/clusters
    - Case: Clusters missing: Check that respective state repo contains the tenant.
    - Case: Clusters unreachable: The cluster could be not yet fully rolled out or had errors means that a prerequisite is likely missing and it we should check with team of previous step in the runbook.
      Check that the installation directory exists on the state repository.

*** TODO Check that new installation ID is captured by the deployment ring definitions.
    - Docs: Wiki https://dt-rnd.atlassian.net/l/cp/TtuwQNCP
    - Repo: dtp-tools https://bitbucket.lab.dynatrace.org/projects/PFI/repos/dtp-tools/browse/pkg/config/deployment_ring.go

** Add support in CLI Utilities for new Installation
*** TODO Check dtp-installation-template (use to generate values-cluster-scoped.yaml if possible to not have to update so many values when copying from a source ref installation.)
*** TODO dtp-tools: Update

** PR on the State Repo Create PR for cluster-scoped values.
*** TODO Copy over missing (no clobbering existing) values-cluster-scoped.yaml files from the $src/{app,workflow}$ directories or ideally generate them (once the generator supports 100% of the file, and supports both dev and prod).
#+BEGIN_src
# Multi-step procedure
# Create src set
find $SRC -name 'values-cluster-scoped.yaml' -printf '%P\0' | grep -P -z '^app|^workflow' | tr '\0' '\n' | sort -h > values-cluster-scoped.$SRC.files
# Create dest set (to avoid clobbering existing files)
find $DEST -name 'values-cluster-scoped.yaml' -printf '%P\0' | grep -P -z '^app|^workflow' | tr '\0' '\n' | sort -h > values-cluster-scoped.$DEST.files
# show files only in src set (set 1)
comm -2 -3 values-cluster-scoped.$SRC.files values-cluster-scoped.$DEST.files > values-cluster-scoped.from.$SRC.to.$DEST.files
# Install files
<values-cluster-scoped.from.$SRC.to.$DEST.files xargs -I{} install -v -D $SRC/{} $DEST/{}
# Correct installation ID in the installed files
cat values-cluster-scoped.from.$SRC.to.$DEST.files | perl -pe 's/^(.*)$/$DEST\/\1/g' | xargs perl -i -pe "s/$SRC/$DEST/g"
# Add files to git staging
git add $DEST
#+END_src

**** TODO Replace installation ID strings after copy with new destination installation ID.
#+BEGIN_src
cat values-cluster-scoped.from.$SRC.to.$DEST.files | perl -pe 's/^(.*)$/$DEST\/\1/g' | xargs perl -i -pe "s/$SRC/$DEST/g"
#+END_src

]=]

-- https://bitbucket.lab.dynatrace.org/projects/PFI/repos/dtp-installation-template/browse/templates/_helpers.tpl

local provision_argocd_application_services_procedure_old = [=[
** Documentation of provisioning argo services on a new installation in a state repository - https://dt-rnd.atlassian.net/l/cp/hR7gnRM1
** TODO Wait for PR approval on state prod / waiting on maintenance window
** TODO Copy over any missing value-scoped.yaml files from AWS template dtp-prod1 according to promotion workflow. $ comm -2 -3 ../dtp-prod1.files ../dtp-prod18.files | xargs -I{} bash -c 'mkdir -p dtp-prod18/app/$(dirname {}); cp dtp-prod1/app/{} dtp-prod18/app/{}'

** TODO Replace all instances of dtp-prod1 with dtp-prod18 in dtp-prod18/app/**/*.yaml. Careful matching prod1 and dtp-prod1 both in URLs and standalone.

** TODO Replace URL for self-monitoring link here https://github.com/dynatrace-infrastructure/dtp-state-prod/blob/9d0912226c4f88a8e225f0dab2c0d802616773e3/dtp-prod18/app/apigw/dynatrace/self-monitoring/values-cluster-scoped.yaml#L2 with desired self-monitoring tenant. There were 3 occurrences.

** TODO Ensure installation ID can be matched by correct deployment ring regex: https://dt-rnd.atlassian.net/l/cp/TtuwQNCP (at time writing: makes no sense “ring: hardening”) continuing with assumption “ring: general-adopters” (Niko said so)

** TODO https://github.com/dynatrace-infrastructure/dtp-state-prod/pull/19026  ping @Michael Wolf

** TODO Update sslCertARN values with values from certificateARN values from dtp-prod18/values-installationid.yaml for plsrv, grail, apigw. Match URLs from mgmt, internal, external for each.

** TODO No need to update Promotion diagram for production host because it is covered by dtp-prodN.

** TODO Update dtp-orchestration CLI to support new installation dtp-prod18, also update helm chart tests (generate and run tests locally to confirm) PR https://bitbucket.lab.dynatrace.org/projects/PFI/repos/dtp-orchestration/pull-requests/859/overview

** TODO After PR merged Argo Workflows → Run the “promotephases-bootstrap-workflowtemplate” bootstrap workflow to create PRs (that trigger checks) for dtp-prod18 to “onboard new argo cd services” using dtp-prod1 as a template source, ignoring cluster-scoped values yaml i.e. make new charts and other files for the newly added argocd services.https://dt-rnd.atlassian.net/wiki/spaces/PIET/pages/71337070/DTP+Installation+Cluster+Provisioning#Onboarding-of-ArgoCD-Services. Contacted Pablo Diaz (or better #help-platform-infrastructure-services) with ArgoCD App State for issues with unhealthy argo apps.

** TODO crosscheck infra global.yaml,local.yaml replicas and replicaCount keys in k8s.

** TODO Check for missing secrets and contact Moser, Stefan for those if any.
The DOK team should rename values.json files to a conventional name that applies it only to AWS and Azure. Stefan Moser opened https://github.com/dynatrace-infrastructure/dtp-dev/pull/47073 to ensure that Argo does not try to deploy apprt on AWS clusters. This should avoid the need for dummy secret for the backend-user of apprt. Notification in #help-dok: https://dynatrace.slack.com/archives/C028HDJH4P4/p1732718393288949
]=]


return {
  s("provision-argocd-application-services-procedure",
    fmt(provision_argocd_application_services_procedure, {}, { delimiters = "[]" })),
  s("provision-installation-directory-procedure",
    fmt([[]], {}, { delimiters = "[]" })),
}
