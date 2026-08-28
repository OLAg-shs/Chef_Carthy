# Testing Chef OS in VMware

1. Build the ISO on a real Arch Linux machine or Arch VM:
   ```
   cd build
   ./build-iso.sh
   ```
   Output lands in `build/out/*.iso`.

2. In VMware Workstation/Fusion: New VM → "Install from ISO" → point at that file.
   - Firmware: UEFI (Hyprland/Wayland runs fine on UEFI+SVGA/virtio)
   - RAM: 4GB minimum recommended for a pentesting toolset, 2GB will boot but be tight
   - Enable 3D acceleration in VM display settings (helps Hyprland's compositor)
   - Give it 2+ vCPUs — password cracking / recon tools are CPU-bound

3. First boot: log in, then run `chef-ai status` to confirm it can see the system,
   and `chef-ai install-category <name>` to pull in extra BlackArch tool sets on demand
   rather than shipping everything in the base image.

4. For actual network pentesting labs, put the VM on a host-only or NAT network you
   control — never bridge a pentesting VM onto a network you don't have permission to test.
