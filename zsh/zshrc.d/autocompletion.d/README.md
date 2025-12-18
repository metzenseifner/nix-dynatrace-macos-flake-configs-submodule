The plugins in zinit.plugins is from a ZSH plugin that manages 

https://github.com/zdharma-continuum/zinit


# Adding plugins

If you want to source *local* or *remote* files (using direct URL), you can do so with snippet.

```
zinit snippet <URL>
zinit snippet https://gist.githubusercontent.com/hightemp/5071909/raw/
```

Example

# Plugin history-search-multi-word loaded with investigating.
zinit load zdharma-continuum/history-search-multi-word

# Two regular plugins loaded without investigating.
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

# Snippet
zinit snippet https://gist.githubusercontent.com/hightemp/5071909/raw/
