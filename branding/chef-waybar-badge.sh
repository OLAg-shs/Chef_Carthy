#!/usr/bin/env bash
# Adds a "Chef OS" text module to the left side of Waybar's config, without
# touching Omarchy's own generated config wholesale. Idempotent + backs up.
set -euo pipefail
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"

if [[ ! -f "$WAYBAR_CONFIG" ]]; then
  echo "No waybar config found at $WAYBAR_CONFIG yet — run this after your"
  echo "first Hyprland/Waybar session so Omarchy has generated one."
  exit 1
fi

if grep -q '"custom/chef-os"' "$WAYBAR_CONFIG"; then
  echo "Chef OS badge already present in waybar config."
  exit 0
fi

cp "$WAYBAR_CONFIG" "$WAYBAR_CONFIG.bak.$(date +%s)"

python3 - "$WAYBAR_CONFIG" << 'PY'
import json, re, sys

path = sys.argv[1]
raw = open(path).read()
# Strip // comments crudely for parsing (jsonc), keep original file untouched on disk otherwise
stripped = re.sub(r'(?m)^\s*//.*$', '', raw)
data = json.loads(stripped)

data.setdefault("custom/chef-os", {
    "format": " Chef OS",
    "tooltip": False
})

modules_left = data.get("modules-left", [])
if "custom/chef-os" not in modules_left:
    modules_left.insert(0, "custom/chef-os")
data["modules-left"] = modules_left

with open(path, "w") as f:
    json.dump(data, f, indent=2)
PY

echo "Added the Chef OS badge to $WAYBAR_CONFIG (backup saved alongside it)."
echo "Restart waybar (omarchy-restart-app waybar, or just relog) to see it."
