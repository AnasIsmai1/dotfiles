# dotfiles

My Linux and macOS setup, managed with GNU Stow. One repo, two bootstrap paths,
and a lockfile so I can tell what drifted between machines.

Originally built on WSL Ubuntu with a Hyprland desktop on bare metal, then
carried over to macOS. Both are still supported.

## Install

Linux:

```sh
git clone https://github.com/AnasIsmai1/dotfiles.git ~/dotfiles
~/dotfiles/pkg-install.sh    # apt packages that back the configs
~/dotfiles/install.sh        # stow everything into $HOME
```

macOS:

```sh
xcode-select --install       # do this first
git clone https://github.com/AnasIsmai1/dotfiles.git ~/dotfiles
~/dotfiles/mac-install.sh --dry-run
~/dotfiles/mac-install.sh
```

`MAC-MIGRATION.md` has the long version, including the parts that need a secret
and therefore are not automated.

## Layout

Every top-level directory is a Stow package laid out relative to `$HOME`:

```
hypr/.config/hypr/hyprland.conf  ->  ~/.config/hypr/hyprland.conf
zsh/.zshrc                       ->  ~/.zshrc
```

`install.sh` stows them in order. Anything already living at the target path
gets backed up to `<path>.bak.<timestamp>` rather than clobbered.

## What is in here

Shell and terminal: zsh, starship, tmux, sesh, alacritty, kitty, atuin.

Desktop (Hyprland stack): hypr, waybar, walker, swayosd, mako, fontconfig.

Dev tools: nvim, lazygit, mise, git, ssh, gh, gh-dash, btop, claude, agents.

Package lists live in `Brewfile` (77 formulae), `Brewfile.casks` (31 casks), and
the `PACKAGES` array in `pkg-install.sh` for apt.

## Keeping machines in sync

```sh
./pkg-dump.sh
```

Snapshots every package manager on the box into `packages.lock`. Run it before a
machine move and `git diff packages.lock` shows exactly what changed. Managers
with nothing installed still get a section header, because an empty section is
information and a missing one is ambiguity.

## Conventions

The install scripts deliberately do not use `set -e`. Every step is wrapped so
one failure does not abort the rest: a half-installed machine you can inspect
beats a script that died on step 3. They are idempotent, so re-running is safe,
and nothing requiring a secret is automated. Those steps get printed at the end
for you to do by hand.

## License

MIT
