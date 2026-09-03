# Chef OS V7 Reference Archive (Arch / Hyprland / Quickshell)

> **Status:** PERMANENT ARCHIVE / REFERENCE IMPLEMENTATION  
> **Historical Period:** August 2026 – September 2026  
> **Compositor & Shell Stack:** Hyprland + Quickshell (QtQuick/QML) + Waybar + SwayNC + Rofi + Alacritty / Kitty

---

## Overview

This directory preserves the complete codebase, configurations, master specifications, visual assets, build state records, and proof artifacts for **Chef OS V7**.

Active development has transitioned to a completely independent, from-scratch operating system. This repository serves as a permanent reference library to preserve architectural lessons, algorithms, UI designs, and assets.

---

## Archive Structure

```
archive/v7/
├── config/                  # Complete desktop configuration files
│   ├── quickshell/          # shell.qml (Dynamic Island, Popovers, HUD, Quick Settings)
│   ├── waybar/              # Vertical sidebar dock, fallback bars, stylesheets
│   ├── hypr/                # Hyprland compositor, hypridle, hyprlock, hyprpaper
│   ├── swaync/              # SwayNC notification center config & CSS
│   ├── rofi/                # Chef OS custom app launcher themes
│   ├── alacritty/           # Terminal emulator styling
│   └── gtk-3.0 / gtk-4.0    # GTK dark frosted glass themes & font tokens
├── bin/                     # Custom Chef OS system utilities & scripts
│   ├── chef-workspace-manager # Dynamic workspace state engine & hyprctl bridge
│   ├── chef-check           # Desktop health & integrity verification suite
│   ├── cheffetch            # Custom ASCII neofetch-style system banner
│   ├── chef-lock            # Lock screen dispatcher
│   ├── chef-screenshot      # Area capture utility
│   ├── chef-power-menu      # Wayland session power dispatcher
│   └── chef-notify-volume   # OSD volume notification script
├── wallpapers/              # Official Chef OS Sumi-e dark/warm wallpapers
│   ├── chefos-main.png
│   └── chef-os-sumie.png
├── state/                   # Runtime state & build log archives
│   ├── workspaces.json      # Dynamic workspace definitions & unicode glyphs
│   ├── theme.json           # Palette & design tokens
│   ├── build_state.md       # Final build verification state
│   ├── build_log.md         # Step-by-step implementation log
│   ├── requirements_state.md# Traceability matrix
│   └── BUILD_PROGRESS.md    # Phase milestones
├── specs/                   # Master engineering & motion UX specifications
│   ├── CHEF_OS_V7_DYNAMIC_ISLAND_MASTER_SPEC.md
│   ├── CHEF_OS_V7_PREMIUM_UI_MOTION_UX_SPEC.md
│   ├── CHEF_OS_V6_PREMIUM_MAC_INSPIRED_MASTER_SPEC.md
│   ├── CHEF_OS_BUILD_SPEC_V6_CONCRETE.md
│   └── CHEF_OS_AUTONOMOUS_BUILD_SPEC.md
└── proofs/                  # Verified screenshots of all UI states & cold boots
    └── *.png (32 proof images)
```

---

## Key Achievements in V7
- **Dynamic Island:** Floating top-center pill with spring physics, hover waveform audio animation, and delayed collapse.
- **Dynamic Workspaces:** Runtime creation with icon grid selection, synchronized with vertical dock pills.
- **Glassmorphism:** Layer-shell exclusive blurred glass surfaces with 22px border radii.
