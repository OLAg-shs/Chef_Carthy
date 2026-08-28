#!/usr/bin/env bash
# Chef OS installer — run this INSIDE a booted Arch Linux install
# (bare metal or a fresh Arch VM). It layers three things on top of
# a base Arch system, in order:
#
#   1. Omarchy  — the real upstream installer (vendored under vendor/omarchy,
#                  MIT licensed, © David Heinemeier Hansson) sets up Hyprland,
#                  Waybar, theming, and the whole desktop experience.
#   2. BlackArch — the full tool catalog, added as a repo and installed by
#                  category group (see packages/blackarch-categories.txt).
#   3. Chef AI   — the Gemini-CLI-backed system agent (ai-agent/chef-ai.sh).
#
# This does NOT build a redistributable ISO by itself — see build/build-iso.sh
# for that. This script is for installing Chef OS directly onto a target
# machine/VM disk, the same way Omarchy is normally installed.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== [1/4] Installing Omarchy (desktop base) ==="
echo "Omarchy's official one-line installer isn't vendored in this repo (it's"
echo "served from omarchy.org and evolves independently of the git history)."
echo "Run the current official installer first — check https://omarchy.org"
echo "for the exact command — then come back and run steps 2/3 below."
echo "The vendored files in vendor/omarchy/{config,bin,install}/ are what"
echo "that installer lays down; they're here so you can inspect, diff against"
echo "future upstream versions, and layer Chef OS's own hooks on top."
read -r -p "Press enter once Omarchy is installed and you're ready for BlackArch + Chef AI... "

echo "=== [2/4] Adding BlackArch repo + installing tool categories ==="
curl -s https://blackarch.org/strap.sh -o /tmp/strap.sh
echo ">>> Inspect /tmp/strap.sh before running it (standard advice for any"
echo ">>> curl | bash-style installer, doubly so for one that edits pacman.conf)."
read -r -p "Run BlackArch's official strap.sh now? [y/N] " reply
if [[ "$reply" =~ ^[Yy]$ ]]; then
  chmod +x /tmp/strap.sh
  sudo /tmp/strap.sh
  sudo pacman -Sy
  xargs -a "$ROOT_DIR/packages/blackarch-categories.txt" sudo pacman -S --needed --noconfirm \
    2> >(grep -v '^#')
fi

echo "=== [3/4] Installing Chef AI ==="
sudo install -Dm755 "$ROOT_DIR/ai-agent/chef-ai.sh" /usr/local/bin/chef-ai
echo "Installed chef-ai. Run 'chef-ai status' to verify it can read the system."

echo "=== [4/4] Installing Chef OS branding ==="
sudo install -Dm644 "$ROOT_DIR/branding/chef-logo.txt" /usr/local/share/chef-os/chef-logo.txt
sudo install -Dm755 "$ROOT_DIR/branding/bin/chef-ascii" /usr/local/bin/chef-ascii
sudo install -Dm755 "$ROOT_DIR/branding/bin/chef-welcome" /usr/local/bin/chef-welcome
install -Dm644 "$ROOT_DIR/branding/autostart/chef-welcome.desktop" \
  "$HOME/.config/autostart/chef-welcome.desktop"
sudo install -Dm644 "$ROOT_DIR/branding/chef-boot-splash.service" \
  /etc/systemd/system/chef-boot-splash.service
sudo systemctl enable chef-boot-splash.service
sudo cp "$ROOT_DIR/branding/motd.txt" /etc/motd
echo "Boot splash will show 'Chef OS' text, MOTD is set, and chef-welcome"
echo "will show the banner + status on first login of each session."
echo "Once Hyprland/Waybar has run at least once, optionally run:"
echo "  bash $ROOT_DIR/branding/chef-waybar-badge.sh"
echo "to add a 'Chef OS' badge to the bar (this rewrites the waybar config"
echo "as plain JSON, so it drops any // comments in it — a backup is kept)."

echo "Done. Reboot into Hyprland and confirm the desktop, then run 'chef-ai status'."
