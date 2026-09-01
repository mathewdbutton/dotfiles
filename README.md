# dotfiles

```sh
./install
```

Symlinks everything into place and asks for this machine's git email.
Safe to re-run.

| | |
| --- | --- |
| `git/config` | git aliases → `~/.config/git/config` |
| `shell/aliases` | shell aliases → fish's `conf.d` (the file is valid zsh too) |
| `tmux/tmux.conf` | → `~/.config/tmux/tmux.conf` |
| `bin/` | scripts → `~/.local/bin` |

Identity and anything machine-specific lives in `~/.gitconfig`, never in this
repo. Git reads that and `~/.config/git/config`, merging the two.

## Dependencies

Install with whatever the machine uses — `apt`, `brew`, `nix`. Nothing here
breaks if one is missing; only the alias that needs it does.

| | Needed by |
| --- | --- |
| `git` | everything |
| `fzf` | `gfb`, `git rfzf` |
| `git-revise` | `git rfzf` |
| `ruby` | `bin/urlencode` (ships with macOS; a package on Linux) |
| `tmux` | `tmux/tmux.conf` |
| `fish` and/or `zsh` | `shell/aliases` |

Everything else these use is POSIX, so they behave the same on macOS and Linux.
