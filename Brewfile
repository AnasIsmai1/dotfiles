# Homebrew bundle for a new machine (macOS or Linux).
#   brew bundle --file=~/dotfiles/Brewfile
#
# Generated from the WSL Ubuntu box on 2026-07-28. Dependency-only formulae are
# omitted — `brew leaves` plus the handful of tools installed via apt on Linux
# that have brew equivalents on macOS. Linux-only things (Hyprland, waybar,
# mako, swayosd, fcitx5, xvfb) are intentionally absent.

tap "dopplerhq/doppler"
tap "steipete/tap"

# --- Shell & terminal ---
brew "zsh"
brew "starship"          # prompt
brew "atuin"             # shell history sync
brew "keychain"          # ssh-agent wrapper used by .zshrc
brew "tmux"
brew "tpm"               # tmux plugin manager
brew "sesh"              # tmux session manager
brew "stow"              # how this repo gets symlinked
brew "zoxide"

# --- Core CLI ---
brew "bat"
brew "eza"
brew "fd"
brew "fzf"
brew "ripgrep"
brew "jq"
brew "curl"
brew "coreutils"         # macOS ships BSD userland; GNU tools live here
brew "television"        # fuzzy finder TUI
brew "btop"
brew "rclone"
brew "mpv"             # formula on macOS, not a cask

# --- Git / GitHub ---
brew "git"
brew "git-delta"
brew "gh"
brew "lazygit"
brew "act"               # run GitHub Actions locally
brew "worktrunk"

# --- Editor ---
brew "neovim"

# --- Languages & runtimes ---
brew "node"
brew "nvm"
brew "go"
brew "python@3.14"
brew "uv"                # python package/tool manager
brew "pipx"
brew "openjdk@21"
brew "maven"

# --- Databases ---
brew "postgresql@17"

# --- Docs / publishing ---
brew "pandoc"
brew "poppler"
brew "ghostscript"
brew "tectonic"          # LaTeX

# --- Cloud / infra ---
brew "cloudflared"
brew "cloudflare-cli4"
brew "doppler"
brew "depot"

# --- AI tooling ---
brew "opencode"

# --- Casks (macOS GUI apps) ---
cask "wezterm"           # primary terminal; config is ~/dotfiles/.wezterm.lua
cask "ghostty"
cask "alacritty"
cask "kitty"
cask "docker-desktop"
cask "google-chrome"
cask "ngrok"

# --- Fonts ---
cask "font-jetbrains-mono-nerd-font"
cask "font-hack-nerd-font"
cask "font-meslo-lg-nerd-font"
cask "font-fira-code-nerd-font"
cask "font-caskaydia-cove-nerd-font"
