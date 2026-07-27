# Moving this setup to a Mac

Inventory taken from the WSL Ubuntu 24.04 box on **2026-07-28**.

## Quick version

```sh
git clone https://github.com/AnasIsmai1/dotfiles.git ~/dotfiles
~/dotfiles/mac-install.sh --dry-run     # read what it will do
~/dotfiles/mac-install.sh
```

`mac-install.sh` does everything in sections 1–6 below: Xcode CLT, Homebrew,
the Brewfile, oh-my-zsh and its plugins, `install.sh` (stow), the curl-only
installers, the npm/pipx/uv/nvm packages, and `chsh` to the brew zsh. It is
idempotent, never aborts on a single failure, and prints the manual
secret-dependent steps at the end.

Clone over HTTPS, not SSH — the SSH host alias it needs (`github-personal`)
only exists once the repo is stowed.

Do **not** run `pkg-install.sh` — it is apt-only.

---

## 1. Homebrew

Everything lives in [`Brewfile`](./Brewfile). Regenerate on the Mac later with
`brew bundle dump --file=~/dotfiles/Brewfile --force --describe`.

## 2. apt packages (Linux side) and their Mac fate

67 manually-installed apt packages. Mapping:

| apt | on macOS |
| --- | --- |
| alacritty, kitty, mpv, google-chrome-stable, ngrok | brew casks (in Brewfile) |
| docker-ce, docker-ce-cli, docker-buildx-plugin, docker-compose-plugin, containerd.io | `cask "docker"` (Docker Desktop) |
| bat, btop, curl, gh, git, jq, rclone, stow, zoxide, zsh | brew formulae (in Brewfile) |
| golang-go, openjdk-21-jdk, maven, pipx, python3-pip | brew: `go`, `openjdk@21`, `maven`, `pipx`, `python@3.14` |
| postgresql, postgresql-client-17 | `brew "postgresql@17"` |
| build-essential | `xcode-select --install` |
| coreutils, findutils, grep, gzip, diffutils, util-linux | `brew install coreutils findutils grep gzip diffutils` (BSD versions ship by default) |
| ani-cli | `brew install ani-cli` |
| fonts-\* (freefont, ipafont, liberation, noto-color-emoji, unifont, wqy-zenhei, tlwg-loma) | mostly bundled with macOS; nerd fonts are in the Brewfile |
| fcitx5, fcitx5-config-qt | skip — use the built-in macOS input sources |
| waybar, mako-notifier, xvfb, ubuntu-wsl, ubuntu-minimal, base-files, init, login, procps, ncurses-\*, lib\*, dash, bash, hostname, file, ca-certificates, bsdutils, debianutils, xfonts-\* | Linux-only or OS-provided — skip |

## 3. Installed via curl / install script (not any package manager)

Run these after Homebrew:

```sh
# Bun (JS runtime) — currently 1.3.14
curl -fsSL https://bun.sh/install | bash

# Claude Code — currently 2.1.220
curl -fsSL https://claude.ai/install.sh | bash

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Supabase CLI
brew install supabase/tap/supabase

# Composio CLI  (~/.composio, on PATH via .zshrc)
curl -fsSL https://cli.composio.dev/install.sh | bash
```

Also present but already covered by Homebrew on macOS — do **not** curl these:
`nvm`, `atuin`, `starship`, `doppler`, `sesh`, `tpm`.

`~/.expo` and `~/.doppler` are caches created by their CLIs; nothing to install.
`~/go/bin/tour` is `go install golang.org/x/website/tour@latest` — skip unless wanted.

## 4. Language-manager packages

```sh
# npm globals
npm i -g docx pnpm

# pipx
pipx install graphifyy          # ==0.9.10

# uv tools
uv tool install nano-pdf        # ==0.2.1

# node version under nvm
nvm install 24.14.0             # system node is 26.4.0 via brew
```

`pnpm` and `bun` have no global packages installed.

## 5. tmux plugins

Managed by tpm — `prefix + I` inside tmux installs all of them:
catppuccin-tmux, tmux-battery, tmux-continuum, tmux-cpu, tmux-fzf, tmux-fzf-url,
tmux-resurrect, tmux-sensible, tmux-sessionx, tmux-yank, vim-tmux,
vim-tmux-navigator.

## 6. Neovim

LazyVim. `nvim/.config/nvim/lazy-lock.json` pins every plugin — just open nvim
and let lazy.nvim restore.

## 7. Secrets — do these by hand, never commit

None of these are in the repo:

- `~/.zsh_secrets` — sourced by `.zshrc`. Holds `NGROK_AUTHTOKEN` and
  `CLAUDE_CODE_OAUTH_TOKEN`. Recreate manually, `chmod 600`.
- `~/.config/gh/hosts.yml` — gitignored. Recreate with `gh auth login` for both
  the `AnasIsmai1` and `AnasSledge` accounts.
### SSH

`ssh/.ssh/config` **is** tracked and gets stowed to `~/.ssh/config`. It holds
only the `github-personal` / `github-work` aliases — `.gitconfig` signs commits
with `github_personal.pub` and rewrites `github.com` to that alias, so both
machines need it.

Its first line is `Include ~/.ssh/config.local`. That file is **not** tracked and
holds every real host (main-hermes, tennis, mba — production IPs and root
logins, which have no business in a public repo). Recreate it by hand:

```sh
chmod 700 ~/.ssh
$EDITOR ~/.ssh/config.local && chmod 600 ~/.ssh/config.local
```

Private keys — `github_personal`, `github_work`, `id_ed25519`, `main-hermes`,
`LightsailDefaultKey-*.pem` — copy out of band, never through this repo, then
`chmod 600`. `ssh/.ssh/*` is gitignored apart from `config` so a stray `git add`
cannot pick one up.

Verify the split resolves the same on the new box:

```sh
ssh -G github-personal | grep -E '^(hostname|identityfile)'
ssh -G main-hermes     | grep -E '^(hostname|user)'
```

## 8. macOS-specific fixups after stowing

- `.zshrc` aliases `pbcopy`/`pbpaste` to `xclip` — macOS has these natively, so
  delete those two lines.
- `wezsync`/`wezedit` and `WEZTERM_WIN_CONFIG` point at `/mnt/c/...` (WSL only).
  On a Mac, WezTerm reads `~/.wezterm.lua` directly — stow it and drop the helpers.
- `config.default_domain = "WSL:Ubuntu-24.04"` in `.wezterm.lua` must be removed.
- Aliases `update`/`install`/`upgrade` call `apt-get` — point them at `brew`.
- `~/scripts/*` (run, x, show, update) and `~/github-tools` are referenced by
  aliases but are not in this repo; copy them separately if wanted.
