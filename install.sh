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
echo -e "${CYAN}  ► Installing Chef_Carthy OS Universal Suite & AI Workstation...${NC}\n"

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Install CLI Engines
echo -e "${CYAN}1. Installing Chef_Carthy Universal Engines (chef, chef-agent, chef-pkg, chef-theme, chef-wallpaper, chef-menu)...${NC}"
mkdir -p "$HOME/.local/bin"
rm -f "$HOME/.local/bin/chef"*
cp -f "$INSTALL_DIR/bin/"* "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/chef"*

# Create/Update chef-session launcher using official start-hyprland wrapper
cat << 'WRAPPER_EOF' > "$HOME/.local/bin/chef-session"
#!/bin/bash
export AQ_NO_MODIFIERS=1
export WLR_NO_HARDWARE_CURSORS=1
export LIBGL_ALWAYS_SOFTWARE=1
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
exec start-hyprland
WRAPPER_EOF
chmod +x "$HOME/.local/bin/chef-session"
if [ -w /usr/local/bin ]; then
    cp "$HOME/.local/bin/chef-session" /usr/local/bin/chef-session 2>/dev/null || true
fi
echo -e "  ${GREEN}✓ Installed all binaries and session wrapper to ~/.local/bin/${NC}"

# 2. Deploy Cyber HUD Bar Widget
echo -e "\n${CYAN}2. Deploying Cyber HUD Bar Widget to Omarchy Shell...${NC}"
mkdir -p "$HOME/.config/omarchy/plugins/custom.chef-hud"
cp -r "$INSTALL_DIR/plugins/custom.chef-hud/"* "$HOME/.config/omarchy/plugins/custom.chef-hud/" 2>/dev/null || true
echo -e "  ${GREEN}✓ Deployed Cyber HUD plugin to ~/.config/omarchy/plugins/custom.chef-hud${NC}"

# 3. Deploy Desktop Themes & Configurations
echo -e "\n${CYAN}3. Deploying Hyprland, Waybar & Cyber Desktop Configs...${NC}"
mkdir -p "$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/wofi" "$HOME/.config/alacritty" "$HOME/.config/starship" "$HOME/.config/mako" "$HOME/.config/chef_carthy"
if command -v omarchy >/dev/null 2>&1 && [ -f /usr/share/omarchy/config/hypr/hyprland.lua ]; then
    cp -u /usr/share/omarchy/config/hypr/hyprland.lua "$HOME/.config/hypr/hyprland.lua" 2>/dev/null || true
    cp "$INSTALL_DIR/configs/hypr/hyprland.conf" "$HOME/.config/hypr/chef-hyprland.conf" || true
else
    rm -f "$HOME/.config/hypr/hyprland.lua" 2>/dev/null || true
    cp "$INSTALL_DIR/configs/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf" || true
    cp "$INSTALL_DIR/configs/hypr/hyprland.conf" "$HOME/.config/hypr/chef-hyprland.conf" || true
fi
cp "$INSTALL_DIR/configs/waybar/"* "$HOME/.config/waybar/" 2>/dev/null || true
cp "$INSTALL_DIR/configs/wofi/"* "$HOME/.config/wofi/" 2>/dev/null || true
cp "$INSTALL_DIR/configs/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml" || true
cp "$INSTALL_DIR/configs/starship/starship.toml" "$HOME/.config/starship/starship.toml" || true
cp "$INSTALL_DIR/configs/mako/"* "$HOME/.config/mako/" 2>/dev/null || true
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

# 6. Apply Default Cyber Theme & Wallpaper
echo -e "\n${CYAN}6. Activating Default Tactical Theme & Dynamic Wallpaper...${NC}"
"$HOME/.local/bin/chef-theme" set cyber-cyan || true
"$HOME/.local/bin/chef-wallpaper" next || true

echo -e "\n${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}✓ Chef_Carthy OS Suite Installation Completed Successfully!${NC}"
echo -e "${CYAN}Try running:${NC}"
echo -e "  • ${BOLD}chef menu${NC}                   - Launch interactive universal dashboard"
echo -e "  • ${BOLD}chef ai <query>${NC}             - Ask the unrestricted AI System Controller"
echo -e "  • ${BOLD}chef login${NC}                  - Authenticate Google Gemini API Key / Google CLI"
echo -e "  • ${BOLD}chef pkg app <vlc|vmware>${NC}   - Install desktop software & apps"
echo -e "  • ${BOLD}chef wallpaper <next|start>${NC} - Dynamic wallpaper rotator with custom duration"
echo -e "  • ${BOLD}chef theme set <name>${NC}       - Switch tactical themes & border glow"
echo -e "  • ${BOLD}chef audit${NC}                  - Run full security posture audit"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
