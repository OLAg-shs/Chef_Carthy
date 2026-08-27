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
lsblk -d -p -n -l -o NAME,SIZE,MODEL | grep -v "loop" | grep -v "airootfs"
echo ""

read -rp "Enter target disk to install Chef_Carthy OS (e.g. /dev/nvme0n1 or /dev/sda): " TARGET_DISK

if [ ! -b "$TARGET_DISK" ]; then
    echo -e "${RED}Error: Disk $TARGET_DISK not found.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}${BOLD}⚠️ WARNING: All data on $TARGET_DISK will be permanently wiped!${NC}"
read -rp "Are you sure you want to proceed? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 0
fi

read -rp "Enter username for the new system [chef_carthy]: " USERNAME
USERNAME=${USERNAME:-chef_carthy}

read -rp "Enter hostname for this machine [chef-laptop]: " HOSTNAME
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

# 5. Pacstrap Base System
echo -e "\n${CYAN}5. Installing Base Arch Linux System & Hyprland...${NC}"
pacstrap /mnt base base-devel linux linux-firmware sudo networkmanager pipewire pipewire-pulse wireplumber hyprland alacritty foot python python-pip git starship btop eza bat fd ripgrep wl-clipboard wtype curl wget which nano

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

# Enable services
systemctl enable NetworkManager
systemctl enable systemd-boot-update.service

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
