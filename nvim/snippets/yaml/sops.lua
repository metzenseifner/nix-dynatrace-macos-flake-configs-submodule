return {
  s("sops", fmt([[
---
# A set of public keys (rage-keygen -y $SOPS_AGE_KEY_FILE)
keys:
  - &some_public_key
    age123

# Who may decrypt which filepaths
creation_rules:
  - path_regex: .*\.sops\.(yaml|yml)$
    key_groups:
      - age:
          - *some_public_key

  ]], {}, {}))
}
