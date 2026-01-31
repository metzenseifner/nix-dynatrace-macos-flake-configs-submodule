#!/usr/bin/env bash
cat <<'EOF'
nix store gc --print-roots      # show roots
nix store gc --print-live       # show live store paths
nix store gc --print-dead       # show what would be collectable
# Finally, you can remove old generations
nix profile wipe-history --older-than 30d --dry-run
# Now that old profile generations are gone, you can free the unreachable stuff from /nix/store:
nix store gc
EOF
