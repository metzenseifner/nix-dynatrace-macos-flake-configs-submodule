" Syntax highlighting for Confluence pages
if exists("b:current_syntax")
  finish
endif

" Markdown-like syntax for better Confluence editing
runtime! syntax/markdown.vim

" Confluence-specific highlights
syntax match confluenceHeading1 /^# .*$/
syntax match confluenceHeading2 /^## .*$/  
syntax match confluenceHeading3 /^### .*$/
syntax match confluenceHeading4 /^#### .*$/

syntax region confluenceBold start=/\*\*/ end=/\*\*/
syntax region confluenceItalic start=/\*/ end=/\*/
syntax region confluenceCode start=/`/ end=/`/

" Highlight common Confluence macros
syntax match confluenceMacro /{[^}]*}/

" Colors
highlight default link confluenceHeading1 Title
highlight default link confluenceHeading2 Title
highlight default link confluenceHeading3 Title  
highlight default link confluenceHeading4 Title
highlight default link confluenceBold Bold
highlight default link confluenceItalic Italic
highlight default link confluenceCode String
highlight default link confluenceMacro Special

let b:current_syntax = "confluence"