# CHEF OS V7 — MASTER BUILD DIRECTIVE
## STRICT AGENT EXECUTION / REASONING / PROGRESS-CONTROL PROTOCOL

> **THIS DOCUMENT IS NOT A SUGGESTION LIST.**
>
> It is the controlling instruction set for the AI agent modifying Chef OS.
> The agent must follow it sequentially, verify its own work, maintain a persistent
> progress record, and never assume that a previous step was completed merely because
> a configuration file exists.
>
> The agent **does not have visual access to the reference screenshots**. Therefore,
> this document explicitly translates the visual target into measurable/observable
> requirements. The agent must use those requirements when judging its work.

---

# 0. NON-NEGOTIABLE OPERATING RULE

The agent must behave as an **engineer working on an existing system**, not as a
generator starting a new project.

Before changing anything:

1. Read this entire document.
2. Inspect the existing Chef OS installation.
3. Determine what has already been implemented.
4. Determine what is partially implemented.
5. Determine what is broken.
6. Determine what is absent.
7. Compare that state against this document.
8. Only then modify what is necessary.

### NEVER DO THIS

- Do not rebuild working components from scratch.
- Do not replace existing configuration just because a cleaner implementation is possible.
- Do not assume a feature is missing because it is not visible in a text file.
- Do not assume a feature works because a command exits with code 0.
- Do not create duplicate daemons/panels when an existing implementation can be extended.
- Do not install a large framework merely to implement a small UI behavior.
- Do not delete old configuration until the replacement has been tested.
- Do not declare completion without runtime verification.

### ALWAYS DO THIS

```text
READ
↓
INSPECT
↓
REASON
↓
PLAN
↓
BACK UP
↓
CHANGE
↓
RELOAD
↓
VERIFY
↓
RECORD PROGRESS
↓
READ THIS DOCUMENT AGAIN
↓
MOVE TO NEXT STEP
```

---

# 1. THE AGENT MUST MAINTAIN MEMORY OF ITS WORK

Create and continuously maintain:

```text
~/.config/chef-os/BUILD_PROGRESS.md
```

If Chef OS already has an equivalent progress/state file, inspect it first and
extend it rather than creating unnecessary duplicates.

At the beginning of EVERY work session:

```text
1. Read CHEF_OS_V7_PREMIUM_UI_MOTION_UX_SPEC.md
2. Read BUILD_PROGRESS.md
3. Inspect current running state
4. Continue from the first incomplete/failed step
```

At the END of EVERY step:

```text
1. Update BUILD_PROGRESS.md
2. Record exactly what changed
3. Record files changed
4. Record commands/tests executed
5. Record PASS / PARTIAL / FAIL
6. Record anything still broken
7. Record the next step
8. Re-read the relevant section of this master document
```

The agent must never rely on conversational memory alone.

---

# 2. REQUIRED PROGRESS FILE FORMAT

Use this structure:

```markdown
# Chef OS V7 Build Progress

## Current Phase
<phase>

## Current Step
<step>

## Overall Status
<IN PROGRESS / BLOCKED / READY FOR VALIDATION / COMPLETE>

## Environment
- OS:
- Desktop:
- Compositor:
- Waybar:
- Notification daemon:
- Launcher:
- Terminal:
- File manager:
- Audio:
- Network:
- Music player:
- Display resolution:

## Existing Components Found
- ...

## Components Already Working
- ...

## Components Partially Working
- ...

## Components Broken
- ...

## Components Not Yet Implemented
- ...

## Completed Steps
### Step X — <name>
- Status:
- What changed:
- Files:
- Commands:
- Verification:
- Result:
- Notes:

## Current Known Problems
- ...

## Decisions Made
- ...

## Rollback Information
- ...

## Next Exact Step
- ...

## Do Not Forget
- ...
```

The **Next Exact Step** must always contain one concrete next action, not vague text
such as "continue polishing."

---

# 3. REASONING REQUIREMENT

The agent must reason before every architectural change.

For each proposed change, internally establish:

```text
CURRENT STATE:
What exists?

TARGET STATE:
What does this document require?

GAP:
What specifically is missing?

CAUSE:
Why is the current implementation insufficient?

MINIMAL CHANGE:
What is the smallest safe modification?

DEPENDENCIES:
What existing components will this affect?

VERIFICATION:
How will success be proven?

ROLLBACK:
How will the previous state be restored if it fails?
```

If the agent discovers that a requested feature already exists, it must **modify
the existing implementation instead of creating a second implementation**.

Example:

```text
Existing Waybar top bar
        ↓
Inspect
        ↓
Already provides clock/workspaces
        ↓
KEEP
        ↓
Extend with live client/application module
```

NOT:

```text
Existing Waybar
+
New unrelated Waybar
+
Third panel
```

---

# 4. REFERENCE IMAGE TRANSLATION

The reference design establishes the following visual target.

The screenshots show a **warm, extremely restrained desktop**.

## Background

Dominant background:

```text
#F1EBDD
```

The desktop should feel like warm parchment/ivory.

It must NOT become:

- pure white
- gray
- dark
- neon
- blue
- glass-heavy

## Artwork

The sumi-e/anime-style artwork sits:

```text
right of center
approximately around the 70% horizontal region
```

The left and central areas deliberately contain substantial negative space.

The artwork must remain visually quiet.

Do not cover it with permanent widgets.

## Main surface

```text
#F8F4EA
```

## Secondary surface

```text
#E8E0CE
```

## Text

```text
#2B2A28
```

## Muted text

```text
#6E6A5F
```

## Accent

```text
#A6534A
```

## Border

```text
#DCD3BE
```

## Dark terminal ink

```text
#1B1B1B
```

## Olive supporting accent

```text
#8A9574
```

---

# 5. WHAT THE REFERENCE SCREEN ACTUALLY COMMUNICATES

The target is NOT a conventional Linux desktop filled with widgets.

It communicates:

```text
large negative space
+
one compact control surface
+
subtle system information
+
temporary floating controls
+
quiet artwork
```

The UI should not compete with the wallpaper.

The desktop itself should remain calm when nothing is happening.

When something happens, the interface should respond naturally and temporarily.

---

# 6. PRIMARY BAR — EXACT DESIGN INTENT

There must be **ONE PRIMARY TOP BAR**.

Do not retain a second competing sidebar as a primary control surface.

The final conceptual structure is:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ ◈  1  2  3    Terminal    Browser    Music                     │
└─────────────────────────────────────────────────────────────────────────────┘
```

This is conceptual, not a literal requirement for those exact icons.

The important structure is:

```text
LEFT:
Chef OS / launcher
+
workspaces

CENTER:
live applications / context / music

RIGHT:
network
audio
battery
notifications
power
```

Date/time may occupy the center context area or a restrained system position.

---

# 7. BAR GEOMETRY

Target:

```text
height: 34–38 px
top margin: approximately 6 px
left/right margin: approximately 12 px
radius: 10 px
border: 1 px
surface: #F8F4EA
border: #DCD3BE
```

Do not make the bar oversized.

It should look like a floating control strip.

The bar should have enough internal spacing that icons do not appear crowded.

---

# 8. LIVE APPLICATION TABS — CRITICAL

The application section must represent **actual currently open windows**.

The agent must inspect available Hyprland IPC/events before implementing this.

Use existing compositor APIs/events where possible.

Required behavior:

### Start

Only workspace:

```text
[1]
```

### Open Terminal

```text
[1]   Terminal
```

### Open Browser

```text
[1]   Terminal     Browser
```

### Open Spotify/music player

```text
[1]   Terminal     Browser     Spotify
```

### Close Browser

Browser disappears.

### Focus Terminal

Terminal becomes visually active.

### Switch workspace

Workspace indicator updates immediately.

### Click application tab

That application's window is focused.

### Multiple windows

Use compact counts or compact repeated application entries.

Do not allow a long title to destroy the bar layout.

Truncate gracefully.

---

# 9. LIVE DATA RULE

The agent must NOT implement application tabs using a static list such as:

```text
Terminal
Browser
Files
Spotify
```

That is not acceptable.

The module must derive its state from the actual desktop.

Preferred information sources include:

```text
Hyprland IPC
Hyprland events
hyprctl clients
hyprctl activewindow
hyprctl monitors
hyprctl workspaces
```

The exact implementation must be determined after inspecting the current system.

Avoid high-frequency polling if event-driven updates are available.

---

# 10. ONE-PANEL ARCHITECTURE

The existing sidebar may contain useful actions.

Do not simply throw those away.

Audit every sidebar function.

Move useful functions into:

```text
launcher
quick settings
top bar
keyboard shortcuts
context menus
```

Then disable the old sidebar only after its functionality has been preserved.

Required final result:

```text
ONE PRIMARY BAR
+
TEMPORARY FLOATING PANELS
+
LAUNCHER
```

Not:

```text
TOP BAR
+
SIDEBAR
+
ANOTHER PANEL
+
ANOTHER DAEMON
```

---

# 11. WINDOW ANIMATION

The desktop should have smooth motion.

Opening:

```text
fade in
+
small movement/scale
+
settle
```

Closing:

```text
fade
+
small scale down
```

Target duration:

```text
180–280 ms
```

Use easing.

Do not use bounce.

Do not use exaggerated zoom.

Do not make windows fly across the screen.

---

# 12. WORKSPACE ANIMATION

Workspace switching should feel smooth.

Target:

```text
200–300 ms
```

The exact animation must be chosen based on the compositor and VM performance.

If the VM stutters:

```text
reduce animation complexity
```

Do not sacrifice responsiveness.

---

# 13. FOCUS ANIMATION

Active window:

```text
border = #A6534A
```

Inactive window:

```text
border = #DCD3BE
```

The transition should be visually smooth.

No glowing effect.

No neon.

No heavy shadow.

---

# 14. HOVER MICRO-INTERACTIONS

Normal:

```text
transparent / surface
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

Keep interactions subtle.

---

# 15. DATE AND TIME

Date and time are required.

Compact visual state:

```text
18:42
```

Date can be displayed as:

```text
Tue, Sep 1
```

or:

```text
Tuesday, September 1
```

depending on available space.

Do not use a huge desktop clock.

The time must update correctly.

The date must update correctly across midnight/day changes.

---

# 16. TYPOGRAPHY

The target has a clean modern system UI feel.

Preferred order:

```text
SF Pro Display / SF Pro Text
↓
Inter
↓
Noto Sans
↓
system-ui
↓
sans-serif
```

Only use SF Pro if legitimately available on the machine.

Do not make the entire system depend on an unavailable font.

Terminal:

```text
JetBrains Mono
or
Fira Code
```

Typography should be:

```text
clean
medium/light
spacious
restrained
```

Avoid oversized labels.

---

# 17. AUDIO QUICK PANEL

Clicking the audio control must open a floating panel.

Conceptual target:

```text
╭──────────────────────────────╮
│    Sound                    │
│                              │
│  Speakers                    │
│  ━━━━━━━━━━━━━━━●━━  40%     │
│                              │
│  Output                      │
│  Built-in Audio         ▾    │
│                              │
│  Input                       │
│  Built-in Microphone    ▾    │
│                              │
│  Open Sound Settings     ✕   │
╰──────────────────────────────╯
```

Required:

- volume
- mute
- output device
- input device
- sound settings
- close
- Escape
- outside click

Use the existing audio stack if already present.

Do not create duplicate audio services.

---

# 18. WIFI QUICK PANEL

Click Wi-Fi.

Conceptual target:

```text
╭──────────────────────────────╮
│    Wi-Fi                    │
│                              │
│  ● CurrentNetwork            │
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

Required:

- current connection
- available networks
- connection state
- Wi-Fi toggle
- connect/disconnect
- network settings
- close
- Escape
- outside click

Do not display passwords.

---

# 19. PANEL BEHAVIOR

Only one quick panel should be open at a time.

For example:

```text
Sound open
↓
click Wi-Fi
↓
Sound closes
↓
Wi-Fi opens
```

Click outside:

```text
panel closes
```

Press Escape:

```text
panel closes
```

Open same panel again:

```text
panel closes
```

Animations:

```text
fade + small scale
150–220 ms
```

---

# 20. UNIFIED QUICK SETTINGS

After individual panels are stable, unify them into a compact control center.

Suggested:

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
│  │ Bluetooth  │  │ Brightness │     │
│  └────────────┘  └────────────┘     │
│                                     │
│  Battery 100%                       │
│                         ⚙ Settings ✕│
╰─────────────────────────────────────╯
```

Do not build this before the individual controls are reliable.

---

# 21. MUSIC — IMMERSIVE MODE

When audio is playing, the center of the top bar may become context-aware.

Example:

```text
  Artist — Track     ▁▃▅▇▅▃▂▅▇▆▃
```

The waveform must correspond to **actual audio amplitude**.

It must not simply loop a prerecorded-looking pattern.

Preferred architecture:

```text
playerctl
    ↓
metadata / playback state

CAVA or equivalent
    ↓
audio amplitude

lightweight persistent bridge
    ↓
Waybar module
```

Before implementing, inspect whether:

```text
playerctl
cava
PipeWire
PulseAudio compatibility
```

are already installed and working.

If something already exists, extend it.

---

# 22. MUSIC STATES

### Playing

Show:

```text
artist
track
subtle waveform
```

### Paused

Show:

```text
♪ Artist — Track   ─────────
```

with reduced movement.

### No music

Hide the music visualizer.

Return center area to:

```text
application context
or
date/time
```

Do not leave an empty placeholder.

---

# 23. MUSIC CONTROLS

Optional click panel:

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

Use existing player controls where possible.

---

# 24. NOTIFICATIONS

Notifications should alert without interrupting.

Visual:

```text
cream card
+
subtle border
+
subtle shadow
+
muted-red accent
```

Incoming:

```text
translate from right
+
fade in
```

Dismiss:

```text
translate right
+
fade out
```

Duration:

```text
180–250 ms
```

Normal notifications must not shake the screen.

Do not flash the desktop.

Do not cover the entire screen.

---

# 25. NOTIFICATION PRIORITY

Support:

```text
INFO
LOW
IMPORTANT
CRITICAL
```

Normal notifications:

```text
quiet
compact
```

Critical notifications:

```text
stronger visual emphasis
```

Do not make every notification look critical.

---

# 26. LAUNCHER

The launcher is the main application access point.

Preferred:

```text
SUPER + SPACE
```

Visual:

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

Animation:

```text
fade
+
0.96 → 1.00 scale
```

Close:

```text
1.00 → 0.98
+
fade
```

Duration:

```text
150–220 ms
```

---

# 27. LAUNCHER MUST BE CONTEXT-AWARE

Support:

- applications
- recent applications
- favorites
- settings
- network actions
- audio actions
- power actions

Search remains the primary interaction.

---

# 28. POWER MENU

Use the same design language:

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

Same:

- radius
- border
- surface
- typography
- motion
- Escape
- outside click

---

# 29. SETTINGS

Settings must feel like part of Chef OS.

Categories:

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

If a native settings application is used initially, that is acceptable.

The entry point must still match Chef OS.

Do not build an entire custom settings application unless the existing architecture
makes that reasonable.

---

# 30. REDUCED MOTION

Provide a motion preference:

```text
Full
Reduced
Off
```

Full:

```text
workspace animation
window animation
panel animation
notification animation
```

Reduced:

```text
shorter transitions
less scale
```

Off:

```text
instant state changes
```

---

# 31. PERFORMANCE REQUIREMENT

This desktop runs inside a VM.

Performance is part of the design.

Avoid:

- Electron panels
- duplicate daemons
- shell process spawning every frame
- high-frequency polling
- animated wallpaper
- heavy blur
- huge shadows
- unnecessary redraws

Priority:

```text
1. responsiveness
2. stability
3. crisp rendering
4. natural animation
5. decoration
```

If an effect causes:

```text
stutter
tearing
CPU spikes
input lag
compositor instability
```

reduce/remove that effect.

---

# 32. BACKUP REQUIREMENT

Before modifying an existing component:

```text
create a backup
```

Prefer timestamped backups, for example:

```text
~/.config/chef-os/backups/
```

Never overwrite a known-good configuration without preserving a rollback path.

---

# 33. RELOAD REQUIREMENT

After changing a component, reload only what is necessary.

Examples:

```text
Waybar configuration
→ restart/reload Waybar

SwayNC
→ reload/restart SwayNC

Hyprland configuration
→ use supported reload method

GTK
→ test newly launched application
```

Do not reboot after every tiny change.

Use reboot only for persistence/cold-boot validation.

---

# 34. VERIFICATION REQUIREMENT

A command succeeding is NOT sufficient.

Every step requires a behavioral test.

Example:

Bad:

```text
waybar restarted successfully
```

Good:

```text
Waybar restarted
+
bar visible
+
workspace indicator correct
+
clock updates
+
audio icon visible
+
Wi-Fi icon visible
+
clicking audio opens panel
+
Escape closes panel
```

---

# 35. VISUAL VALIDATION WITHOUT IMAGE ACCESS

The agent cannot see the reference screenshot.

Therefore it must validate against this document's explicit measurable rules.

For every visual component check:

```text
geometry
spacing
colors
radius
border
typography
alignment
behavior
animation
performance
```

The agent must describe the observed result in BUILD_PROGRESS.md.

If screenshots can be generated by the environment, create them for the human
operator to inspect, but do not pretend the agent visually evaluated them.

---

# 36. DO NOT CLAIM VISUAL PERFECTION

The agent must never write:

```text
"matches the screenshot perfectly"
```

unless it actually has a visual comparison mechanism.

Instead use:

```text
PASS — satisfies documented visual constraints
PARTIAL — some documented constraints remain
FAIL — documented constraints not satisfied
```

This distinction is mandatory.

---

# 37. PHASE EXECUTION GATES

The agent must complete phases in order.

```text
PHASE A
Architecture
    ↓
GATE A
one primary bar verified

PHASE B
Live applications
    ↓
GATE B
open/close/focus behavior verified

PHASE C
Motion
    ↓
GATE C
animation + performance verified

PHASE D
System controls
    ↓
GATE D
Wi-Fi/audio panels verified

PHASE E
Date + music
    ↓
GATE E
clock + real audio visualization verified

PHASE F
UX
    ↓
GATE F
launcher/clipboard/power/settings verified

PHASE G
Final polish
    ↓
GATE G
cold reboot + complete checklist
```

Do not move to the next phase if the current gate has a major failure.

---

# 38. PHASE A — EXISTING SYSTEM AUDIT

Before changing anything, inspect:

```text
~/.config/hypr/
~/.config/waybar/
~/.config/rofi/
~/.config/swaync/
~/.config/alacritty/
~/.config/gtk-3.0/
~/.config/gtk-4.0/
~/.config/chef-os/
```

Also inspect:

```text
running processes
systemd user services
Waybar instances
Hyprland configuration
workspace configuration
keybindings
audio stack
network stack
installed utilities
```

Determine:

```text
What already exists?
What already works?
What is duplicated?
What is broken?
```

Do not modify anything during the audit unless necessary to safely inspect it.

---

# 39. PHASE A — SINGLE BAR MIGRATION

1. Identify top Waybar instance.
2. Identify side Waybar instance.
3. Record their configs.
4. Identify useful functions in the sidebar.
5. Map those functions to the new architecture.
6. Back up both configurations.
7. Extend the top bar.
8. Migrate functionality.
9. Disable the sidebar.
10. Reload.
11. Verify only one primary bar.
12. Test every migrated function.
13. Update BUILD_PROGRESS.md.
14. Re-read this document.
15. Continue only after Gate A passes.

---

# 40. PHASE B — LIVE APPLICATION TABS

1. Inspect Hyprland client information.
2. Inspect event support.
3. Inspect existing Waybar custom modules.
4. Choose the least expensive event-driven architecture.
5. Build the live state model.
6. Render applications.
7. Add focus behavior.
8. Add open/close updates.
9. Add workspace updates.
10. Test Terminal.
11. Test browser.
12. Test Files.
13. Test music player.
14. Test closing.
15. Test focusing.
16. Test workspace switching.
17. Test multiple windows.
18. Test long titles.
19. Update progress.
20. Re-read this document.

---

# 41. PHASE C — MOTION

Implement in this exact order:

```text
1. window open
2. window close
3. focus transition
4. workspace transition
5. launcher
6. quick panels
7. notifications
8. power menu
```

After each item:

```text
change
→ reload
→ test
→ check CPU/input responsiveness
→ record
→ reread
```

Do not implement all animations at once.

---

# 42. PHASE D — AUDIO

1. Inspect current audio stack.
2. Determine whether PipeWire/PulseAudio is being used.
3. Identify existing volume controls.
4. Preserve them.
5. Build the compact panel.
6. Add volume.
7. Add mute.
8. Add output.
9. Add input.
10. Add settings button.
11. Add close.
12. Add Escape.
13. Add outside click.
14. Test every interaction.
15. Record result.
16. Re-read this document.

---

# 43. PHASE D — WIFI

1. Inspect current network manager.
2. Determine existing network command/API.
3. Preserve it.
4. Build compact panel.
5. Show current connection.
6. Show available networks.
7. Add toggle.
8. Add connect/disconnect.
9. Add settings.
10. Add close.
11. Add Escape.
12. Add outside click.
13. Test.
14. Record.
15. Re-read.

---

# 44. PHASE E — DATE/TIME

1. Inspect current clock module.
2. Keep it if working.
3. Add date if absent.
4. Ensure time updates.
5. Ensure date changes correctly.
6. Ensure timezone is correct.
7. Ensure formatting fits the bar.
8. Test.
9. Record.
10. Re-read.

---

# 45. PHASE E — MUSIC

1. Inspect installed music/player utilities.
2. Inspect `playerctl`.
3. Inspect audio visualization availability.
4. Do not install unnecessary software.
5. Build metadata first.
6. Test play.
7. Test pause.
8. Test stop.
9. Test track change.
10. Add waveform only after metadata is stable.
11. Connect waveform to real audio.
12. Measure CPU impact.
13. Reduce update rate if necessary.
14. Hide waveform when inactive.
15. Test paused state.
16. Record.
17. Re-read.

---

# 46. PHASE F — NOTIFICATIONS

1. Inspect existing SwayNC.
2. Keep working configuration.
3. Improve card styling.
4. Improve animation.
5. Verify notification history.
6. Verify grouping.
7. Verify critical behavior.
8. Test `notify-send`.
9. Test dismissal.
10. Test multiple notifications.
11. Test that notifications do not disrupt normal work.
12. Record.
13. Re-read.

---

# 47. PHASE F — LAUNCHER / CLIPBOARD / POWER / SETTINGS

Implement one at a time.

For each:

```text
inspect existing
→ preserve
→ modify
→ test
→ record
→ reread
```

Do not bundle four untested features into one change.

---

# 48. PHASE G — FINAL POLISH

Only after functionality is stable, tune:

```text
spacing
radii
borders
typography
icon size
icon alignment
animation duration
animation easing
panel position
panel width
panel height
shadow strength
```

Do not change architecture during final polish unless a real defect is discovered.

---

# 49. FINAL COLD-BOOT TEST

The final test must include a real reboot.

After reboot verify:

```text
Hyprland
swaybg
Waybar
SwayNC
hypridle
launcher
audio
network
```

Then verify:

```text
one bar
workspaces
live applications
date
time
Wi-Fi
audio
battery
notifications
power
launcher
music
animations
```

Check:

```text
hyprctl configerrors
```

There must be no configuration errors.

---

# 50. FINAL ACCEPTANCE CHECKLIST

## Architecture
- [ ] One primary top bar
- [ ] Old duplicate sidebar removed/disabled
- [ ] Sidebar functionality preserved where useful
- [ ] No unnecessary duplicate daemon
- [ ] Existing working components preserved

## Top bar
- [ ] Launcher
- [ ] Workspaces
- [ ] Live application tabs
- [ ] Active application
- [ ] Date
- [ ] Time
- [ ] Wi-Fi
- [ ] Audio
- [ ] Battery
- [ ] Notifications
- [ ] Power

## Live behavior
- [ ] Terminal appears when opened
- [ ] Browser appears when opened
- [ ] Music player appears when opened
- [ ] Applications disappear when closed
- [ ] Active application changes correctly
- [ ] Clicking application focuses it
- [ ] Workspace changes update immediately
- [ ] Long titles do not break layout

## Motion
- [ ] Window open
- [ ] Window close
- [ ] Focus
- [ ] Workspace
- [ ] Launcher
- [ ] Quick panels
- [ ] Notifications
- [ ] Power menu
- [ ] Reduced motion

## Audio
- [ ] Panel
- [ ] Volume
- [ ] Mute
- [ ] Output
- [ ] Input
- [ ] Settings
- [ ] Close
- [ ] Escape
- [ ] Outside click

## Wi-Fi
- [ ] Current network
- [ ] Available networks
- [ ] Toggle
- [ ] Connect/disconnect
- [ ] Settings
- [ ] Close
- [ ] Escape
- [ ] Outside click

## Music
- [ ] Metadata
- [ ] Player detection
- [ ] Actual waveform
- [ ] Play/pause
- [ ] Previous
- [ ] Next
- [ ] Seek
- [ ] Hide when inactive
- [ ] Low CPU

## Notifications
- [ ] Floating
- [ ] Quiet
- [ ] Informative
- [ ] Animated
- [ ] Grouped
- [ ] History
- [ ] Critical distinction

## Visual
- [ ] #F1EBDD background
- [ ] #F8F4EA surfaces
- [ ] #E8E0CE secondary surface
- [ ] #2B2A28 text
- [ ] #6E6A5F muted text
- [ ] #A6534A accent
- [ ] #DCD3BE border
- [ ] artwork preserved
- [ ] negative space preserved
- [ ] no neon
- [ ] no excessive blur
- [ ] no excessive shadows
- [ ] no giant widgets
- [ ] consistent radius
- [ ] consistent typography
- [ ] consistent iconography

## Performance
- [ ] no obvious stutter
- [ ] no input lag
- [ ] no compositor instability
- [ ] no excessive CPU
- [ ] waveform optimized
- [ ] idle desktop lightweight

## Persistence
- [ ] cold reboot tested
- [ ] one bar returns
- [ ] all panels work
- [ ] notifications work
- [ ] audio works
- [ ] Wi-Fi works
- [ ] music works
- [ ] no Hyprland errors

---

# 51. STOP CONDITIONS

The agent must STOP and report a blocker rather than guessing when:

- an existing config has unclear ownership
- two components appear to perform the same function
- a destructive migration would risk the working desktop
- required software is unavailable and installing it could destabilize the system
- an API/command behaves differently from expected
- a panel implementation conflicts with existing keybindings
- an animation causes instability
- a change cannot be verified
- the agent is about to overwrite a known-good configuration without backup

When blocked:

```text
DO NOT GUESS.
DO NOT RANDOMLY CHANGE THINGS.
DO NOT CONTINUE AS IF SUCCESSFUL.
```

Record:

```text
BLOCKER
EVIDENCE
WHAT WAS TRIED
WHAT REMAINS UNKNOWN
SAFE NEXT ACTION
```

Then stop at that gate.

---

# 52. ANTI-DRIFT RULE

At the beginning of each step, the agent must state to itself:

```text
I am modifying an existing Chef OS installation.
I must preserve working components.
I must follow the current phase.
I must not implement unrelated features.
I must verify before declaring success.
I must update BUILD_PROGRESS.md.
I must reread this master document before continuing.
```

If the agent notices that it has started doing unrelated work:

```text
STOP
↓
read BUILD_PROGRESS.md
↓
read this document's current phase
↓
return to the exact next step
```

---

# 53. ANTI-DUPLICATION RULE

Before adding ANY service, script, module, panel, shortcut, or daemon:

```text
SEARCH EXISTING SYSTEM
```

Check:

```text
processes
systemd user services
configuration files
scripts
Waybar modules
Hyprland binds
existing Chef OS helpers
```

If an equivalent already exists:

```text
EXTEND IT
```

not:

```text
CREATE ANOTHER ONE
```

---

# 54. SELF-CHECK AFTER EVERY STEP

The agent must answer:

```text
1. What was the target?
2. What existed before?
3. What did I change?
4. What evidence proves it works?
5. Did I introduce duplication?
6. Did I break another feature?
7. Does the result still follow Chef OS visual rules?
8. What is the next exact step?
```

Write the answers to BUILD_PROGRESS.md.

---

# 55. IMPORTANT DISTINCTION: FUNCTIONAL SUCCESS VS DESIGN SUCCESS

A component can be functionally correct but visually wrong.

Example:

```text
Wi-Fi command works
```

does NOT mean:

```text
Wi-Fi panel is complete
```

The panel must also satisfy:

```text
correct position
correct surface
correct border
correct radius
correct spacing
correct typography
correct animation
correct close behavior
correct interaction
```

Both must pass.

---

# 56. THE DESIGN NORTH STAR

The final desktop should feel:

```text
warm
quiet
premium
minimal
alive
responsive
cohesive
```

It should NOT feel:

```text
busy
neon
cyberpunk
widget-heavy
glass-heavy
overanimated
cluttered
```

The desired feeling is:

> Everything responds naturally.

Not:

> Look how many effects were added.

---

# 57. FINAL PRINCIPLE

Chef OS is not macOS.

The implementation may borrow qualities associated with polished desktop systems:

```text
clarity
spacing
hierarchy
motion
feedback
consistency
restraint
```

But the identity remains:

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

The final result must feel like:

# CHEF OS

not:

# Arch Linux with a theme.

---

# 58. HANDOFF COMMAND TO THE AGENT

When this document is supplied to the build agent, the agent should NOT immediately
start editing.

Its first response/action must be equivalent to:

```text
I have read the Chef OS V7 Master Build Directive.

I will first inspect the existing installation and BUILD_PROGRESS.md.

I will not assume features are missing.

I will preserve working components and modify existing implementations where possible.

I will execute one phase/step at a time.

After every step I will verify behavior, update BUILD_PROGRESS.md, and reread the
relevant instructions before proceeding.

I cannot visually inspect the reference screenshot, so I will use the documented
geometry, palette, spacing, behavior, and visual rules as my objective acceptance
criteria.

I will not claim visual perfection without actual visual comparison.
```

Then begin:

```text
PHASE A — EXISTING SYSTEM AUDIT
```

**Do not skip the audit.**


---

# APPENDIX — DETAILED FEATURE SPECIFICATION

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
