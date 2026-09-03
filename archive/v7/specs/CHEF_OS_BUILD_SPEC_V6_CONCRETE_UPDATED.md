# CHEF OS — V6 CONCRETE BUILD SPEC (replaces V5)

## WHY V5 FAILED

V5 was ~5,200 lines of process philosophy (inspect → reconcile → verify
loops, state files, requirement tracking) but almost never told the agent
**what to literally put in a file**. No hex colors. No waybar/rofi/hyprlock
config content. No package list. No exec-once list.

Result: the agent spent its effort managing "requirement state" and never
got to writing real configs. It also launched Hyprland directly instead of
through a session wrapper (hence the "started without start-hyprland"
warning), and never migrated the old config syntax (hence the ".conf
format will be removed in 0.57" warning).

V6 fixes this by being **linear and literal**: every section below is a
file path and exact file content. Follow it top to bottom. If a file
already matches what's below, leave it. If it doesn't, overwrite it with
what's below. Do not re-litigate the design — just build it.

---

# 0. IMMEDIATE FIXES (do these first, before anything else)

1. **"started without start-hyprland" warning** — Hyprland is being
   launched with a bare `Hyprland` command from a TTY/greeter instead of
   via a proper session entry. Fix:
   - Ensure `/usr/share/wayland-sessions/hyprland.desktop` exists (comes
     with the `hyprland` package — reinstall/verify with
     `pacman -Qi hyprland` and `pacman -Ql hyprland | grep wayland-sessions`).
   - Launch Chef OS via a display manager (see section 12) selecting the
     "Hyprland" Wayland session, not by typing `Hyprland` at a shell
     prompt.
   - If a shell-based autostart is required (e.g. `.bash_profile`/`.zprofile`
     auto-exec on tty1), the exec line must be exactly:
     `exec Hyprland` (not `Hyprland &`, not `sh -c Hyprland`).

2. **".conf config format will be removed in 0.57" warning** — this means
   `hyprland.conf` still uses old-style syntax. Run:
   ```
   hyprctl configerrors
   ```
   and fix every flagged line. Common causes: `$mod = SUPER` lines that
   don't use current hyprlang variable syntax, deprecated `bezier`/
   `animation` shorthand, or a `source=` pointing to a file using the old
   format. Rewrite hyprland.conf using the section content in §3 of this
   document, which is already current-syntax.

---

# 1. PACKAGE LIST

Install everything up front so nothing is missing mid-build:

```bash
sudo pacman -Syu --needed \
  hyprland hyprpaper hyprlock hypridle \
  waybar rofi-wayland \
  nautilus \
  alacritty \
  noto-fonts noto-fonts-emoji ttf-jetbrains-mono ttf-fira-code ttf-font-awesome \
  papirus-icon-theme adwaita-icon-theme adw-gtk-theme \
  qt5-wayland qt6-wayland xdg-desktop-portal-hyprland polkit-gnome \
  network-manager-applet pipewire pipewire-pulse wireplumber pavucontrol \
  brightnessctl playerctl grim slurp wl-clipboard \
  ttf-inter
```

`swaync` and `nwg-look` are AUR packages — install with your AUR helper
(e.g. `yay -S swaync nwg-look`).

---

# 2. DESIGN TOKENS (exact values — use these everywhere, no substitutions)

```
BACKGROUND      #F1EBDD   (warm ivory)
SURFACE         #F8F4EA   (soft cream — cards, panels, sidebar)
SURFACE_ALT     #E8E0CE   (slightly darker cream — hover/pressed)
TEXT            #2B2A28   (charcoal/ink)
TEXT_MUTED      #6E6A5F   (secondary text)
ACCENT          #A6534A   (muted brick red — active states, selection)
ACCENT_TEXT     #FFFFFF   (text/icon on top of accent)
SECONDARY       #B8B0A0   (subdued warm gray — borders, inactive icons)
OLIVE           #8A9574   (optional secondary accent — battery ok, success)
BORDER          #DCD3BE   (hairline borders)

FONT_UI         "Noto Sans", "Inter", sans-serif
FONT_MONO       "JetBrains Mono", "Fira Code", monospace
FONT_SIZE_UI    11px
FONT_SIZE_MONO  11px

RADIUS_SM       6px
RADIUS_MD       10px
RADIUS_LG       16px
BORDER_WIDTH    1px

SIDEBAR_WIDTH   56px
TOPBAR_HEIGHT   34px
ICON_SIZE       20px
WINDOW_GAP      8px
WINDOW_RADIUS   10px
```

Do not invent additional colors. Every component below must draw only
from this palette.

---

# 3. `~/.config/hypr/hyprland.conf`

```ini
monitor=,preferred,auto,1

exec-once = hyprpaper
exec-once = waybar -c ~/.config/waybar/config-top.jsonc -s ~/.config/waybar/style-top.css
exec-once = waybar -c ~/.config/waybar/config-side.jsonc -s ~/.config/waybar/style-side.css
exec-once = swaync
exec-once = hypridle
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = nm-applet --indicator
exec-once = wl-paste --watch cliphist store

env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct

general {
    gaps_in = 4
    gaps_out = 8
    border_size = 1
    col.active_border = rgb(A6534A)
    col.inactive_border = rgb(DCD3BE)
    layout = dwindle
}

decoration {
    rounding = 10
    blur {
        enabled = true
        size = 4
        passes = 2
    }
    drop_shadow = true
    shadow_range = 12
    shadow_render_power = 2
    col.shadow = rgba(2B2A2833)
}

animations {
    enabled = true
    bezier = easeOutQuint,0.23,1,0.32,1
    animation = windows, 1, 4, easeOutQuint
    animation = fade, 1, 4, easeOutQuint
    animation = workspaces, 1, 4, easeOutQuint
}

input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
}

$mod = SUPER
$term = alacritty
$launcher = rofi -show drun -theme ~/.config/rofi/chefos.rasi
$files = nautilus

bind = $mod, RETURN, exec, $term
bind = $mod, SPACE, exec, $launcher
bind = $mod, E, exec, $files
bind = $mod, Q, killactive
bind = $mod, L, exec, hyprlock
bind = $mod, PRINT, exec, grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%s).png
bind = $mod, 1, workspace, 1
bind = $mod, 2, workspace, 2
bind = $mod, 3, workspace, 3
bind = $mod SHIFT, 1, movetoworkspace, 1
bind = $mod SHIFT, 2, movetoworkspace, 2
bind = $mod SHIFT, 3, movetoworkspace, 3
```

Verify with `hyprctl configerrors` after saving — it must return nothing.

---

# 4. WALLPAPER — `~/.config/hypr/hyprpaper.conf`

```ini
preload = ~/.config/chef-os/wallpapers/chefos-main.png
wallpaper = ,~/.config/chef-os/wallpapers/chefos-main.png
splash = false
```

Wallpaper geometry rules (build/verify against the reference art):
- Canvas = native monitor resolution exactly (e.g. 1920x1080), no upscale.
- Background fill = `BACKGROUND` (#F1EBDD).
- Character artwork height ≈ 55–70% of canvas height.
- Artwork horizontal center ≈ 68–75% of canvas width (right-of-center).
- Large empty negative space on the left (this is where windows/sidebar
  sit) — never place artwork behind where the sidebar renders.
- Export as PNG, not JPEG (avoids compression artifacts/blur).

---

# 5. TOP STATUS BAR — Waybar instance 1

**Reference comparison / correction:** the first implementation did create the
top bar, but several status modules were text-only or visually ambiguous.
The reference design shows a compact cream status panel with explicit icons,
an active workspace pill, readable clock, network/battery/notification state,
and the brick-red power icon. The configuration below makes every visible
status item explicit instead of relying on blank custom formats.

`~/.config/waybar/config-top.jsonc`
```jsonc
{
  "layer": "top",
  "position": "top",
  "height": 34,
  "margin-top": 6,
  "margin-left": 70,
  "margin-right": 12,
  "modules-left": ["hyprland/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["network", "pulseaudio", "battery", "custom/notification", "custom/power"],

  "hyprland/workspaces": {
    "format": "{id}",
    "on-click": "activate"
  },

  "clock": {
    "format": "  {:%H:%M}",
    "tooltip-format": "{:%A, %B %d}"
  },

  "network": {
    "format-wifi": "  {essid}",
    "format-ethernet": "󰈀  {ifname}",
    "format-disconnected": "  offline",
    "tooltip-format": "{ifname}: {ipaddr}"
  },

  "pulseaudio": {
    "format": "  {volume}%",
    "format-muted": "  muted",
    "on-click": "pavucontrol"
  },

  "battery": {
    "format": "  {capacity}%",
    "format-charging": "  {capacity}%",
    "format-full": "  {capacity}%"
  },

  "custom/notification": {
    "format": "",
    "on-click": "swaync-client -t",
    "tooltip": "Notifications"
  },

  "custom/power": {
    "format": "",
    "on-click": "wlogout",
    "tooltip": "Power"
  }
}
```

`~/.config/waybar/style-top.css`
```css
* {
  font-family: "Noto Sans", "Font Awesome 6 Free", "Inter", sans-serif;
  font-size: 11px;
  color: #2B2A28;
}

window#waybar {
  background: #F8F4EA;
  border: 1px solid #DCD3BE;
  border-radius: 10px;
}

#workspaces {
  margin-left: 4px;
}

#workspaces button {
  padding: 2px 8px;
  margin: 0 2px;
  border-radius: 6px;
  background: transparent;
  color: #6E6A5F;
  border: none;
}

#workspaces button.active {
  background: #A6534A;
  color: #FFFFFF;
}

#clock,
#network,
#pulseaudio,
#battery,
#custom-notification,
#custom-power {
  padding: 0 8px;
}

#custom-notification {
  font-family: "Font Awesome 6 Free";
}

#custom-power {
  font-family: "Font Awesome 6 Free";
  color: #A6534A;
  margin-right: 6px;
}
```

---

# 6. LEFT SIDEBAR DOCK — Waybar instance 2 (vertical)

**This was the main visible failure in the supplied screenshot.**
The sidebar container itself loaded, but most of its custom modules had
`"format": ""`. That explicitly tells Waybar to render **nothing**, so the
buttons existed without the visible icons shown in the reference.

The fix is to put real Font Awesome glyphs in every custom module and to use
the icon font only for the icon-bearing module content. The launcher remains
the brick-red active pill; the remaining app icons stay muted until hover.

`~/.config/waybar/config-side.jsonc`
```jsonc
{
  "layer": "top",
  "position": "left",
  "width": 56,
  "margin-top": 12,
  "margin-bottom": 12,
  "margin-left": 8,
  "modules-left": [
    "custom/launcher",
    "custom/search",
    "custom/files",
    "custom/terminal",
    "custom/spotify"
  ],
  "modules-right": [
    "custom/volume",
    "custom/network",
    "custom/notifications",
    "custom/settings",
    "custom/power"
  ],

  "custom/launcher": {
    "format": "",
    "on-click": "rofi -show drun -theme ~/.config/rofi/chefos.rasi",
    "tooltip": "Applications"
  },

  "custom/search": {
    "format": "",
    "on-click": "rofi -show run -theme ~/.config/rofi/chefos.rasi",
    "tooltip": "Search"
  },

  "custom/files": {
    "format": "",
    "on-click": "nautilus",
    "tooltip": "Files"
  },

  "custom/terminal": {
    "format": "",
    "on-click": "alacritty",
    "tooltip": "Terminal"
  },

  "custom/spotify": {
    "format": "",
    "on-click": "spotify",
    "tooltip": "Spotify"
  },

  "custom/volume": {
    "format": "",
    "on-click": "pavucontrol",
    "tooltip": "Volume"
  },

  "custom/network": {
    "format": "",
    "on-click": "nm-connection-editor",
    "tooltip": "Network"
  },

  "custom/notifications": {
    "format": "",
    "on-click": "swaync-client -t",
    "tooltip": "Notifications"
  },

  "custom/settings": {
    "format": "",
    "on-click": "nwg-look",
    "tooltip": "Settings"
  },

  "custom/power": {
    "format": "",
    "on-click": "wlogout",
    "tooltip": "Power"
  }
}
```

`~/.config/waybar/style-side.css`
```css
* {
  font-family: "Font Awesome 6 Free";
  font-size: 16px;
}

window#waybar {
  background: #F8F4EA;
  border: 1px solid #DCD3BE;
  border-radius: 12px;
}

button,
#custom-launcher,
#custom-search,
#custom-files,
#custom-terminal,
#custom-spotify,
#custom-volume,
#custom-network,
#custom-notifications,
#custom-settings,
#custom-power {
  color: #6E6A5F;
  background: transparent;
  border: none;
  padding: 10px;
  margin: 2px 6px;
  border-radius: 8px;
}

#custom-launcher {
  background: #A6534A;
  color: #FFFFFF;
  margin-top: 2px;
}

#custom-launcher:hover,
#custom-search:hover,
#custom-files:hover,
#custom-terminal:hover,
#custom-spotify:hover,
#custom-volume:hover,
#custom-network:hover,
#custom-notifications:hover,
#custom-settings:hover {
  background: #E8E0CE;
}

#custom-power {
  color: #A6534A;
  margin-bottom: 2px;
}
```

**Important:** do not use `format: ""` for any sidebar custom module.
A blank format was the direct reason the screenshot showed the dock frame
without the intended reference icons.

If Font Awesome 6 glyphs still render as boxes, verify that
`ttf-font-awesome` is installed and restart Waybar. Do not leave the modules
blank as a fallback.

---

---

# 7. LAUNCHER — `~/.config/rofi/chefos.rasi`

```css
* {
  bg: #F8F4EA;
  bg-alt: #E8E0CE;
  fg: #2B2A28;
  fg-muted: #6E6A5F;
  accent: #A6534A;
  border-color: #DCD3BE;
  font: "Noto Sans 11";
}
window {
  background-color: @bg;
  border: 1px;
  border-color: @border-color;
  border-radius: 12px;
  width: 640px;
}
inputbar {
  background-color: @bg-alt;
  text-color: @fg;
  border-radius: 8px;
  padding: 8px 12px;
  margin: 12px;
}
listview {
  background-color: @bg;
  margin: 0px 12px 12px 12px;
  spacing: 2px;
}
element {
  padding: 8px;
  border-radius: 8px;
  text-color: @fg-muted;
}
element selected {
  background-color: @accent;
  text-color: #FFFFFF;
}
```

Config: `~/.config/rofi/config.rasi`
```css
configuration {
  modi: "drun,run,filebrowser";
  show-icons: true;
  icon-theme: "Papirus";
  font: "Noto Sans 11";
}
```

---

# 8. NOTIFICATIONS — swaync

`~/.config/swaync/style.css`
```css
* {
  font-family: "Noto Sans", sans-serif;
}
.notification {
  background: #F8F4EA;
  border: 1px solid #DCD3BE;
  border-radius: 10px;
  color: #2B2A28;
}
.notification-content .summary {
  color: #2B2A28;
  font-weight: bold;
}
.notification-content .body {
  color: #6E6A5F;
}
.notification-action {
  background: #E8E0CE;
  color: #2B2A28;
  border-radius: 6px;
}
.control-center {
  background: #F1EBDD;
  border: 1px solid #DCD3BE;
  border-radius: 12px;
}
```
Keep `~/.config/swaync/config.json` at defaults except pointing
`"style"` at the file above and setting `"positionX": "right"`,
`"positionY": "top"`.

---

# 9. LOCK SCREEN — `~/.config/hypr/hyprlock.conf`

```ini
background {
    path = ~/.config/chef-os/wallpapers/chefos-main.png
    color = rgb(F1EBDD)
}

label {
    text = cmd[update:1000] echo "$(date +'%H:%M')"
    font_family = Noto Sans
    font_size = 64
    color = rgb(2B2A28)
    position = 0, 60
    halign = center
    valign = center
}

label {
    text = cmd[update:1000] echo "$(date +'%A, %B %d')"
    font_family = Noto Sans
    font_size = 16
    color = rgb(6E6A5F)
    position = 0, -10
    halign = center
    valign = center
}

input-field {
    size = 260, 48
    outline_thickness = 1
    outer_color = rgb(DCD3BE)
    inner_color = rgb(F8F4EA)
    font_color = rgb(2B2A28)
    placeholder_text = <span>Password</span>
    position = 0, -140
    halign = center
    valign = center
}
```

`hypridle.conf` should call `hyprlock` on idle timeout and DPMS off after
a longer timeout — do not leave the machine unlockable.

---

# 10. TERMINAL — `~/.config/alacritty/alacritty.toml`

```toml
[window]
padding = { x = 10, y = 10 }
opacity = 1.0

[font]
normal = { family = "JetBrains Mono", style = "Regular" }
size = 11

[colors.primary]
background = "#1B1B1B"
foreground = "#F1EBDD"

[colors.normal]
black   = "#1B1B1B"
red     = "#A6534A"
green   = "#8A9574"
yellow  = "#C9A96E"
blue    = "#7C93A8"
magenta = "#A6534A"
cyan    = "#7C93A8"
white   = "#DCD3BE"

[colors.bright]
black   = "#6E6A5F"
red     = "#C06A5F"
green   = "#A3B592"
yellow  = "#DDBB87"
blue    = "#94ABC0"
magenta = "#C06A5F"
cyan    = "#94ABC0"
white   = "#F8F4EA"
```

Set the shell prompt to run `neofetch` on new interactive shell start
(add `neofetch` to `.zshrc`/`.bashrc`) so it matches the reference.

---

# 11. FILE MANAGER — Nautilus theming

Nautilus follows the system GTK theme, so theming happens once, globally:

1. Install `adw-gtk-theme` (already in package list).
2. `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`:
   ```ini
   [Settings]
   gtk-theme-name=adw-gtk3
   gtk-icon-theme-name=Papirus
   gtk-font-name=Noto Sans 11
   gtk-application-prefer-dark-theme=false
   ```
3. Override the accent to the Chef OS red via `~/.config/gtk-4.0/gtk.css`:
   ```css
   @define-color accent_color #A6534A;
   @define-color accent_bg_color #A6534A;
   @define-color accent_fg_color #FFFFFF;
   @define-color window_bg_color #F1EBDD;
   @define-color view_bg_color #F8F4EA;
   ```
4. Custom folder icons matching the ink-wash aesthetic are optional
   polish — do not block the build on them. If added, place them in a
   Papirus icon-theme override folder, not by replacing the whole theme.

---

# 12. LOGIN / SESSION

Use a display manager (`sddm` or `greetd`+`tuigreet`) with the Hyprland
Wayland session entry from the `hyprland` package. Do not rely on manual
shell exec unless section 0 item 1's rules are followed exactly.

---

# 13. BUILD ORDER (linear — do not skip ahead)

1. Section 0 fixes (session launch + config syntax).
2. Section 1 packages.
3. Section 3 hyprland.conf → `hyprctl configerrors` must be clean.
4. Section 4 wallpaper + hyprpaper running.
5. Section 6 sidebar dock visible with all literal Font Awesome glyphs, and every icon clickable.
6. Section 5 top bar visible with workspace/clock/network/volume/battery/notification/power icons.
7. Section 7 launcher opens via sidebar icon and `$mod+SPACE`.
8. Section 8 notifications render correctly (test with
   `notify-send "Test" "Hello"`).
9. Section 11 Nautilus themed, opens via sidebar/launcher.
10. Section 10 terminal themed, `neofetch` runs on open.
11. Section 9 lock screen (`hyprlock`) tested manually.
12. Reboot. Re-verify every item above still works after reboot.

---

# 14. REFERENCE COMPARISON — WHAT WORKED VS WHAT FAILED

The supplied implementation screenshot was compared against the supplied
Chef OS reference design.

### Already working / substantially matched

- Wallpaper placement and the large left-side negative space match the intended
  composition.
- Warm ivory/cream palette is visibly present.
- The top Waybar instance is launching and the active workspace pill is visible.
- Rounded borders and the general floating-panel treatment are present.
- The right-side system status area is present.
- The sidebar itself is launching in the correct left-side location.
- The launcher uses the intended brick-red active treatment.
- The underlying click actions were defined for the sidebar apps/utilities.

### Failed or did not match the reference

- **Sidebar icons were missing.** The custom modules used `format: ""`, so
  Waybar had no visible content to draw. This is the primary reason the dock
  looked like an empty vertical shell in the supplied screenshot.
- **Sidebar typography was not enough by itself.** The stylesheet selected
  Font Awesome, but no glyphs were actually supplied to most modules.
- **Top status modules were too text-only.** Network, audio and battery lacked
  the explicit icon treatment visible in the reference.
- **Notification was effectively blank.** `custom/notification` used
  `exec: "echo "` rather than a visible notification glyph.
- **The network disconnected string contained an unintended character**
  (`睊 offline`), which was replaced with a real Wi-Fi icon and `offline`.
- **The written spec claimed icons existed without actually specifying them.**
  The corrected §5 and §6 now put the literal glyphs in the JSONC.
- The reference's sidebar is visually a deliberate dock with recognizable
  launcher/search/files/terminal/media and utility icons; the corrected
  configuration now makes those elements explicit and testable.

### Expected result after applying the correction

After restarting Waybar, the left dock should visibly contain:

`Applications → Search → Files → Terminal → Spotify`

with the lower utility group:

`Volume → Network → Notifications → Settings → Power`

The top status bar should visibly contain the active workspace, clock, network,
volume, battery, notifications and brick-red power control.

The geometry, palette, wallpaper and existing Hyprland settings should remain
unchanged; this update specifically fixes the missing/blank Waybar content
rather than redesigning the rest of Chef OS.

---

# 14. FINAL CHECKLIST (short — replaces the old 40-point QA essay)

- [ ] No Hyprland config errors (`hyprctl configerrors` empty)
- [ ] No ".conf format" or "without start-hyprland" warnings on launch
- [ ] Wallpaper matches geometry rules in §4
- [ ] Top bar + left sidebar both visible, correct colors/fonts, and sidebar icons are visibly rendered
- [ ] Launcher opens, themed, searches apps
- [ ] Notifications themed and functional
- [ ] Terminal themed, neofetch runs
- [ ] File manager themed, folders browsable
- [ ] Lock screen themed, unlocks correctly
- [ ] All of the above still true after a full reboot
