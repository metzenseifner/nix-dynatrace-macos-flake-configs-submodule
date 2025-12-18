# Orgmode & Markdown Browser Preview

This extension adds browser preview functionality to nvim-orgmode that also works with markdown files.

## Features

- **One-time Preview**: Generate and open HTML in your browser once
- **Live Preview**: Auto-refresh browser view when you save the file
- Supports both `.org` and `.md` files
- Uses pandoc for conversion with elegant CSS styling
- Cross-platform (macOS, Linux, Windows)

## Requirements

- [Pandoc](https://pandoc.org/) installed and available in PATH
- A web browser

## Usage

### Commands

```vim
:OrgPreview          " One-time preview in browser
:OrgPreviewLive      " Live preview with auto-refresh on save
:OrgPreviewStop      " Stop live preview for current buffer
```

### Keymaps

When editing `.org` or `.md` files:

- `<leader>mp` - Open one-time preview in browser (`,mp` by default)
- `<leader>mP` - Start live preview (auto-refresh every 2 seconds) (`,mP` by default)
- `<leader>ms` - Stop live preview (`,ms` by default)

(Default leader key is `,`. The `m` stands for "markdown/markup")

## How It Works

### One-time Preview

1. Converts current file to HTML using pandoc
2. Generates a temporary HTML file with embedded CSS
3. Opens the file in your default browser

### Live Preview

1. Same as one-time preview for initial generation
2. Sets up a `BufWritePost` autocmd to regenerate HTML on save
3. Browser auto-refreshes every 2 seconds via meta refresh tag
4. Manual refresh also works if you prefer

## Examples

### Preview an orgmode file

```vim
" Open test.org
:e test.org

" Preview it
,mp

" Or start live preview
,mP

" Make changes and save - browser will auto-update
:w

" Stop live preview when done
,ms
```

### Preview a markdown file

```vim
" Works exactly the same for .md files
:e README.md
,mp
```

## Tips

- Live preview keeps the same temporary file, so your browser history won't be cluttered
- The HTML is self-contained with embedded CSS, so it looks good offline
- Stop live preview when switching files to avoid unnecessary regeneration
- Use `:OrgPreview` for quick checks, `:OrgPreviewLive` when actively editing

## Troubleshooting

**Preview doesn't open**
- Check that pandoc is installed: `pandoc --version`
- Check that your browser is set as default application for HTML files

**HTML looks unstyled**
- Check that the template and CSS files exist:
  - `~/.config/nvim/lua/plugins/orgmode/easy_template.html.template`
  - `~/.config/nvim/lua/plugins/orgmode/elegant_boostrap.css`

**Live preview not updating**
- Save the file (`:w`) to trigger regeneration
- Check `:messages` for any pandoc errors
- Stop and restart live preview: `,ms` then `,mP`
