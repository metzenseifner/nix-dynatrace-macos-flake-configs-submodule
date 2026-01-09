" Argo Workflows syntax highlighting
" Extends YAML syntax with Argo-specific keywords

runtime! syntax/yaml.vim

" Argo Workflows resource kinds
syn keyword argoKind WorkflowTemplate Workflow ClusterWorkflowTemplate CronWorkflow
syn keyword argoStepType steps dag suspend container script resource

" Argo Workflows specific fields
syn keyword argoField templates entrypoint arguments parameters artifacts inputs outputs
syn keyword argoField steps dag tasks dependencies when withItems withParam withSequence
syn keyword argoField retryStrategy backoff limit retryPolicy
syn keyword argoField activeDeadlineSeconds podSpecPatch serviceAccountName
syn keyword argoField archiveLocation onExit hooks
syn keyword argoField suspend duration
syn keyword argoField synchronization semaphore mutex
syn keyword argoField metrics prometheus

" Highlight groups
hi def link argoKind Type
hi def link argoStepType Statement
hi def link argoField Identifier
