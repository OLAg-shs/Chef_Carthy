#!/bin/bash
set -e

# ==============================================================================
# Chef_Carthy OS - Bare-Metal Disk Installer
# Provisions full Arch Linux + Hyprland + Agentic AI platform onto target drive
# ==============================================================================

CYAN='\033[38;5;51m'
PURPLE='\033[38;5;141m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;226m'
RED='\033[38;5;196m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${PURPLE}${BOLD}"
echo "   ██████╗██╗  ██╗███████╗███████╗   ██████╗ █████╗ ██████╗ ████████╗██╗  ██╗██╗   ██╗"
echo "  ██╔════╝██║  ██║██╔════╝██╔════╝  ██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██║  ██║╚██╗ ██╔╝"
echo "  ██║     ███████║█████╗  █████╗    ██║     ███████║██████╔╝   ██║   ███████║ ╚████╔╝ "
echo "  ██║     ██╔══██║██╔══╝  ██╔══╝    ██║     ██╔══██║██╔══██╗   ██║   ██╔══██║  ╚██╔╝  "
echo "  ╚██████╗██║  ██║███████╗██║       ╚██████╗██║  ██║██║  ██║   ██║   ██║  ██║   ██║   "
echo "   ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝        ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   "
echo -e "${CYAN}  ► Bare-Metal Installation Wizard (Live USB Environment)${NC}\n"

# Check root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run chef-installer as root (sudo chef-installer).${NC}"
    exit 1
fi

echo -e "${CYAN}1. Detecting Available Storage Disks:${NC}"
AVAILABLE_DISKS=($(lsblk -d -p -n -l -o NAME,TYPE | awk '$2=="disk" && $1 !~ /loop|zram|airootfs/ {print $1}'))

if [ ${#AVAILABLE_DISKS[@]} -eq 0 ]; then
    echo -e "${RED}Error: No suitable installation disks detected.${NC}"
    lsblk
    exit 1
fi

echo -e "Detected disks:"
for d in "${AVAILABLE_DISKS[@]}"; do
    SIZE=$(lsblk -d -n -o SIZE "$d" 2>/dev/null || echo "Unknown")
    MODEL=$(lsblk -d -n -o MODEL "$d" 2>/dev/null || echo "Virtual/Generic Disk")
    echo -e "  • ${BOLD}$d${NC} (${SIZE}) - $MODEL"
done
echo ""

DEFAULT_DISK="${AVAILABLE_DISKS[0]}"

# Ensure reading from controlling terminal when script is piped via curl | bash
if [ -t 0 ]; then
    INPUT_DEV="/dev/stdin"
elif [ -e /dev/tty ]; then
    INPUT_DEV="/dev/tty"
else
    INPUT_DEV="/dev/stdin"
fi

read -rp "Enter target disk to install Chef_Carthy OS [$DEFAULT_DISK]: " TARGET_DISK < "$INPUT_DEV"
TARGET_DISK=${TARGET_DISK:-$DEFAULT_DISK}

if [ ! -b "$TARGET_DISK" ]; then
    echo -e "${RED}Error: Disk $TARGET_DISK not found.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}${BOLD}⚠️ WARNING: All data on $TARGET_DISK will be permanently wiped!${NC}"
read -rp "Are you sure you want to proceed? [y/N]: " CONFIRM < "$INPUT_DEV"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 0
fi

read -rp "Enter username for the new system [chef_carthy]: " USERNAME < "$INPUT_DEV"
USERNAME=${USERNAME:-chef_carthy}

read -rp "Enter hostname for this machine [chef-laptop]: " HOSTNAME < "$INPUT_DEV"
HOSTNAME=${HOSTNAME:-chef-laptop}

# 2. Partitioning Disk (GPT: 1GB EFI, Rest Root)
echo -e "\n${CYAN}2. Partitioning $TARGET_DISK (GPT layout)...${NC}"
wipefs -a "$TARGET_DISK"
parted -s "$TARGET_DISK" mklabel gpt
parted -s "$TARGET_DISK" mkpart "EFI" fat32 1MiB 1024MiB
parted -s "$TARGET_DISK" set 1 esp on
parted -s "$TARGET_DISK" mkpart "ROOT" ext4 1024MiB 100%

# Partition naming check (nvme vs sda)
if [[ "$TARGET_DISK" =~ "nvme" ]] || [[ "$TARGET_DISK" =~ "mmcblk" ]]; then
    PART_EFI="${TARGET_DISK}p1"
    PART_ROOT="${TARGET_DISK}p2"
else
    PART_EFI="${TARGET_DISK}1"
    PART_ROOT="${TARGET_DISK}2"
fi

# 3. Formatting
echo -e "\n${CYAN}3. Formatting Partitions...${NC}"
mkfs.fat -F32 "$PART_EFI"
mkfs.ext4 -F -L "CHEF_ROOT" "$PART_ROOT"

# 4. Mounting
echo -e "\n${CYAN}4. Mounting Target Filesystem to /mnt...${NC}"
mount "$PART_ROOT" /mnt
mkdir -p /mnt/boot
mount "$PART_EFI" /mnt/boot

# 5. Pacstrap Base System & GUI Desktop Suite
echo -e "\n${CYAN}5. Installing Base Arch Linux System, GUI Desktop & Cyber Suite...${NC}"
pacstrap /mnt base base-devel linux linux-firmware sudo networkmanager pipewire pipewire-pulse wireplumber hyprland waybar wofi swaybg mako sddm polkit-gnome alacritty foot python python-pip tk mesa vulkan-mesa-layers open-vm-tools xf86-video-vmware ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji git starship btop eza bat fd ripgrep wl-clipboard wtype curl wget which nano

# 6. Generate FSTAB
echo -e "\n${CYAN}6. Generating /etc/fstab...${NC}"
genfstab -U /mnt >> /mnt/etc/fstab

# 7. System Configuration inside chroot
echo -e "\n${CYAN}7. Configuring System Settings & Bootloader...${NC}"
cat << CHROOT_EOF | arch-chroot /mnt /bin/bash
# Hostname & Time
echo "$HOSTNAME" > /etc/hostname
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

# Locales
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# User setup
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:chef" | chpasswd
echo "root:chef" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Enable services for full GUI & networking
systemctl enable NetworkManager
systemctl enable sddm
systemctl enable vmtoolsd
systemctl enable systemd-boot-update.service

# Create Hyprland VM Launcher Wrapper
cat << 'WRAPPER_EOF' > /usr/local/bin/chef-session
#!/bin/bash
export AQ_NO_MODIFIERS=1
export WLR_NO_HARDWARE_CURSORS=1
export LIBGL_ALWAYS_SOFTWARE=1
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
exec Hyprland
WRAPPER_EOF
chmod +x /usr/local/bin/chef-session

# Create Wayland Desktop Entry for SDDM
mkdir -p /usr/share/wayland-sessions
cat << 'DESKTOP_EOF' > /usr/share/wayland-sessions/chef.desktop
[Desktop Entry]
Name=Chef_Carthy OS (Cyber & AI)
Comment=Cybersecurity & Agentic AI Hyprland Desktop
Exec=/usr/local/bin/chef-session
Type=Application
DesktopNames=Hyprland
DESKTOP_EOF

# Bootloader (systemd-boot)
bootctl install
cat << BOOT_ENTRY > /boot/loader/entries/chef.conf
title   Chef_Carthy OS (Cyber & Agentic AI)
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=\$(blkid -s PARTUUID -o value $PART_ROOT) rw quiet
BOOT_ENTRY

cat << LOADER_CONF > /boot/loader/loader.conf
default chef.conf
timeout 3
console-mode max
LOADER_CONF
CHROOT_EOF

# 8. Install Chef_Carthy Suite into target system
echo -e "\n${CYAN}8. Installing Chef_Carthy OS Suite & Agentic AI Core...${NC}"
mkdir -p /mnt/home/$USERNAME/Projects
arch-chroot /mnt /bin/bash -c "
  cd /home/$USERNAME/Projects && \
  git clone https://github.com/OLAg-shs/Chef_Carthy.git && \
  chown -R $USERNAME:$USERNAME /home/$USERNAME/Projects && \
  sudo -u $USERNAME HOME=/home/$USERNAME /home/$USERNAME/Projects/Chef_Carthy/install.sh
"
mkdir -p /mnt/usr/local/bin
cp -r /mnt/home/$USERNAME/Projects/Chef_Carthy/bin/* /mnt/usr/local/bin/ 2>/dev/null || true
chmod +x /mnt/usr/local/bin/chef* 2>/dev/null || true

echo -e "\n${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}✓ Chef_Carthy OS Installation Complete!${NC}"
echo -e "${CYAN}You can now reboot into your new OS:${NC}"
echo -e "  • Default user: ${BOLD}$USERNAME${NC} (password: chef)"
echo -e "  • Default root: ${BOLD}root${NC} (password: chef)"
echo -e "  • Type ${BOLD}reboot${NC} and unplug your USB drive."
echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
