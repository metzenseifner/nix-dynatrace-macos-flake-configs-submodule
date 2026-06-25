# NeoVim Configuration

- Custom written plugin source code lives here: ~/.config/nvim/local_plugin_packages/
- Plugins live in a organized-by-function-usually directory structure here: ~/.config/nvim/lua/plugins/
- Prefer respecting rules of cohesion: coupled code should be near on the filesystem. Breaking that rule means we're coupling on an established high-level API.
- Code should follow functional paradigm: better to name a chunk of code something semantically relevant than to inline it. Then compose it with other functions.
