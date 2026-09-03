# CHEF OS — V6 PREMIUM MAC-INSPIRED DESKTOP MASTER SPECIFICATION
## Autonomous implementation controller + visual/interaction system

> THIS FILE IS THE MASTER DIRECTIVE.
> Read the ENTIRE file before changing Chef OS.
> Re-read this file after EVERY major step and after every completed repair.
> The coding agent must treat this document as the source of truth.

---

# 0. MISSION

Take the CURRENT Chef OS VM from its existing state to a polished, cohesive,
MacOS-inspired desktop while preserving useful work that already exists.

Chef OS is NOT a generic Arch rice.

The target is:

**warm parchment + sumi-e/anime artwork + elegant LEFT vertical dock +
cohesive surfaces + real application icons + smooth motion + unified themes +
natural system popovers + dynamic workspaces + dynamic running applications.**

The desktop must feel like ONE operating system.

Do not rebuild working components blindly.

---

# 1. NON-NEGOTIABLE AUTONOMOUS EXECUTION RULES

You are the implementation agent. The user should not have to repeatedly
tell you the next step.

Before starting:
1. Read this entire specification.
2. Read `~/.config/chef-os/build_state.md` if it exists.
3. Read `~/.config/chef-os/requirements_state.md` if it exists.
4. Read recent `~/.config/chef-os/build_log.md` when needed.
5. Inspect the REAL running VM.
6. Determine what is already implemented.

For EVERY requirement classify it:

- PASS = implemented and verified
- PARTIAL = implemented but mismatched
- FAIL = missing/broken
- UNKNOWN = insufficient evidence
- BLOCKED = genuinely impossible without missing external information

Rules:

PASS -> VERIFY -> KEEP
PARTIAL -> REPAIR ONLY THE MISMATCH -> VERIFY
FAIL -> IMPLEMENT -> VERIFY
UNKNOWN -> INVESTIGATE -> VERIFY

Never assume:
- a file existing means it works,
- a package being installed means it is being used,
- a command succeeding means the feature works,
- a previous agent's claim is proof.

Every major step is:

INSPECT
-> BACKUP
-> CHANGE
-> VALIDATE
-> RELOAD
-> VERIFY
-> RECORD
-> RE-READ THIS SPEC
-> CONTINUE

Never perform a giant unrelated batch of changes.

After EVERY major step:
- update build_state.md,
- append build_log.md,
- update requirements_state.md,
- re-read this specification,
- re-read the current state,
- choose the highest-priority incomplete requirement.

If interrupted, resume from the first incomplete requirement. Do not restart
from the beginning.

Do not ask "should I continue?" during normal work.

Only stop for a genuine blocker such as an unsafe destructive operation,
missing credentials that cannot be obtained normally, or an ambiguous choice
that the specification genuinely cannot resolve.

---

# 2. PERSISTENT PROJECT MEMORY

Create/maintain:

`~/.config/chef-os/`

Required files:

`build_state.md`
`build_log.md`
`requirements_state.md`

`build_state.md` must contain:

CHEF OS BUILD STATE

Overall status:
Current phase:
Current step:
Current substep:

Last action:
Last successful action:
Last failed action:

Failure:
Root cause:
Repair:
Verification:

Files changed:
Packages changed:
Services changed:

Next action:
Last updated:

`requirements_state.md` must contain one row per requirement:

REQ-ID | Requirement | STATUS | Evidence | Last verified | Next action

The state files are MEMORY, NOT PROOF.
Always reconcile them against the actual VM.

---

# 3. ANTI-DRIFT PROTOCOL

Whenever confused, do exactly this:

STOP
-> READ THIS SPEC
-> READ build_state.md
-> READ requirements_state.md
-> INSPECT REAL SYSTEM
-> FIND FIRST FAIL/PARTIAL/UNKNOWN DEPENDENCY
-> REPAIR
-> VERIFY
-> RECORD
-> RE-READ SPEC
-> CONTINUE

Never invent a new architecture just because an existing implementation is
messy.

First determine whether the existing implementation can be repaired.

---

# 4. EXISTING-SYSTEM RECONCILIATION

Before installing anything, inspect:

`~/.config/hypr/`
`~/.config/waybar/`
`~/.config/rofi/`
`~/.config/swaync/`
`~/.config/chef-os/`
`~/.config/gtk-3.0/`
`~/.config/gtk-4.0/`
`~/.config/qt6ct/` if present
`~/.local/share/applications/`

Inspect:
- running processes,
- user services,
- Hyprland startup,
- Waybar/other panel startup,
- notification daemon,
- wallpaper backend,
- theme environment,
- icon theme,
- fonts,
- active monitor,
- workspaces,
- currently focused windows.

Do NOT create duplicate:
- bars,
- notification daemons,
- wallpaper daemons,
- launchers,
- theme engines,
- background services.

If an existing component already performs a required function:
KEEP and improve it unless replacement is clearly necessary.

---

# 5. CORE VISUAL IDENTITY

Chef OS must use one shared design system.

Default theme:

Background: `#F1EBDD`
Surface: `#F8F4EA`
Surface Alt: `#E8E0CE`
Text: `#2B2A28`
Text Muted: `#6E6A5F`
Accent: `#A6534A`
Border: `#DCD3BE`

Use:
- subtle shadows,
- thin borders,
- restrained blur only when useful,
- rounded corners,
- generous spacing,
- clean typography.

Avoid:
- neon,
- RGB,
- cyberpunk purple,
- excessive glass,
- excessive blur,
- giant glowing borders,
- gaming-HUD styling,
- random unrelated colors.

Approximate geometry:
- dock width: 52–68 px depending on display
- outer margin: 10–16 px
- radius: 12–16 px
- icon size: approximately 18–24 px
- gaps: approximately 4–10 px
- active border/accent: muted red

All values must be responsive rather than blindly hardcoded.

---

# 6. THE DESKTOP COMPOSITION

The desktop should resemble a large sheet of warm Japanese paper with a
carefully placed sumi-e illustration and a restrained computer interface.

Wallpaper:
`/home/chef_carthy/.config/chef-os/wallpapers/chefos-main.png`

If this file exists and passes inspection, preserve it rather than recreating
it.

For 1920x1080:
- canvas exactly 1920x1080,
- artwork approximately 350–500 px tall,
- artwork center around 65–72% of canvas width,
- artwork centered approximately vertically,
- large negative space,
- no aggressive crop,
- no stretch.

Check actual monitor resolution before making wallpaper changes.

Do not confuse VMware viewer scaling with guest display scaling.

---

# 7. PRIMARY NAVIGATION — LEFT VERTICAL DOCK ONLY

There must be NO PRIMARY HORIZONTAL TOP BAR.

The main Chef OS control surface is a single elegant LEFT vertical dock.

It should occupy most of the usable screen height while remaining narrow.

Target:

- LEFT
- VERTICAL
- NARROW
- FLOATING
- FULL/MOST USABLE HEIGHT
- warm cream surface
- thin border
- subtle shadow
- rounded corners

Do not leave a second top bar running just because it already exists.

Find what creates the current top bar and remove/replace only the conflicting
implementation.

---

# 8. LEFT DOCK INFORMATION ARCHITECTURE

The dock should be organized into clear zones.

Top:
1. Chef OS logo
2. Dynamic workspace list

Then:
3. Running applications / active application list
4. Launcher
5. Files
6. Terminal
7. Optional frequently used applications

Then:
8. Volume
9. Wi-Fi/network
10. Battery
11. Notifications
12. Date/time
13. Settings
14. Power/logout

The dock must remain visually calm. Do not cram every feature into tiny
buttons.

If necessary, use compact expandable popovers instead of making the dock
wider.

---

# 9. DYNAMIC WORKSPACES

Workspaces are NOT limited to 1, 2, and 3.

Chef OS must support dynamic Hyprland workspaces.

Requirements:

- Workspace 1 exists.
- Workspace 2 exists when used.
- Workspace 3 exists when used.
- Additional workspaces can be created naturally.
- The dock updates when workspaces are created/removed/occupied.
- The active workspace is clearly visible.
- Empty unused workspaces should not create a giant permanent list unless
  Hyprland configuration requires it.
- Switching workspaces must update the dock immediately.
- Clicking a workspace must switch to it.
- Keyboard workspace switching must continue to work.

The UI should visually communicate:

ACTIVE = muted accent fill/border
INACTIVE = neutral low-contrast state
OCCUPIED = subtle indication
EMPTY = minimal or hidden according to implementation

The workspace list must never become visually chaotic when many workspaces
exist.

---

# 10. DYNAMIC RUNNING APPLICATIONS

The dock must show currently running applications dynamically.

Example:

[Files]
[Terminal]
[Browser]
[Spotify]

When an application opens:
- its entry appears automatically.

When it closes:
- its entry disappears automatically.

When focus changes:
- the focused application becomes visually active.

Do NOT maintain a fake hardcoded list.

Derive application state from actual Hyprland/window state.

Use real application metadata and `.desktop` entries where possible.

---

# 11. APPLICATION ICON QUALITY

Use real installed application icons.

Preferred source order:
1. application's desktop entry icon,
2. installed icon theme,
3. appropriate fallback icon.

Do NOT use:
- emoji as permanent application icons,
- random generated 2D placeholders,
- unrelated generic icons,
- fake icons merely to fill space.

Icons must be:
- crisp,
- correctly scaled,
- consistent with the chosen icon theme,
- recognizable,
- visually balanced.

The same icon language must be used across:
- dock,
- launcher,
- application lists,
- notifications where appropriate,
- file manager,
- settings.

Do not distort icons.

---

# 12. HOVER STATES — GLOBAL REQUIREMENT

EVERY interactive page/control must have a coherent hover state.

Hover must make it immediately obvious:
- what the pointer is over,
- what will happen if clicked,
- where the user currently is.

Hover styling must use the ACTIVE CHEF OS THEME.

Never use:
- browser-like blue,
- default GTK blue,
- random purple,
- bright unrelated colors.

Hover should use:
- subtle surface change,
- accent tint or border,
- slight elevation,
- small movement where appropriate.

The active, hovered, focused, pressed and disabled states must all belong to
the same design system.

---

# 13. ONE THEME ENGINE

Create one central Chef OS theme source.

All Chef OS components should consume shared theme tokens.

Conceptually:

BACKGROUND
SURFACE
SURFACE_ALT
TEXT
TEXT_MUTED
ACCENT
BORDER
SUCCESS
WARNING
ERROR
SHADOW
RADIUS
SPACING
FONT

Do not hardcode unrelated colors independently in every CSS/config file.

The theme system must cover:
- dock,
- launcher,
- popovers,
- notifications,
- settings,
- calendar,
- volume,
- Wi-Fi,
- terminal,
- file manager where controllable,
- lock screen,
- workspace indicators,
- application states.

---

# 14. THEME SWITCHING

Settings must provide an Appearance section.

At minimum provide:

- Chef Cream (default)
- Chef Dark
- Chef Olive
- Chef Rose
- Chef Midnight

Themes must be intentional Chef OS themes, not random imported themes.

Changing theme must update the desktop consistently.

No component may remain accidentally light while the rest becomes dark.

No component may retain stale accent colors.

Theme switching must:
1. change the central theme state,
2. update dependent components,
3. reload/re-render what is necessary,
4. verify every major UI surface,
5. save the selected theme persistently.

---

# 15. CUSTOM COLORS

Provide an Appearance -> Colors area.

At minimum allow:
- Accent
- Background
- Surface
- Text
- Border

Use a proper color picker where the environment supports it.

Changes must update the central theme tokens.

Do not create one-off color overrides that break future theme switching.

Provide a reset-to-theme-defaults action.

Persist user choices.

---

# 16. WALLPAPER SELECTOR

Provide:

Appearance -> Wallpaper

Requirements:
- preview available wallpapers,
- choose wallpaper,
- apply immediately,
- preserve aspect ratio,
- support custom local wallpapers,
- optionally support a solid-color background,
- remember the selected wallpaper.

Never stretch a wallpaper simply to fill space.

Where possible, apply wallpaper changes with a subtle transition.

---

# 17. MACOS-INSPIRED SYSTEM POPOVERS

Clicking a system control must NOT open an ugly full application window unless
the feature genuinely requires a full settings application.

Volume, Wi-Fi, date/time, notifications, battery and quick settings should
open compact floating popovers anchored to the clicked dock control.

All popovers must share:
- same surface,
- same border,
- same radius,
- same typography,
- same icon language,
- same hover behavior,
- same shadow,
- same animation,
- current theme.

The content must always have sufficient contrast.

Never allow text to disappear because the active theme changed.

---

# 18. VOLUME / SOUND POPOVER

Clicking volume opens a polished compact sound panel.

It should provide, where supported:
- current output device,
- volume slider,
- mute state,
- input device,
- input level if available,
- sound settings action.

The panel should feel integrated into Chef OS rather than looking like
pavucontrol pasted onto the desktop.

A full mixer may remain available as an advanced action, but the primary click
interaction is the compact Chef OS popover.

---

# 19. WI-FI / NETWORK POPOVER

Clicking network opens a compact network panel.

Provide, where supported:
- connection state,
- active network,
- signal strength,
- available networks,
- lock indicator,
- connect/disconnect,
- network settings action.

Use the same Chef OS popover architecture as volume.

No default GTK styling leakage.

---

# 20. DATE/TIME POPOVER

Clicking date/time opens:
- current date,
- current time,
- calendar,
- navigation between months where practical.

Use the same theme.

The calendar must remain readable in EVERY Chef OS theme.

Current date and time must always be visible somewhere in the main dock.

---

# 21. NOTIFICATIONS

Notifications should be:
- noticeable,
- natural,
- non-intrusive,
- dismissible,
- theme-consistent.

Notification cards must use the active Chef OS theme.

Hover, close and action buttons must match the theme.

Clicking the notification control should open a notification center/popover
rather than an unrelated full-screen application.

---

# 22. SETTINGS / CONTROL CENTER

Settings should feel like part of Chef OS.

Primary categories:

Appearance
- Theme
- Accent colors
- Wallpaper
- Icons
- Fonts
- Animations

Display
- monitor
- resolution/scale information
- available display settings

Sound
- output
- input
- volume

Network
- Wi-Fi
- Ethernet

Notifications
- notification behavior

System
- lock
- logout
- reboot/power

Do not invent settings the system cannot actually support.

---

# 23. ANIMATION SYSTEM

Chef OS must feel smooth and alive.

Use restrained MacOS-inspired motion:
- popover fade/scale from anchor,
- dock hover response,
- workspace transition,
- application appearance/disappearance,
- active-state transitions,
- settings navigation,
- notification entry/dismissal,
- theme transitions where safe,
- wallpaper transition where safe.

Animation rules:
- short,
- smooth,
- subtle,
- responsive.

Do NOT use:
- bouncing everywhere,
- giant zooms,
- excessive blur,
- flashy effects,
- constant motion when nothing is happening.

Respect reduced-motion accessibility if implemented.

---

# 24. APPLICATION TABS AND WINDOW CLOSING

Chef OS must NOT globally hijack application tab behavior.

## Ctrl + W

`Ctrl + W` should be left to the focused application.

Therefore:
- Chrome/Firefox can close their current browser tab.
- file manager can close its current tab if supported.
- terminal applications can handle their own tab behavior.
- applications without tabs behave normally.

Do NOT implement a global rule that turns Ctrl+W into "kill current window."

## Super + W

`Super + W` is the Chef OS window-level close action.

It closes the currently focused application/window.

This distinction is mandatory:

Ctrl+W = application-level current-tab behavior
Super+W = Chef OS current-window close

Verify this with at least:
- browser with multiple tabs,
- file manager with tabs if supported,
- terminal,
- another normal single-window application.

Do not break native application shortcuts.

---

# 25. APPLICATION NAVIGATION / "WHERE AM I?"

The user must always be able to understand:
- active workspace,
- active application,
- focused control,
- hovered control.

Use consistent active states.

Example visual hierarchy:

Workspace 2 = active accent
Browser = active surface/accent
Hovered Settings = subtle accent surface
Inactive controls = neutral

Do not rely on color alone; use shape, border, icon weight or text state too.

---

# 26. TYPOGRAPHY

Prefer modern clean UI fonts actually available on the system.

Preferred:
- Inter
- Noto Sans
- Noto Sans CJK where needed

Monospace:
- JetBrains Mono
- Fira Code

If a proprietary MacOS font is unavailable, DO NOT download unsafe random
fonts. Use the closest installed/reliably installable fallback.

Use consistent typography across Chef OS.

---

# 27. GTK / QT CONSISTENCY

Configure where possible:
- GTK theme,
- GTK color behavior,
- Qt theme,
- icon theme,
- cursor,
- fonts.

The objective is that applications do not suddenly become visually unrelated.

When exact cross-toolkit matching is impossible, prioritize:
1. readability,
2. color consistency,
3. typography,
4. spacing,
5. icon consistency.

---

# 28. TERMINAL

Terminal target:
- dark ink/charcoal,
- warm ivory foreground,
- restrained muted-red accents,
- clean monospace,
- subtle border,
- restrained radius,
- no neon,
- no excessive transparency.

If already correct:
VERIFY and KEEP.

---

# 29. FILE MANAGER

File manager target:
- warm surface,
- charcoal text,
- active selection using Chef accent,
- clean real icons,
- consistent typography,
- generous whitespace,
- no random blue/default styling where controllable.

If already correct:
VERIFY and KEEP.

---

# 30. LAUNCHER

Launcher must match the desktop theme.

It should:
- open from the dock,
- use real application icons,
- show clear search,
- show hover/active states,
- animate smoothly,
- use current theme,
- remain readable in dark and light themes.

Do not create a separate visual language.

---

# 31. AUDIO-REACTIVE MUSIC DISPLAY

When music is actually playing, Chef OS may show a small elegant audio-reactive
waveform/visualizer in the dock or running-application area.

Requirements:
- reacts to actual player/audio state,
- disappears or becomes minimal when nothing is playing,
- does not continuously animate for no reason,
- remains small and premium,
- follows the current theme.

Prefer real player/audio metadata over fake animation.

---

# 32. WORKSPACE + APPLICATION RESPONSIVENESS

All dynamic UI must update without requiring a logout.

Examples:
- open Terminal -> application entry appears,
- open Browser -> entry appears,
- close Browser -> entry disappears,
- switch workspace -> active workspace changes,
- create workspace 4 -> dock updates,
- remove unused workspace -> dock reconciles,
- change theme -> popovers/dock/launcher update,
- change accent -> active states update.

Use event-driven or efficient polling mechanisms appropriate to the environment.

Avoid wasteful tight loops.

---

# 33. NO VISUAL LEAKAGE

After implementing the new system, inspect every major surface for:
- default GTK colors,
- stale red/blue/purple colors,
- wrong border colors,
- unreadable text,
- inconsistent corner radii,
- inconsistent shadows,
- different icon styles,
- different hover behavior,
- oversized panels,
- accidental top bars,
- duplicate controls.

A feature is not complete if its functionality works but its styling belongs
to another system.

---

# 34. ACCESSIBILITY + READABILITY

Every theme must maintain:
- readable text,
- visible focus,
- sufficient contrast,
- usable sliders,
- recognizable states.

Never optimize aesthetics by making content invisible.

The user's report that clicked Wi-Fi/date/etc. contents can become invisible
is a HARD FAIL.

Fix contrast at the shared theme-token level whenever possible.

---

# 35. SAFE CONFIGURATION PRACTICE

Before changing important configuration:
- make a backup,
- identify the active file,
- identify the active process,
- make one controlled change,
- validate syntax,
- reload,
- inspect runtime,
- inspect logs.

Never:
- delete the entire `.config`,
- reinstall the whole desktop blindly,
- erase user data,
- modify unknown VM disks,
- remove useful packages merely because an older rice used them.

---

# 36. OMARCHY / LEGACY CLEANUP

If previous Chef OS work contains Omarchy-derived components:
- identify them,
- classify them as necessary/conflicting/unused/unknown,
- preserve useful generic packages,
- remove only components that conflict with Chef OS.

Chef OS must have its own identity.

Do not simply install another person's complete rice.

---

# 37. RESPONSIVE DESIGN

Do not assume only one resolution.

At minimum reason about:
- 1366x768
- 1920x1080
- 2560x1440
- ultrawide where practical

Scale:
- dock,
- icon size,
- spacing,
- wallpaper composition,
- popovers,
- typography

without destroying the visual hierarchy.

---

# 38. HEALTH CHECK

Maintain a reusable `chef-check` command/script.

It should report:
- compositor,
- display,
- dock/panel,
- workspaces,
- running application detection,
- launcher,
- notifications,
- audio,
- network,
- wallpaper,
- theme,
- fonts,
- icons,
- file manager,
- lock screen,
- startup/login,
- relevant services,
- duplicate/conflicting processes.

A failure should include a useful diagnostic hint.

---

# 39. REQUIRED IMPLEMENTATION PHASES

Use this order unless dependency analysis proves another order is necessary.

PHASE 0 — AUDIT
- identify VM,
- display,
- compositor,
- current UI processes,
- current config,
- current state.

PHASE 1 — FOUNDATION
- backups,
- central Chef theme tokens,
- configuration organization,
- state files.

PHASE 2 — DISPLAY/WALLPAPER
- native resolution,
- scale,
- wallpaper quality,
- artwork geometry.

PHASE 3 — SINGLE LEFT DOCK
- remove conflicting top bar,
- build/refine left dock,
- preserve working functionality.

PHASE 4 — DYNAMIC WORKSPACES
- live workspace discovery,
- active state,
- dynamic creation/removal.

PHASE 5 — DYNAMIC APPLICATIONS
- live window/app detection,
- real application icons,
- active application state.

PHASE 6 — SYSTEM POPOVERS
- volume,
- Wi-Fi,
- date/time,
- notifications,
- battery.

PHASE 7 — SETTINGS / APPEARANCE
- themes,
- colors,
- wallpaper selector,
- icons/fonts,
- animation settings.

PHASE 8 — INTERACTION
- hover states,
- focus states,
- Ctrl+W behavior,
- Super+W behavior,
- keyboard/workspace behavior.

PHASE 9 — MOTION + POLISH
- transitions,
- audio-reactive display,
- micro-interactions,
- spacing,
- typography.

PHASE 10 — INTEGRATION
- remove duplicates,
- check startup,
- check services,
- check logs.

PHASE 11 — COLD REBOOT
- reboot,
- verify everything returns correctly.

PHASE 12 — FINAL ACCEPTANCE
- every requirement PASS.

Do not proceed through a phase merely because commands completed.
Proceed because its requirements PASS.

---

# 40. VISUAL QA LOOP

When a visual mismatch is reported or can be objectively inspected:

INSPECT
-> IDENTIFY ONE MOST IMPORTANT MISMATCH
-> MAKE ONE CONTROLLED CHANGE
-> RELOAD
-> VERIFY
-> RECORD
-> RE-READ SPEC
-> REPEAT

Do not change ten visual variables simultaneously.

If actual screenshot/pixel inspection is available, use it.
If it is not available, use deterministic configuration/runtime checks and
do not claim visual perfection.

---

# 41. FINAL ACCEPTANCE CHECKLIST

ALL must PASS:

[ ] Chef OS has one intentional visual language
[ ] Default theme is warm parchment/cream
[ ] Artwork is right-oriented with negative space
[ ] Native display resolution verified
[ ] Wallpaper sharpness protected
[ ] Primary navigation is LEFT
[ ] Primary navigation is VERTICAL
[ ] No unwanted primary top bar
[ ] No duplicate bar
[ ] Dock geometry is restrained and responsive
[ ] Workspace list is dynamic
[ ] Workspace 1 works
[ ] Workspace 2 works
[ ] Workspace 3 works
[ ] Additional workspaces update dynamically
[ ] Running applications update dynamically
[ ] Real application icons are used
[ ] Active application is obvious
[ ] Hover states are theme-consistent
[ ] Focus states are theme-consistent
[ ] Volume popover is integrated and readable
[ ] Wi-Fi popover is integrated and readable
[ ] Date/calendar popover is integrated and readable
[ ] Notification popover is integrated and readable
[ ] Battery information is readable
[ ] Settings panel matches the theme
[ ] Theme switching works
[ ] Accent color changing works
[ ] Wallpaper selection works
[ ] Theme changes propagate to popovers
[ ] No invisible popup content
[ ] Launcher matches theme
[ ] File manager styling is coherent
[ ] Terminal styling is coherent
[ ] Notifications are coherent
[ ] Ctrl+W remains application-level tab behavior
[ ] Super+W closes the focused window
[ ] Native application shortcuts are not unnecessarily hijacked
[ ] Animations are smooth and restrained
[ ] Audio visualizer responds only when appropriate
[ ] Fonts are consistent
[ ] Icons are consistent
[ ] GTK/QT styling is reconciled where possible
[ ] No conflicting daemons remain
[ ] `chef-check` passes
[ ] Login/autostart works
[ ] Cold reboot works
[ ] Post-reboot verification passes
[ ] build_state.md is current
[ ] requirements_state.md is current
[ ] build_log.md contains the full history

---

# 42. COMPLETION RULE

DO NOT say Chef OS is complete while any requirement is:
- FAIL
- PARTIAL
- UNKNOWN
- BLOCKED without a documented reason

Completion requires:
1. all feasible requirements PASS,
2. integration verification,
3. cold reboot,
4. post-reboot verification,
5. persistent state updated.

Final response:

CHEF OS BUILD COMPLETE

Requirements verified.
Integration verified.
Reboot verified.

State:
`~/.config/chef-os/build_state.md`

Requirements:
`~/.config/chef-os/requirements_state.md`

Log:
`~/.config/chef-os/build_log.md`

If anything remains incomplete, DO NOT use the completion message.
Continue working.

---

# 43. FINAL IDENTITY STATEMENT

Chef OS should feel like:

**a premium, calm, warm, MacOS-inspired workstation designed specifically
around Chef OS — not a Linux desktop wearing a wallpaper.**

The user should be able to glance at the dock and immediately understand:
- where they are,
- what is open,
- what is active,
- what is available,
- what will happen when they click.

Every surface must belong to the same system.

**INSPECT. REASON. MODIFY. VERIFY. RECORD. RE-READ. CONTINUE.**
