#!/bin/bash
set -e

# ==============================================================================
# Chef_Carthy OS - Standalone Bootable ISO Builder Script
# Uses mkarchiso to compile a bootable live Arch Linux ISO with Hyprland & AI tools
# ==============================================================================

CYAN='\033[38;5;51m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;226m'
RED='\033[38;5;196m'
BOLD='\033[1m'
NC='\033[0m'

if ! command -v mkarchiso &> /dev/null; then
    echo -e "${YELLOW}mkarchiso not found. Installing 'archiso' package...${NC}"
    sudo pacman -S --needed --noconfirm archiso
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="/tmp/chef-carthy-archiso-work"
OUT_DIR="$SCRIPT_DIR/out"

mkdir -p "$OUT_DIR"
rm -rf "$WORK_DIR"

echo -e "${CYAN}${BOLD}🚀 Building Chef_Carthy OS Bootable ISO...${NC}"
echo -e "  • Profile Directory: $SCRIPT_DIR"
echo -e "  • Output Directory:  $OUT_DIR"
echo -e "  • Work Directory:    $WORK_DIR\n"

sudo mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$SCRIPT_DIR"

echo -e "\n${GREEN}${BOLD}✓ Chef_Carthy OS ISO Generated Successfully!${NC}"
echo -e "${CYAN}Output file:${NC} $(ls -lh "$OUT_DIR"/*.iso 2>/dev/null || echo "$OUT_DIR")\n"
