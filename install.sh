#!/bin/bash
set -e

# ==============================================================================
# Chef_Carthy OS - AI-Powered Cybersecurity Linux Suite Installer
# ==============================================================================

CYAN='\033[38;5;51m'
PURPLE='\033[38;5;141m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;226m'
RED='\033[38;5;196m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}${BOLD}"
echo "   ██████╗██╗  ██╗███████╗███████╗   ██████╗ █████╗ ██████╗ ████████╗██╗  ██╗██╗   ██╗"
echo "  ██╔════╝██║  ██║██╔════╝██╔════╝  ██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██║  ██║╚██╗ ██╔╝"
echo "  ██║     ███████║█████╗  █████╗    ██║     ███████║██████╔╝   ██║   ███████║ ╚████╔╝ "
echo "  ██║     ██╔══██║██╔══╝  ██╔══╝    ██║     ██╔══██║██╔══██╗   ██║   ██╔══██║  ╚██╔╝  "
echo "  ╚██████╗██║  ██║███████╗██║       ╚██████╗██║  ██║██║  ██║   ██║   ██║  ██║   ██║   "
echo "   ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝        ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   "
echo -e "${CYAN}  ► Installing Chef_Carthy OS & AI Cybersecurity Suite...${NC}\n"

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Install CLI Engines
echo -e "${CYAN}1. Installing Chef_Carthy Command Center (chef, chef-pkg, chef-theme, chef-menu)...${NC}"
mkdir -p "$HOME/.local/bin"
cp "$INSTALL_DIR/bin/"* "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/chef"*
echo -e "  ${GREEN}✓ Installed binaries to ~/.local/bin/${NC}"

# 2. Deploy Cyber HUD Bar Widget
echo -e "\n${CYAN}2. Deploying Cyber HUD Bar Widget to Omarchy Shell...${NC}"
mkdir -p "$HOME/.config/omarchy/plugins/custom.chef-hud"
cp -r "$INSTALL_DIR/plugins/custom.chef-hud/"* "$HOME/.config/omarchy/plugins/custom.chef-hud/"
echo -e "  ${GREEN}✓ Deployed Cyber HUD plugin to ~/.config/omarchy/plugins/custom.chef-hud${NC}"

# 3. Deploy Desktop Themes & Configurations
echo -e "\n${CYAN}3. Deploying Hyprland & Terminal Configs...${NC}"
mkdir -p "$HOME/.config/hypr" "$HOME/.config/alacritty" "$HOME/.config/starship"
cp "$INSTALL_DIR/configs/hypr/hyprland.conf" "$HOME/.config/hypr/chef-hyprland.conf" || true
cp "$INSTALL_DIR/configs/alacritty/alacritty.toml" "$HOME/.config/alacritty/chef-alacritty.toml" || true
cp "$INSTALL_DIR/configs/starship/starship.toml" "$HOME/.config/starship/chef-starship.toml" || true
echo -e "  ${GREEN}✓ Saved desktop configs to ~/.config/${NC}"

# 4. Kernel & System Security Hardening
echo -e "\n${CYAN}4. Applying Baseline Kernel Security Policies...${NC}"
mkdir -p "$HOME/.config/sysctl.d"
cat << 'EOF' > "$HOME/.config/sysctl.d/99-chef-carthy-security.conf"
# Chef_Carthy OS Kernel Self-Protection Baseline
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
net.ipv4.tcp_syncookies = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
EOF
echo -e "  ${GREEN}✓ Generated kernel hardening parameters in ~/.config/sysctl.d/${NC}"

# 5. Environment & Shell Aliases
echo -e "\n${CYAN}5. Configuring Shell Integrations & Aliases...${NC}"
ALIAS_LINE='alias chef="$HOME/.local/bin/chef"'
if [ -f "$HOME/.bashrc" ] && ! grep -q "alias chef=" "$HOME/.bashrc"; then
    echo "$ALIAS_LINE" >> "$HOME/.bashrc"
fi
if [ -f "$HOME/.zshrc" ] && ! grep -q "alias chef=" "$HOME/.zshrc"; then
    echo "$ALIAS_LINE" >> "$HOME/.zshrc"
fi
echo -e "  ${GREEN}✓ Added 'chef' alias to shell profile${NC}"

# 6. Apply Default Cyber Theme
echo -e "\n${CYAN}6. Activating Default Tactical Theme (Neon Cyber Cyan)...${NC}"
"$HOME/.local/bin/chef-theme" set cyber-cyan || true

echo -e "\n${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}✓ Chef_Carthy OS Suite Installation Completed Successfully!${NC}"
echo -e "${CYAN}Try running:${NC}"
echo -e "  • ${BOLD}chef menu${NC}          - Launch interactive TUI control center"
echo -e "  • ${BOLD}chef audit${NC}         - Run full security posture audit"
echo -e "  • ${BOLD}chef ai <query>${NC}    - Ask the built-in AI Security Assistant"
echo -e "  • ${BOLD}chef pkg bundles${NC}   - View & install curated tool bundles"
echo -e "  • ${BOLD}chef theme list${NC}    - Switch tactical visual themes"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
