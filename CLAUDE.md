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

`aerospace`, `sketchybar`, and `karabiner` are tightly coupled and edited together:

- **aerospace** (`aerospace/.config/aerospace/aerospace.toml`) is the tiling WM. Modifiers in its bindings are what AeroSpace sees *after* karabiner's remapping (e.g. command-arrow becomes alt-arrow) — keep the two in sync. `exec-on-workspace-change` fires `sketchybar --trigger aerospace_workspace_change`, the event that drives the bar. Bindings invoke helper scripts by absolute `~/`-installed path (`/Users/revan/.config/aerospace/*.sh`).
- **flows** (`aerospace/.config/aerospace/flow.sh`) are named sets of workspaces, one active at a time. A flow `<f>` owns workspaces `<f>.1`–`<f>.10`, created on demand (so no `persistent-workspaces`); slots 1–6 go to the main monitor, 7–10 to the secondary, enforced by the script rather than a static `[workspace-to-monitor-force-assignment]`. State lives in `~/.local/state/aerospace/`; the script fires `sketchybar --trigger flow_change` on flow changes. Scratchpad stash workspaces (`aerospace/.config/aerospace/scratchpad.sh`) have no dot in the name — the dot is what marks a workspace as belonging to a flow.
- **sketchybar** (`sketchybar/.config/sketchybar/`) is the status bar. `sketchybarrc` sources `colors.sh`/`icons.sh` and wires up `items/` (definitions) which reference `plugins/` (scripts that produce the actual content). `items/aerospace.sh` creates ten static slot items plus the flow strip; hidden controller items render everything in one atomic pass via `plugins/aerospace.sh` (slots, per-monitor pinning/brackets) and `plugins/flows.sh` (flow strip), reacting to the triggers above. Plugin scripts must stay bash 3.2-compatible (no associative arrays).
- **yabai + skhd** (`yabai/`) and the unsourced `items/{yabai,spaces,apps}.sh` / `plugins/{yabai,space,app}.sh` are the legacy pre-aerospace stack — still in the repo but inactive; don't edit them for current behavior.

## nvim

`nvim/` is a [LazyVim](https://lazyvim.github.io) config. Plugin versions are pinned in `lazy-lock.json`. Personal config lives in `lua/config/` (`options.lua`, `keymaps.lua`, `autocmds.lua`) and `lua/plugins/`. Lua is formatted with stylua (`stylua.toml`).

## Note

Two terminal configs coexist (`alacritty/`, `ghostty/`) and two editors (`vim/`, `nvim/`); `i3/` is for Linux. Edit the one relevant to the change rather than assuming a single source of truth.
