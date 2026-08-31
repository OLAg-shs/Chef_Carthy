#!/usr/bin/env bash
# Repair/finish an existing Chef OS install without starting over.
# Use this on a VM that already ran chef-install.sh but came up incomplete
# (e.g. only some BlackArch groups, no gemini CLI, or an old broken logo).
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Re-checking BlackArch category groups (safe to re-run, skips installed) ==="
ok=0; failed=()
while read -r group; do
  [[ "$group" =~ ^#.*$ || -z "$group" ]] && continue
  echo "--- $group ---"
  if sudo pacman -S --needed --noconfirm "$group"; then
    ok=$((ok+1))
  else
    failed+=("$group")
  fi
done < "$ROOT_DIR/packages/blackarch-categories.txt"
echo "BlackArch groups now installed: $ok / 48"
[[ ${#failed[@]} -gt 0 ]] && printf 'Still failing: %s\n' "${failed[@]}"

echo "=== Gemini CLI ==="
if ! command -v gemini >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm nodejs npm
  sudo npm install -g @google/gemini-cli
  echo "Installed gemini CLI — run 'gemini' once to authenticate."
else
  echo "Already installed."
fi

echo "=== Refreshing Chef OS branding (fixes the old broken logo) ==="
sudo install -Dm644 "$ROOT_DIR/branding/chef-logo.txt" /usr/local/share/chef-os/chef-logo.txt
sudo install -Dm755 "$ROOT_DIR/branding/bin/chef-ascii" /usr/local/bin/chef-ascii
sudo install -Dm755 "$ROOT_DIR/branding/bin/chef-welcome" /usr/local/bin/chef-welcome
sudo cp "$ROOT_DIR/branding/motd.txt" /etc/motd
rm -f "$HOME/.local/state/chef-os/welcomed"   # so chef-welcome shows the fixed banner again

echo "Done. Run 'chef-welcome --force' now to see the corrected logo immediately."
