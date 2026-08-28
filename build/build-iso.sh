#!/usr/bin/env bash
# Chef OS ISO builder
# Run this on a real Arch Linux machine or Arch VM (needs network access to
# Arch + BlackArch mirrors). Produces a bootable .iso for VMware.
set -euo pipefail

PROFILE_DIR="./chef-os-profile"
OUT_DIR="./out"

echo "[1/6] Installing build deps (archiso)..."
sudo pacman -Sy --needed --noconfirm archiso git

echo "[2/6] Copying releng archiso profile as base..."
rm -rf "$PROFILE_DIR"
cp -r /usr/share/archiso/configs/releng/ "$PROFILE_DIR"

echo "[3/6] Adding BlackArch repo to the profile's pacman.conf..."
cat >> "$PROFILE_DIR/pacman.conf" << 'REPO'

[blackarch]
Server = https://blackarch.org/blackarch/$repo/os/$arch
SigLevel = Optional TrustAll
REPO

echo "[4/6] Merging package lists (Omarchy base + full BlackArch catalog) into packages.x86_64..."
grep -vE '^\s*#|^\s*$' ../vendor/omarchy/install/omarchy-base.packages >> "$PROFILE_DIR/packages.x86_64"
grep -vE '^\s*#|^\s*$' ../packages/blackarch-categories.txt >> "$PROFILE_DIR/packages.x86_64"

echo "[5/6] Copying Omarchy's real config + Chef AI into the airootfs skeleton..."
mkdir -p "$PROFILE_DIR/airootfs/etc/skel/.config"
mkdir -p "$PROFILE_DIR/airootfs/usr/local/bin"
cp -r ../vendor/omarchy/config/*  "$PROFILE_DIR/airootfs/etc/skel/.config/" 2>/dev/null || true
cp -r ../vendor/omarchy/bin/*     "$PROFILE_DIR/airootfs/usr/local/bin/" 2>/dev/null || true
cp ../ai-agent/chef-ai.sh  "$PROFILE_DIR/airootfs/usr/local/bin/chef-ai"

echo "[5b/6] Baking in Chef OS branding (boot splash, MOTD, welcome banner)..."
mkdir -p "$PROFILE_DIR/airootfs/usr/local/share/chef-os"
mkdir -p "$PROFILE_DIR/airootfs/etc/skel/.config/autostart"
mkdir -p "$PROFILE_DIR/airootfs/etc/systemd/system"
cp ../branding/chef-logo.txt "$PROFILE_DIR/airootfs/usr/local/share/chef-os/chef-logo.txt"
cp ../branding/bin/chef-ascii "$PROFILE_DIR/airootfs/usr/local/bin/chef-ascii"
cp ../branding/bin/chef-welcome "$PROFILE_DIR/airootfs/usr/local/bin/chef-welcome"
chmod +x "$PROFILE_DIR/airootfs/usr/local/bin/chef-ascii" "$PROFILE_DIR/airootfs/usr/local/bin/chef-welcome"
cp ../branding/autostart/chef-welcome.desktop "$PROFILE_DIR/airootfs/etc/skel/.config/autostart/"
cp ../branding/chef-boot-splash.service "$PROFILE_DIR/airootfs/etc/systemd/system/"
cp ../branding/motd.txt "$PROFILE_DIR/airootfs/etc/motd"
mkdir -p "$PROFILE_DIR/airootfs/etc/systemd/system/sysinit.target.wants"
ln -sf ../chef-boot-splash.service \
  "$PROFILE_DIR/airootfs/etc/systemd/system/sysinit.target.wants/chef-boot-splash.service"
chmod +x "$PROFILE_DIR/airootfs/usr/local/bin/chef-ai"

echo "[6/6] Building the ISO with mkarchiso..."
mkdir -p "$OUT_DIR"
sudo mkarchiso -v -o "$OUT_DIR" "$PROFILE_DIR"

echo "Done. ISO is in $OUT_DIR/ — point VMware at it as the CD/DVD boot image."
