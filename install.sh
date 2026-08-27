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

# 1. Install CLI Engine
echo -e "${CYAN}1. Installing Chef_Carthy Master CLI & AI Engine...${NC}"
mkdir -p "$HOME/.local/bin"
cp "$INSTALL_DIR/bin/chef" "$HOME/.local/bin/chef"
chmod +x "$HOME/.local/bin/chef"
echo -e "  ${GREEN}✓ Installed 'chef' to ~/.local/bin/chef${NC}"

# 2. Deploy Cyber HUD Bar Widget
echo -e "\n${CYAN}2. Deploying Cyber HUD Bar Widget to Omarchy Shell...${NC}"
mkdir -p "$HOME/.config/omarchy/plugins/custom.chef-hud"
cp -r "$INSTALL_DIR/plugins/custom.chef-hud/"* "$HOME/.config/omarchy/plugins/custom.chef-hud/"
echo -e "  ${GREEN}✓ Deployed Cyber HUD plugin to ~/.config/omarchy/plugins/custom.chef-hud${NC}"

# 3. Kernel & System Security Hardening
echo -e "\n${CYAN}3. Applying Baseline Kernel Security Policies...${NC}"
mkdir -p "$HOME/.config/sysctl.d"
cat << 'EOF' > "$HOME/.config/sysctl.d/99-chef-carthy-security.conf"
# Chef_Carthy OS Kernel Self-Protection Baseline
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
net.ipv4.tcp_syncookies = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
EOF
echo -e "  ${GREEN}✓ Generated kernel hardening parameters in ~/.config/sysctl.d/${NC}"

# 4. Environment & Shell Aliases
echo -e "\n${CYAN}4. Configuring Shell Integrations & Aliases...${NC}"
ALIAS_LINE='alias chef="$HOME/.local/bin/chef"'
if [ -f "$HOME/.bashrc" ] && ! grep -q "alias chef=" "$HOME/.bashrc"; then
    echo "$ALIAS_LINE" >> "$HOME/.bashrc"
fi
if [ -f "$HOME/.zshrc" ] && ! grep -q "alias chef=" "$HOME/.zshrc"; then
    echo "$ALIAS_LINE" >> "$HOME/.zshrc"
fi
echo -e "  ${GREEN}✓ Added 'chef' alias to shell profile${NC}"

echo -e "\n${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}✓ Chef_Carthy OS Suite Installation Completed Successfully!${NC}"
echo -e "${CYAN}Try running:${NC}"
echo -e "  • ${BOLD}chef audit${NC}         - Run full security posture audit"
echo -e "  • ${BOLD}chef ai <query>${NC}    - Ask the built-in AI Security Assistant"
echo -e "  • ${BOLD}chef tools list${NC}    - View all available cybersecurity toolchains"
echo -e "  • ${BOLD}chef network${NC}       - Inspect network sockets & interfaces"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
