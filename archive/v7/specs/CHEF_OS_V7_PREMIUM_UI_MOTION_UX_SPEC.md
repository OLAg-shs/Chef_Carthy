# CHEF OS V7 — PREMIUM UI / MOTION / UX SPECIFICATION

## Purpose

Upgrade the working Chef OS desktop into a cohesive, polished desktop experience.
The design authority remains the Chef OS reference: warm parchment/ivory background,
sumi-e artwork on the right, generous negative space, charcoal/ink text, muted
brick-red accent, restrained borders, rounded surfaces, and crisp rendering.

The goal is **macOS-level naturalness and polish expressed through Chef OS identity**,
not a copy of Apple's branding or proprietary assets.

---

# 1. KEEP WHAT ALREADY WORKS

Keep and verify the existing:

- warm Chef OS palette
- parchment wallpaper and right-side artwork
- negative space
- working workspace indicator
- working sidebar actions/icons
- launcher actions
- terminal/files/audio/network/notification/power actions
- rounded surfaces
- Hyprland
- SwayNC
- Rofi
- Hyprlock/hypridle
- themed Alacritty
- themed GTK/Nautilus
- cold-boot persistence

Do not rebuild working pieces blindly.

Use:

```text
INSPECT → KEEP/REPAIR → CHANGE ONE GROUP → RELOAD → TEST → SCREENSHOT → COMPARE
```

---

# 2. ONE PRIMARY BAR

Remove the duplicate primary top/side Waybar architecture.

The final desktop has **one primary top control bar**.

```text
┌───────────────────────────────────────────────────────────────────────────┐
│ ◈  1   2   3    Terminal    Browser   ♪ Music                  │
└───────────────────────────────────────────────────────────────────────────┘
```

Useful sidebar functions migrate into:

- the launcher
- quick settings
- keyboard shortcuts
- context menus
- notification/control center

Do not leave two competing primary panels.

---

# 3. TOP BAR GEOMETRY

Target:

```text
height: 34–38 px
top margin: 6 px
left/right margin: 12 px
radius: 10 px
border: 1 px #DCD3BE
surface: #F8F4EA
```

The bar should be compact and floating.

---

# 4. LIVE WORKSPACE + APPLICATION TABS

The top bar must communicate what is currently open.

When Terminal opens:

```text
[1]   Terminal
```

When a browser opens:

```text
[1]   Terminal     Browser
```

When Spotify opens:

```text
[1]   Terminal     Browser     Spotify
```

When windows open/close/focus, the bar updates in real time.

Requirements:

- active tab gets muted-red emphasis
- inactive tabs use muted charcoal
- application icons preferred
- active applications may show text
- long names truncate gracefully
- clicking a tab focuses the corresponding window
- closing a window removes its tab
- multiple windows may show a compact count

Implementation may use Hyprland client/workspace events plus a lightweight
Waybar custom module/script. Do not rely on a static list.

---

# 5. WINDOW OPEN/CLOSE MOTION

Opening:

```text
fade in
+
small scale/position transition
→ settle
```

Closing:

```text
fade
+
slight scale down
```

Target duration:

```text
180–280 ms
```

Use smooth easing. No bounce. No dramatic zoom.

---

# 6. WORKSPACE TRANSITIONS

Switching workspaces must feel fluid.

Target:

```text
200–300 ms
smooth easing
no bounce
no overshoot
```

Workspace state must update in the top bar immediately.

---

# 7. FOCUS TRANSITIONS

Active window:

```text
border: #A6534A
```

Inactive:

```text
border: #DCD3BE
```

Transition the visual state smoothly instead of changing it harshly.

---

# 8. CENTER CONTEXT AREA

Keep the center calm.

Preferred priority:

1. music information while music is playing
2. active application/context
3. date/time when otherwise quiet

Do not show everything simultaneously.

---

# 9. DATE + TIME

Date and time are required.

Compact:

```text
18:42
```

Expanded/tooltip:

```text
Tuesday, September 1
18:42
```

Alternative:

```text
Tue, Sep 1   18:42
```

No oversized clock.

---

# 10. TYPOGRAPHY

Use an Apple-like system-font feel without depending on unofficial proprietary
downloads.

Preferred:

```text
SF Pro Display
SF Pro Text
Inter
Noto Sans
system-ui
sans-serif
```

Use SF Pro only if legitimately available. Otherwise prefer Inter.

Monospace:

```text
JetBrains Mono
Fira Code
```

Typography should be clean, medium/regular, restrained, and spacious.

---

# 11. RIGHT-SIDE SYSTEM CONTROLS

Required:

```text
Wi-Fi
Audio
Battery
Notifications
Power
```

Optional only when relevant:

```text
Bluetooth
Microphone
VPN
```

Compact form:

```text
     40%     100%        
```

---

# 12. AUDIO PANEL

Clicking the audio icon opens a compact floating card.

```text
╭──────────────────────────────╮
│    Sound                    │
│                              │
│  Speakers                    │
│  ━━━━━━━━━━━━━━━●━━  40%     │
│                              │
│  Output                      │
│  Built-in Audio        ▾     │
│                              │
│  Input                       │
│  Built-in Microphone   ▾     │
│                              │
│  Open Sound Settings     ✕   │
╰──────────────────────────────╯
```

Requirements:

- volume slider
- mute state
- output selection
- input selection
- sound settings action
- smooth open/close
- close button
- Escape closes
- outside click closes

Opening another system panel closes the current one.

---

# 13. WI-FI PANEL

Use the same visual language.

```text
╭──────────────────────────────╮
│    Wi-Fi                    │
│                              │
│  ● ChefNetwork               │
│    Connected                 │
│                              │
│  ○ Network Two               │
│  ○ Network Three             │
│                              │
│  Wi-Fi                 ON    │
│                              │
│  Open Network Settings   ✕   │
╰──────────────────────────────╯
```

Requirements:

- current network
- available networks
- connection state
- Wi-Fi toggle
- connect/disconnect
- network settings
- close button
- Escape
- outside click
- smooth animation

Do not expose passwords or sensitive network details.

---

# 14. UNIFIED QUICK SETTINGS

Eventually unify Wi-Fi/audio/battery/Bluetooth/brightness into one compact panel.

```text
╭─────────────────────────────────────╮
│             CHEF OS                 │
│                                     │
│  ┌────────────┐  ┌────────────┐     │
│  │           │  │           │     │
│  │   Wi-Fi    │  │   Sound    │     │
│  │ Connected  │  │    40%     │     │
│  └────────────┘  └────────────┘     │
│                                     │
│  ┌────────────┐  ┌────────────┐     │
│  │           │  │           │     │
│  │ Bluetooth  │  │ Brightness │     │
│  └────────────┘  └────────────┘     │
│                                     │
│  Battery 100%                       │
│                         ⚙ Settings ✕│
╰─────────────────────────────────────╯
```

Keep it compact, not a permanent dashboard.

---

# 15. MUSIC MODE + REAL WAVEFORM

When music is playing, the center bar becomes an immersive music area.

```text
  Artist — Track     ▁▃▅▇▅▃▂▅▇▆▃
```

The waveform must react to **actual audio**, not be a fake looping animation.

Preferred architecture:

```text
playerctl
   ↓
music metadata/control

CAVA or equivalent
   ↓
audio amplitude data
   ↓
lightweight bridge
   ↓
Waybar custom module
```

Requirements:

- actual amplitude response
- subtle waveform
- muted red/charcoal tones
- disappears when no music is active
- reduced movement when paused
- low CPU usage
- no process spawned every frame

When paused:

```text
♪ Artist — Track   ─────────
```

---

# 16. MUSIC CONTROLS

Clicking music may open:

```text
╭──────────────────────────────────╮
│    Artist                       │
│     Track Name                   │
│                                  │
│       ◀        ▶               │
│                                  │
│  ━━━━━━━━━━━●━━━━━━━━            │
╰──────────────────────────────────╯
```

Controls:

- previous
- play/pause
- next
- seek
- volume

Use playerctl where practical.

---

# 17. NOTIFICATIONS

Notifications must be informative without being annoying.

Target:

```text
╭──────────────────────────────╮
│  🔔  Chef OS                 │
│                              │
│  Download complete           │
│  Firefox                     │
│                              │
│                     2m ago   │
╰──────────────────────────────╯
```

Requirements:

- floating cards
- warm cream
- subtle border
- restrained shadow
- muted-red accent
- compact size
- grouping
- history
- automatic dismissal where appropriate
- no permanent top bar

---

# 18. NOTIFICATION MOTION

Incoming:

```text
translate from right + fade in
```

Dismiss:

```text
fade out + translate right
```

Target:

```text
180–250 ms
```

Normal notifications must never visually shake or move the desktop.

---

# 19. NOTIFICATION PRIORITY

Use:

```text
INFO
LOW
IMPORTANT
CRITICAL
```

Normal notifications remain quiet.

Critical notifications may use a stronger accent.

Never flash the whole screen for normal events.

---

# 20. CHEF OS LAUNCHER

The launcher replaces the old sidebar as the main application access point.

Shortcut:

```text
SUPER + SPACE
```

Target:

```text
╭────────────────────────────────────────╮
│  🔍  Search applications...            │
├────────────────────────────────────────┤
│     Browser                           │
│     Terminal                          │
│     Files                             │
│     Spotify                           │
│  ⚙   Settings                          │
╰────────────────────────────────────────╯
```

Opening:

```text
fade + scale 0.96 → 1.00
```

Closing:

```text
scale 1.00 → 0.98 + fade
```

---

# 21. CONTEXT-AWARE LAUNCHER

Support:

- applications
- recent applications
- favorites
- settings
- network actions
- audio actions
- power actions

Search remains primary.

---

# 22. WINDOW STYLE

Windows:

```text
radius: 10–12 px
border: 1 px
gap: 8 px
```

Use subtle shadows only.

No excessive blur.

No neon.

---

# 23. DESKTOP COMPOSITION

Keep the wallpaper mostly unobstructed.

Hierarchy:

```text
WALLPAPER
    ↓
TOP CONTROL BAR
    ↓
APPLICATION WINDOWS
    ↓
TEMPORARY FLOATING PANELS
```

Do not add giant widgets, permanent graphs, desktop clutter, or oversized clocks.

---

# 24. HOVER MICRO-INTERACTIONS

Normal:

```text
transparent
```

Hover:

```text
#E8E0CE
```

Active:

```text
#A6534A
```

Transition:

```text
150–200 ms
```

No glowing outlines or bouncing.

---

# 25. POWER MENU

```text
╭───────────────────────────╮
│       Chef OS             │
│                           │
│   ⏾  Lock                │
│   ↻  Restart             │
│   ⏻  Shut Down           │
│   ⇥  Log Out             │
│                       ✕   │
╰───────────────────────────╯
```

Use the same panel language as Wi-Fi/audio.

---

# 26. CLIPBOARD

Keep cliphist.

Shortcut:

```text
SUPER + V
```

Use a Chef OS launcher-style picker with the same surface, typography, and motion.

---

# 27. SCREENSHOT UX

Keep grim/slurp.

After capture use a small SwayNC notification:

```text
✓ Screenshot captured
```

Optional:

```text
Open
Copy
Delete
```

---

# 28. SETTINGS

Settings entry should open a polished Chef OS settings surface.

Initial categories:

```text
Appearance
Wallpaper
Motion
Theme
Audio
Network
Keyboard
Power
Notifications
```

It may initially route to native settings applications. The entry point must still
feel like Chef OS.

---

# 29. MOTION PREFERENCE

Provide:

```text
Motion
○ Full
○ Reduced
○ Off
```

Full:
- workspace transitions
- window transitions
- panel transitions
- notification animations

Reduced:
- shorter transitions
- less scaling

Off:
- instant state changes

---

# 30. GLOBAL DESIGN TOKENS

```text
CHEF_BACKGROUND = #F1EBDD
CHEF_SURFACE = #F8F4EA
CHEF_SURFACE_ALT = #E8E0CE
CHEF_TEXT = #2B2A28
CHEF_TEXT_MUTED = #6E6A5F
CHEF_ACCENT = #A6534A
CHEF_BORDER = #DCD3BE
CHEF_INK = #1B1B1B
CHEF_OLIVE = #8A9574

CHEF_RADIUS_SM = 8
CHEF_RADIUS = 10
CHEF_RADIUS_LG = 12

CHEF_BORDER_WIDTH = 1

CHEF_GAP_IN = 4
CHEF_GAP_OUT = 8

CHEF_ANIM_FAST = 150ms
CHEF_ANIM_NORMAL = 220ms
CHEF_ANIM_SLOW = 300ms
```

Use one shared token source wherever practical.

---

# 31. COMPONENT CONSISTENCY

These must look like one system:

```text
Top bar
Launcher
Quick settings
Wi-Fi panel
Audio panel
Battery panel
Music panel
Notifications
Power menu
Clipboard
Screenshot notifications
Settings
Lock screen
```

If two surfaces look like different applications, repair them.

---

# 32. PERFORMANCE

Chef OS runs inside a VM.

Avoid:

- Electron-based panels
- redundant daemons
- high-frequency shell polling
- heavy animated wallpaper
- spawning processes every animation frame
- constantly redrawing large surfaces

For the music visualizer:

- stop when playback stops
- reduce update rate when possible
- use one lightweight persistent process/script where practical

Performance priority:

```text
1. Responsiveness
2. Crisp rendering
3. Stability
4. Natural animation
5. Decorative effects
```

---

# 33. VM-SAFE MOTION

If animation causes stutter, tearing, CPU spikes, input lag, wallpaper problems,
or compositor instability, reduce animation complexity.

Never sacrifice stability for decoration.

---

# 34. KEYBOARD-FIRST UX

Required:

```text
SUPER + SPACE     Launcher
SUPER + V         Clipboard
SUPER + 1–9       Workspace
SUPER + SHIFT+1   Move window
SUPER + L         Lock
SUPER + ENTER     Terminal
SUPER + E         Files
ESC               Close floating panel
```

Important controls must remain keyboard reachable.

---

# 35. FALLBACKS

If SF Pro is unavailable:

```text
Inter
```

If audio visualization is unavailable:

```text
♪ Artist — Track
```

If music metadata is unavailable:

```text
player icon
```

If Wi-Fi/audio integration fails:

```text
Open Network Settings
Open Sound Settings
```

Never leave a broken or blank module.

---

# 36. IMPLEMENTATION ORDER

## Phase A — Architecture

1. inspect current Waybar processes
2. identify both instances
3. migrate useful sidebar functions
4. create one primary top bar
5. disable duplicate sidebar panel
6. verify only one primary bar remains

## Phase B — Live tabs

1. inspect Hyprland client/workspace information
2. build live application/workspace model
3. render applications in top bar
4. focus application when clicked
5. update on open/close/focus
6. test multiple applications

## Phase C — Motion

1. window open
2. window close
3. focus transition
4. workspace transition
5. floating-panel transition
6. launcher transition
7. notification transition

## Phase D — System controls

1. audio panel
2. Wi-Fi panel
3. battery panel
4. unified quick settings
5. close/outside-click/Escape behavior

## Phase E — Date + music

1. date/time
2. player metadata
3. waveform
4. playback controls
5. CPU optimization

## Phase F — UX

1. launcher
2. clipboard
3. screenshot feedback
4. power menu
5. settings
6. reduced motion

## Phase G — final polish

1. spacing
2. typography
3. icon consistency
4. animation timing
5. panel sizing
6. shadows
7. wallpaper relationship
8. VM performance
9. reboot persistence

---

# 37. VISUAL VALIDATION

After every major phase:

```text
SCREENSHOT
↓
COMPARE AGAINST REFERENCE
↓
COMPARE AGAINST DESIGN TOKENS
↓
PASS / PARTIAL / FAIL
↓
REPAIR
↓
SCREENSHOT AGAIN
```

Do not declare success merely because a command exits successfully.

---

# 38. HARD VISUAL RULES

Chef OS must remain:

```text
warm
quiet
premium
minimal
sharp
responsive
cohesive
```

It must not become:

```text
neon
cyberpunk
overanimated
widget-heavy
blur-heavy
glass-everywhere
cluttered
```

---

# 39. FINAL TARGET

```text
┌───────────────────────────────────────────────────────────────────────────┐
│ ◈  1  2  3    Terminal    Browser   ♪ Music                  │
└───────────────────────────────────────────────────────────────────────────┘


                         LARGE NEGATIVE SPACE


                                           ┌──────────────┐
                                           │ APPLICATION  │
                                           │              │
                                           │    WINDOW    │
                                           │              │
                                           └──────────────┘

                    Sumi-e artwork remains quietly
                    positioned on the right.
```

The interface should feel alive without calling attention to its animation.

The user should think:

> Everything responds naturally.

not:

> There are lots of animations.

---

# 40. ACCEPTANCE CHECKLIST

## Architecture
- [ ] Exactly one primary control bar
- [ ] No duplicate primary sidebar
- [ ] No competing panel daemon
- [ ] Useful sidebar functions migrated
- [ ] Existing working configuration preserved

## Top bar
- [ ] Chef launcher
- [ ] Live workspaces
- [ ] Live application tabs
- [ ] Active application indication
- [ ] Date
- [ ] Time
- [ ] Wi-Fi
- [ ] Audio
- [ ] Battery
- [ ] Notifications
- [ ] Power

## Live behavior
- [ ] Opening Terminal updates the bar
- [ ] Opening browser updates the bar
- [ ] Opening Spotify updates the bar
- [ ] Closing apps removes them
- [ ] Switching windows changes active state
- [ ] Clicking a tab focuses its window
- [ ] Workspace state updates immediately

## Motion
- [ ] Window open
- [ ] Window close
- [ ] Workspace
- [ ] Focus
- [ ] Launcher
- [ ] Quick settings
- [ ] Notifications
- [ ] Power menu
- [ ] Reduced-motion fallback

## Audio
- [ ] Audio panel
- [ ] Volume
- [ ] Mute
- [ ] Output selection
- [ ] Input selection
- [ ] Sound settings
- [ ] Close
- [ ] Escape
- [ ] Outside click

## Wi-Fi
- [ ] Current network
- [ ] Available networks
- [ ] Toggle
- [ ] Connect/disconnect
- [ ] Network settings
- [ ] Close
- [ ] Escape
- [ ] Outside click

## Music
- [ ] Track metadata
- [ ] Player detection
- [ ] Real waveform
- [ ] Play/pause
- [ ] Previous
- [ ] Next
- [ ] Seek
- [ ] Waveform disappears when inactive
- [ ] Low CPU usage

## Notifications
- [ ] Floating
- [ ] Quiet
- [ ] Informative
- [ ] Animated
- [ ] Grouped
- [ ] History
- [ ] Critical distinction

## Typography
- [ ] SF Pro if legitimately available
- [ ] Inter fallback
- [ ] Clean hierarchy
- [ ] JetBrains Mono/Fira Code terminal
- [ ] No inconsistent fonts

## Visual quality
- [ ] Palette preserved
- [ ] Wallpaper preserved
- [ ] Artwork sharp
- [ ] Negative space preserved
- [ ] No excessive blur
- [ ] No excessive shadows
- [ ] No neon
- [ ] No giant widgets
- [ ] Consistent radii
- [ ] Consistent borders
- [ ] Consistent icons

## Performance
- [ ] No obvious stutter
- [ ] No compositor instability
- [ ] No excessive CPU usage
- [ ] Music visualizer optimized
- [ ] Idle desktop lightweight

## Persistence
- [ ] Cold reboot tested
- [ ] One bar returns
- [ ] Applications launch
- [ ] Panels work
- [ ] Notifications work
- [ ] Audio works
- [ ] Wi-Fi works
- [ ] Music visualization works
- [ ] No Hyprland errors

---

# 41. FINAL DESIGN PRINCIPLE

Chef OS is not trying to imitate macOS.

It is borrowing the qualities that make polished desktop interfaces feel natural:

```text
clarity
+
spacing
+
hierarchy
+
motion
+
feedback
+
consistency
+
restraint
```

Then expressing them through:

```text
PARCHMENT
+
SUMI-E
+
CHARCOAL
+
MUTED RED
+
CLEAN TYPOGRAPHY
+
NEGATIVE SPACE
```

The final result should feel like:

# CHEF OS

not:

# Arch Linux with a theme.
