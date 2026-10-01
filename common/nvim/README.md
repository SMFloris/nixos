# Neovim

Personal Neovim configuration managed by Home Manager through the custom
`programs.neonix` wrapper. The generated config is linked to `~/.config/nvim`;
edit the files in this directory, then run `./rebuild.sh switch` from the
repository root.

## Layout

- `init.lua` — entry point and lazy.nvim bootstrap.
- `lua/flow/` — editor options, keymaps, formatting, and shared behavior.
- `lua/plugins/` — one lazy.nvim specification per feature or plugin.
- `.packages` — Nix packages installed in the isolated Neovim profile.
- `lazy-lock.json` — pinned plugin revisions.

The setup uses `mini.nvim` and `snacks.nvim` for many of its editor utilities;
their configuration lives in `lua/plugins/mini.lua` and
`lua/plugins/snacks.lua`.

The leader key is `Space`. Press it and wait for WhichKey to discover the
available mappings. Use `:Lazy` to inspect plugins and `:checkhealth` when
troubleshooting Neovim, providers, or language servers.
