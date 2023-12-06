# dotfiles

Each top-level directory is a GNU stow "package". To install dotfiles for vim, for example, run:

```
$ stow --target=$HOME --restow vim
```

which will alias `vim/.vimrc` as `~/.vimrc`. This will fail if the file already exists, in which
case you should verify and delete the target.

Note that stow will create a directory symlink if the package contains a subdirectory which doesn't
exist in the destination, rather than per-file links.
This is actually required for Karabiner, which will clobber `karabiner.json` if it is directly
symlinked. This means the entire `~/.config/karabiner` must be deleted before linking with stow.

