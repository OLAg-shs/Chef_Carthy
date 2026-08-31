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

  # Install one category group at a time so one bad/conflicting package
  # can't silently abort the whole batch (this is what left a previous
  # run at only 2/48 groups with no explanation). Logs a clear pass/fail
  # summary at the end and is safe to re-run — --needed skips what's
  # already installed.
  ok=0; failed=()
  while read -r group; do
    [[ "$group" =~ ^#.*$ || -z "$group" ]] && continue
    echo "--- installing $group ---"
    if sudo pacman -S --needed --noconfirm "$group"; then
      ok=$((ok+1))
    else
      failed+=("$group")
    fi
  done < "$ROOT_DIR/packages/blackarch-categories.txt"

  echo "BlackArch groups installed: $ok / 48"
  if [[ ${#failed[@]} -gt 0 ]]; then
    echo "Failed (often package conflicts — resolve manually, then re-run this script, --needed makes it safe to repeat):"
    printf '  %s\n' "${failed[@]}"
  fi
fi

echo "=== [3/4] Installing Chef AI + Gemini CLI ==="
sudo install -Dm755 "$ROOT_DIR/ai-agent/chef-ai.sh" /usr/local/bin/chef-ai
echo "Installed chef-ai."

if ! command -v gemini >/dev/null 2>&1; then
  echo "gemini CLI not found — installing it (needs Node.js 20+ and npm)."
  sudo pacman -S --needed --noconfirm nodejs npm
  sudo npm install -g @google/gemini-cli
  echo "Installed. Run 'gemini' once to authenticate with your Google account"
  echo "or API key before chef-ai's 'ask'/'fix' commands will work."
else
  echo "gemini CLI already present."
fi

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
