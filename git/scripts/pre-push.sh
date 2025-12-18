#!/usr/bin/env bash

WORKTREE_HOOKS_DIR=$(git rev-parse --show-toplevel)/hooks

# This works because the list of refs being pushed is passed on standard input
if [[ `grep 'null'` ]]; then 
  echo "You really do not want to push this branch. Aborting."
  exit 1
fi

# Check if the hook exists in the worktree hooks directory
if [ -x "$WORKTREE_HOOKS_DIR/pre-push" ]; then
    echo "INFO Found $WORKTREE_HOOKS_DIR/pre-push. Executing."
    # Execute the worktree hook
    exec "$WORKTREE_HOOKS_DIR/pre-push" "$@"
else
    # Execute the global hook
    echo "INFO Completed pre-push. No hook under $WORKTREE_HOOKS_DIR/pre-push found. Exiting."
fi
