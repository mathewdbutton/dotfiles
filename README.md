# dotfiles

```sh
./install
```

Symlinks everything into place and asks for this machine's git email.
Safe to re-run.

`shell/aliases` is one file that is valid fish *and* zsh; `install` checks
`$SHELL` and wires it up whichever way that shell wants. `zsh/` is zsh-only,
and skipped under fish.

| | |
| --- | --- |
| `git/config` | git aliases → `~/.config/git/config` |
| `shell/aliases` | shell aliases → wherever `$SHELL` wants them: fish's `conf.d`, or `~/.config/zsh/` plus a `source` line in `~/.zshrc` |
| `zsh/keybindings` | emacs line editing, prefix history search → `~/.config/zsh/`, sourced from `~/.zshrc` |
| `zsh/history` | a history worth searching → `~/.config/zsh/`, sourced from `~/.zshrc` |
| `tmux/tmux.conf` | → `~/.config/tmux/tmux.conf` |
| `bin/` | scripts → `~/.local/bin` |
| `hammerspoon/` | audio output toggle on Shift+PageUp → `~/.hammerspoon/` (macOS only) |

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
| `fish` or `zsh` | `shell/aliases` (whichever is `$SHELL`) |
| Hammerspoon | `hammerspoon/` — macOS only, `brew install --cask hammerspoon` |

Everything else these use is POSIX, so they behave the same on macOS and Linux;
`install` skips `hammerspoon/` anywhere that isn't macOS.
