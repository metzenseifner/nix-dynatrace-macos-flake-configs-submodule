return {
  s("bug-argowf-exitSignalReceived-template", fmt([[
# Error
- What was the duration of the Argo Workflow process?

- When did the Argo Workflow start and stop?

- Why did it stop? timeout or cancelation?

- Who triggered the Argo Workflow?

- What was the last phase to have been merged before the failed state (usually current phase -1 because the current phase's checkInstallation step fails due to previous phase)?
  See [Promotion Phases](https://dt-rnd.atlassian.net/wiki/x/6oFAB)
- Which were the last ArgoCD Applications in state "Unhealthy" at the time of process termination?
  `<argo.path>::<commit_id>`

- Are the commits (and stage) the same as in another bug and that other bug has been closed (indicates possible duplication)?
  ]], {}, {delimiters="{}"}))
}
