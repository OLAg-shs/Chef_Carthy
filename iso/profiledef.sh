#!/usr/bin/env bash
# Chef_Carthy OS ISO Profile Definition for mkarchiso

iso_name="chef-carthy-os"
iso_label="CHEF_CARTHY_$(date +%Y%m)"
iso_publisher="Maccarthy Quest <https://github.com/OLAg-shs>"
iso_application="Chef_Carthy OS - AI-Powered Cybersecurity & Auditing Linux"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-ia32.systemd-boot.esp' 'uefi-x64.systemd-boot.esp')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/usr/local/bin/chef"]="0:0:755"
)
