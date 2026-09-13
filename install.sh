#!/usr/bin/env bash
# Migration installer: Arch / CachyOS
# Installs + configures Claude Code, Obsidian, Syncthing, Tailscale.
# Ends by handing Chrome + LazyVim + VSCode config off to Claude Code itself.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$DOTFILES_DIR/configs"

echo "==> Updating system"
sudo pacman -Syu --noconfirm

# ---------------------------------------------------------------------------
# Tailscale (needed before syncthing key transfer, and for Pi/vault access)
# ---------------------------------------------------------------------------
echo "==> Installing Tailscale"
sudo pacman -S --needed --noconfirm tailscale
sudo systemctl enable --now tailscaled
echo "==> Tailscale auth: open the URL below and approve this device"
sudo tailscale up
tailscale ip -4 || true

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------
echo "==> Installing Claude Code"
if ! command -v node >/dev/null; then
  sudo pacman -S --needed --noconfirm nodejs npm
fi
sudo npm install -g @anthropic-ai/claude-code

echo "==> Restoring Claude Code config"
mkdir -p ~/.claude
cp "$CONF/claude/CLAUDE.md" ~/.claude/CLAUDE.md
cp "$CONF/claude/settings.json" ~/.claude/settings.json
cp "$CONF/claude/settings.local.json" ~/.claude/settings.local.json
chmod 600 ~/.claude/settings.json
echo "    NOTE: run 'claude' once and log in — .credentials.json is not in this repo on purpose."

# ---------------------------------------------------------------------------
# Syncthing
# ---------------------------------------------------------------------------
echo "==> Installing Syncthing"
sudo pacman -S --needed --noconfirm syncthing
systemctl --user enable --now syncthing.service

cat <<'EOF'
    NOTE: syncthing identity (cert.pem/key.pem/config.xml with API key) is
    intentionally NOT in this repo (private keys should never sit in git,
    even a private repo). Copy it from the old laptop over Tailscale instead,
    once both machines show up in `tailscale status`:

      OLD_LAPTOP_IP=100.75.40.13   # update if it changed
      systemctl --user stop syncthing.service   # on the NEW machine
      scp -r "$OLD_LAPTOP_IP:~/.config/syncthing/." ~/.config/syncthing/
      systemctl --user start syncthing.service

    Do this before it re-syncs the vault, so the device ID matches and
    Syncthing doesn't treat this laptop as a stranger.
EOF

# ---------------------------------------------------------------------------
# Obsidian
# ---------------------------------------------------------------------------
echo "==> Installing Obsidian"
yay -S --needed --noconfirm obsidian

echo "    Vault syncs in via Syncthing above — once that catches up, open"
echo "    Obsidian and point it at the synced vault folder."

# ---------------------------------------------------------------------------
# LazyVim (base config only — plugins install on first nvim launch)
# ---------------------------------------------------------------------------
echo "==> Installing Neovim + restoring LazyVim config"
sudo pacman -S --needed --noconfirm neovim git ripgrep fd unzip
mkdir -p ~/.config
cp -r "$CONF/nvim" ~/.config/nvim
echo "    Run 'nvim' once to let lazy.nvim sync plugins from lazy-lock.json."

echo
echo "==> Core apps done: Tailscale, Claude Code, Syncthing, Obsidian, LazyVim."
echo "==> Handing the rest (Chrome, VSCode) to Claude Code..."

claude "Set up this fresh Arch/CachyOS install (Serpentium shell) to match my \
old machine for the remaining apps: Google Chrome and VSCode. Install Chrome \
(prefer the AUR google-chrome package via yay), install VSCode (code, from \
the official repo or AUR), then help me restore/sync their settings \
(extensions, keybindings, settings.json for VSCode; profile via Chrome sync \
login for Chrome). Ask me anything you need to proceed."
