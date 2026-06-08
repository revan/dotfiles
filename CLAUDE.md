# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Structure

Each top-level directory is a [GNU stow](https://www.gnu.org/software/stow/) "package". Within a package, files are laid out relative to `$HOME` — e.g. `fish/.config/fish/config.fish` is installed to `~/.config/fish/config.fish`, and `vim/.vimrc` to `~/.vimrc`. When adding a file, mirror the real target path inside the package directory.

## Installing / linking

```sh
stow --target=$HOME --restow <package>   # e.g. fish, nvim, yabai
```

Stow fails if a target file already exists (not a symlink) — verify and delete the target first. Stow creates a *directory* symlink when a package subdirectory doesn't exist in the destination, rather than per-file links. Karabiner depends on this: it clobbers a directly-symlinked `karabiner.json`, so `~/.config/karabiner` must be deleted entirely before stowing.

## Window-management stack (macOS)

`yabai`, `sketchybar`, and `karabiner` are tightly coupled and edited together:

- **yabai** (`yabai/.yabairc`) is a bsp tiling WM. It reserves space for the bar via `external_bar` and emits signals (`window_focused`, `window_created`, `window_destroyed`) that call `sketchybar --trigger ...`.
- **skhd** (`yabai/.skhdrc`) holds the keybindings that drive yabai. Many space-switch bindings also fire `sketchybar --trigger windows_on_spaces` to keep the bar in sync. Helper scripts `yabai/stack.sh` and `yabai/scratchpad.sh` are invoked from bindings (note: bindings may reference absolute `~/`-installed paths like `/Users/revan/stack.sh`).
- **karabiner** remaps keys *before* skhd sees them (e.g. command-arrow becomes alt) — keep skhd's expected modifiers consistent with karabiner's remapping.
- **sketchybar** (`sketchybar/.config/sketchybar/`) is the status bar. `sketchybarrc` sources `colors.sh`/`icons.sh` and wires up `items/` (definitions) which reference `plugins/` (scripts that produce the actual content, often reacting to the yabai triggers above).

## nvim

`nvim/` is a [LazyVim](https://lazyvim.github.io) config. Plugin versions are pinned in `lazy-lock.json`. Personal config lives in `lua/config/` (`options.lua`, `keymaps.lua`, `autocmds.lua`) and `lua/plugins/`. Lua is formatted with stylua (`stylua.toml`).

## Note

Two terminal configs coexist (`alacritty/`, `ghostty/`) and two editors (`vim/`, `nvim/`); `i3/` is for Linux. Edit the one relevant to the change rather than assuming a single source of truth.
