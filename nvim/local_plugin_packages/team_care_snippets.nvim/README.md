# Team Care Snippets Plugin

A LuaSnip plugin that automatically generates snippets for team members based on the `team_care.yml` configuration file.

## Features

- Reads team member data from `~/.config/yaml-supplier/team_care.yml`
- Creates snippets for "all" filetypes
- Each team member gets a snippet with their name as a trigger (lowercase with dashes)
- Snippets provide multiple choices:
  1. Just the name
  2. Name with roles in parentheses (if roles exist)
  3. Name with special engagements in parentheses (if special engagements exist)
  4. Name with both roles and special engagements (if both exist)

## Usage

When editing any file, type a team member's name (lowercase with dashes instead of spaces) and expand the snippet:

- `jonathan-komar` → cycle through:
  - "Jonathan Komar"
  - "Jonathan Komar (Team Captain)"
  
- `nikolas-keuck` → cycle through:
  - "Nikolas Keuck"
  - "Nikolas Keuck (PO)"

- `dominick-einkemmer` → cycle through:
  - "Dominick Einkemmer"
  - "Dominick Einkemmer (Security Advocate)"

## Requirements

- LuaSnip plugin
- `yq` command-line tool for YAML parsing
- Team configuration file at `~/.config/yaml-supplier/team_care.yml`

## Configuration

The plugin reads from the existing `team_care.yml` file. No additional configuration needed.
