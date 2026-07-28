# Moving this setup to a Mac

Inventory taken from the WSL Ubuntu 24.04 box on **2026-07-28**.

## Quick version

```sh
xcode-select --install                  # do this FIRST — see below
git clone https://github.com/AnasIsmai1/dotfiles.git ~/dotfiles
~/dotfiles/mac-install.sh --dry-run     # read what it will do
~/dotfiles/mac-install.sh
```

**Why `xcode-select --install` comes first:** on a clean macOS install `git` is
only a stub. The first `git` command pops the "install command line developer
tools" dialog and then blocks until you accept it — so the clone looks hung when
it is really waiting on a window that may be behind the terminal. Installing the
tools up front avoids that. (`mac-install.sh` also handles this, but it can't
run until the repo is cloned.)

Clone over **HTTPS**, not SSH — the `github-personal` host alias only exists
once `~/.ssh/config` is stowed and the private key is in place. Once the key is
there, switch this repo's remote over so pushes use the personal account rather
than whichever account `gh` happens to be logged in as:

```sh
git -C ~/dotfiles remote set-url origin git@github-personal:AnasIsmai1/dotfiles.git
```

Do this per repo. `.gitconfig` deliberately does **not** rewrite `https://`
globally — that would drag every unrelated HTTPS clone through a key it has no
reason to need.

`mac-install.sh` does everything in sections 1–7 below: Xcode CLT, Homebrew,
the Brewfile, oh-my-zsh and its plugins, `install.sh` (stow), the curl-only
installers, the npm/pipx/uv/nvm packages, and `chsh` to the brew zsh. It is
idempotent, never aborts on a single failure, and prints the manual
secret-dependent steps at the end.

Do **not** run `pkg-install.sh` — it is apt-only.

---

## 1. Homebrew

Split in two on purpose:

- [`Brewfile`](./Brewfile) — 46 formulae. Fast, no sudo, everything the shell needs.
- [`Brewfile.casks`](./Brewfile.casks) — 12 GUI apps and fonts. Hundreds of MB
  each, privileged installers, password prompts.

`mac-install.sh` runs them in that order, so a stalled cask cannot cost you the
command-line toolchain. `--skip-casks` defers the second file entirely:

```sh
./mac-install.sh --skip-casks
# later, when you have time and patience:
brew bundle --verbose --file=~/dotfiles/Brewfile.casks
```

If a cask does stall, `--verbose` names the entry it is on. `docker-desktop` is
the usual suspect — comment it out and install Docker Desktop by hand.

## 2. apt packages (Linux side) and their Mac fate

67 manually-installed apt packages. Mapping:

| apt | on macOS |
| --- | --- |
| alacritty, kitty, google-chrome-stable, ngrok | brew casks (in `Brewfile.casks`) |
| mpv | `brew "mpv"` — a formula on macOS, not a cask |
| docker-ce, docker-ce-cli, docker-buildx-plugin, docker-compose-plugin, containerd.io | `cask "docker-desktop"` (in `Brewfile.casks`) |
| bat, btop, curl, gh, git, jq, rclone, stow, zoxide, zsh | brew formulae (in Brewfile) |
| golang-go, openjdk-21-jdk, maven, pipx, python3-pip | brew: `go`, `openjdk@21`, `maven`, `pipx`, `python@3.14` |
| postgresql, postgresql-client-17 | `brew "postgresql@17"` |
| build-essential | `xcode-select --install` |
| coreutils, findutils, grep, gzip, diffutils, util-linux | `brew install coreutils findutils grep gzip diffutils` (BSD versions ship by default) |
| ani-cli | not in Homebrew; install from https://github.com/pystardust/ani-cli |
| fonts-\* (freefont, ipafont, liberation, noto-color-emoji, unifont, wqy-zenhei, tlwg-loma) | mostly bundled with macOS; nerd fonts are in `Brewfile.casks` |
| fcitx5, fcitx5-config-qt | skip — use the built-in macOS input sources |
| waybar, mako-notifier, xvfb, ubuntu-wsl, ubuntu-minimal, base-files, init, login, procps, ncurses-\*, lib\*, dash, bash, hostname, file, ca-certificates, bsdutils, debianutils, xfonts-\* | Linux-only or OS-provided — skip |

## 3. Installed via curl / install script (not any package manager)

Run these after Homebrew:

```sh
# Bun (JS runtime) — currently 1.3.14
curl -fsSL https://bun.com/install | bash

# Claude Code — currently 2.1.220
curl -fsSL https://claude.ai/install.sh | bash

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Supabase CLI
brew install supabase/tap/supabase
```

`~/.composio` has no standalone installer — it is provisioned by the Composio
MCP integration inside Claude Code
(`claude mcp add --transport http composio https://connect.composio.dev/mcp`).
`.zshrc` puts it on PATH.

Also present but already covered by Homebrew on macOS — do **not** curl these:
`nvm`, `atuin`, `starship`, `doppler`, `sesh`, `tpm`.

`~/.expo` and `~/.doppler` are caches created by their CLIs; nothing to install.
`~/go/bin/tour` is `go install golang.org/x/website/tour@latest` — skip unless wanted.

## 4. Language-manager packages

The lists below are a snapshot. Before any machine move, refresh them:

```sh
./pkg-dump.sh          # rewrites packages.lock, then shows what drifted
```

`packages.lock` is the source of truth for what is actually installed — brew
leaves and casks, apt manual, npm/pnpm/bun globals, pipx, uv tools, gem, go and
cargo bins, nvm node versions, oh-my-zsh plugins, tpm plugins. Every manager
gets a section even when empty, so "cargo: none" is recorded rather than merely
absent. Diff it against the hand-written lists here and in `mac-install.sh`
before trusting either.

On macOS, `./pkg-dump.sh --brewfile` also regenerates the Brewfile. It refuses
to do that on Linux, where `brew bundle dump` emits no casks and would silently
delete the cask and font sections.

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

## 7. Claude Code

Tracked in the `claude` and `agents` stow packages:

| what | where |
| --- | --- |
| `settings.json`, `CLAUDE.md`, `keybindings.json` | `claude/.claude/` |
| `statusline-command.sh` | `claude/.claude/` — already cross-platform (env var → macOS Keychain → Linux creds file) |
| 18 SEO subagent definitions | `claude/.claude/agents/` |
| 14 custom skills that live directly in `~/.claude/skills` | `claude/.claude/skills/` |
| 61 hand-written skills | `agents/.agents/skills/` |

**Not** tracked, because it regenerates (~300 MB of plugin cache plus 1335
marketplace skills): `plugins/cache`, `plugins/marketplaces`, and everything
under `~/.claude/skills` that came from a marketplace. `settings.json` declares
`extraKnownMarketplaces` and `enabledPlugins`, so Claude Code reinstalls them on
first launch. `claude/manifests/` keeps a snapshot of `installed_plugins.json`,
`known_marketplaces.json` and the antigravity skill list for reference.

Also not tracked: `.credentials.json`, `settings.local.json`, and all session,
telemetry, history and project state.

Two things to know about the layout:

- Both packages stow with `--no-folding`. Without it, stow would replace
  `~/.claude/skills` with a symlink into this repo on a fresh machine, and every
  marketplace skill installed afterwards would be written into the repo.
- The hand-written skills exist once, in `~/.agents/skills`. `~/.claude/skills`
  reaches them through relative symlinks (`../../.agents/skills/<name>`). Stow
  restores the store but not those links — `mac-install.sh` recreates them.
  It links all 61; three of them were not linked on the Linux box.

## 8. Secrets — do these by hand, never commit

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

## 9. macOS-specific fixups after stowing

- `.zshrc` aliases `pbcopy`/`pbpaste` to `xclip` — macOS has these natively, so
  delete those two lines.
- `wezsync`/`wezedit` and `WEZTERM_WIN_CONFIG` point at `/mnt/c/...` (WSL only).
  On a Mac, WezTerm reads `~/.wezterm.lua` directly — stow it and drop the helpers.
- `config.default_domain = "WSL:Ubuntu-24.04"` in `.wezterm.lua` must be removed.
- Aliases `update`/`install`/`upgrade` call `apt-get` — point them at `brew`.
- `~/scripts/*` (run, x, show, update) and `~/github-tools` are referenced by
  aliases but are not in this repo; copy them separately if wanted.
