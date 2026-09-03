# CHEF OS — V7 MASTER SPECIFICATION
## Dynamic Island + Functional Dynamic Desktops + Autonomous implementation controller

> THIS FILE SUPERSEDES V6.
> Read the ENTIRE file before changing Chef OS.
> Re-read this file after EVERY major step and after every completed repair.
> The coding agent must treat this document as the source of truth.
> Everything in V6 that is not explicitly changed below still applies —
> this file adds two new required systems (Dynamic Island, working Dynamic
> Desktop creation) and tightens verification rules so both are provably
> functional, not just visually present.

---

# 0. WHAT CHANGED FROM V6 (READ THIS FIRST)

Two concrete failures were observed in the running VM and must be fixed
before any further polish work:

1. **"Create Desktop" button does nothing.** The popover renders, an icon
   can be selected, a label can be typed, but pressing "Create Desktop"
   produces no new workspace, no dock update, nothing. This is a hard
   blocker — treat it as REQ-CRITICAL-01.

2. **The top bar is a flat static pill, not a Dynamic Island.** It shows
   "Chef OS" and, when music plays, an always-visible waveform crammed
   into a fixed-width pill. The user wants an iOS-style Dynamic Island:
   compact by default, and it only reveals the now-playing waveform on
   **hover**, expanding outward with a spring animation, then **collapsing
   back down over a short delay** when the pointer leaves — not
   permanently expanded, not a static readout.

Everything else already built (dock, popovers, themes, workspace pills,
icon system) should be preserved and only touched if this file explicitly
says so.

---

# 1. NON-NEGOTIABLE AUTONOMOUS EXECUTION RULES

You are the implementation agent. The user should not have to repeatedly
tell you the next step.

Before starting:
1. Read this entire specification.
2. Read `~/.config/chef-os/build_state.md` if it exists.
3. Read `~/.config/chef-os/requirements_state.md` if it exists.
4. Read recent `~/.config/chef-os/build_log.md` when needed.
5. Inspect the REAL running VM — do not trust prior claims of "done."
6. Determine what is already implemented.

For EVERY requirement classify it:

- PASS = implemented and verified with an actual screenshot/log/command output
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
- a UI element rendering means its click handler works,
- a command succeeding means the feature works end-to-end,
- a previous agent's claim is proof.

**Specifically for this file: "the button is visible" is not evidence it
works. Every interactive control must be verified by actually clicking it
and observing the resulting state change (new workspace appears, dock
re-renders, file on disk updates) — not just that no error was thrown.**

Every major step is:

INSPECT -> BACKUP -> CHANGE -> VALIDATE -> RELOAD -> VERIFY -> RECORD
-> RE-READ THIS SPEC -> CONTINUE

Never perform a giant unrelated batch of changes.

After EVERY major step:
- update build_state.md,
- append build_log.md,
- update requirements_state.md,
- re-read this specification,
- re-read the current state,
- choose the highest-priority incomplete requirement.

If interrupted, resume from the first incomplete requirement. Do not
restart from the beginning.

Do not ask "should I continue?" during normal work. Only stop for a
genuine blocker: an unsafe destructive operation, missing credentials
that cannot be obtained normally, or a choice this spec genuinely cannot
resolve.

---

# 2. PERSISTENT PROJECT MEMORY

Maintain `~/.config/chef-os/build_state.md`, `build_log.md`,
`requirements_state.md` exactly as in V6. These are memory, not proof —
always reconcile against the actual running VM before trusting them.

---

# 3. REQ-CRITICAL-01 — FIX DESKTOP CREATION (BLOCKING, DO THIS FIRST)

The "New Desktop" popover (label field + mandatory icon grid + "Create
Desktop" button) renders correctly but the button is non-functional.
Debug in this order and do not stop until it works end-to-end:

1. **Confirm the click handler fires at all.** Add a temporary log
   statement inside the "Create Desktop" `onClick`. Click it. If nothing
   logs, the handler is not bound — find where the button element is
   defined and verify the event is actually wired to the function, not
   just visually styled as a button.

2. **Confirm icon selection updates real state.** Tapping an icon tile
   must set a state variable (e.g. `selectedIcon`) that the submit
   handler reads — not merely toggle a `.selected` CSS class with no
   backing value. Log the value of `selectedIcon` right before the
   create action runs; if it's `null`/`undefined` even after clicking an
   icon, the click handler on the icon tiles is the actual bug, not the
   create button.

3. **Confirm the workspace-ID allocation logic.** The handler must:
   compute the next unused Hyprland workspace ID (query `hyprctl
   workspaces` or maintain a counter reconciled against it), then run
   `hyprctl dispatch workspace <id>`. Test this exact command manually in
   a terminal with a real number and confirm Hyprland actually switches.
   If the manual command works but the app's call doesn't, the bug is in
   how the shell executes external commands (check for missing shell
   escaping, wrong binary path, or a swallowed non-zero exit code).

4. **Confirm `workspaces.json` is actually written.** After clicking
   Create, `cat ~/.config/chef-os/workspaces.json` — if the new entry
   isn't there, check file path expansion (`$HOME` resolved correctly),
   write permissions, and whether the write call's promise/callback is
   actually awaited before the function returns (a common bug: firing an
   async write and immediately re-rendering from stale data).

5. **Confirm the dock re-renders from the new state without a restart.**
   If the file writes correctly but the dock doesn't update, the dock's
   data source isn't reactively watching `workspaces.json` — wire a file
   watcher or have the create action directly push the new entry into
   the dock's in-memory state instead of relying on a full re-read.

**Verification required before marking this PASS:** type a label, select
an icon, click "Create Desktop," and in the same session observe (a) a
new pill in the dock with the chosen icon, (b) focus switches to the new
workspace, (c) `workspaces.json` on disk contains the new entry. Screenshot
the result.

---

# 4. THE DYNAMIC ISLAND (replaces the flat top strip/pill from V6 §"top branding strip")

## 4.1 Placement and shape

- Top-center of the screen, floating (not edge-to-edge, not full-width).
- Frosted/blurred `SURFACE` background at reduced opacity, fully rounded
  pill shape (radius = height / 2), consistent with the rest of the
  iOS-style popover language already built.
- This is a layer-shell surface (or always-on-top floating surface) with
  an exclusive zone reserved so no window can render through/behind it,
  even in its compact state.

## 4.2 Compact (idle) state — default, at rest

- Small pill, just wide enough for: a tiny ink-seal glyph + "Chef OS"
  wordmark.
- No waveform, no track info visible in this state, regardless of
  whether music is playing or not. The island stays quiet until the user
  actively looks at it.

## 4.3 Hover-triggered expansion

- On mouse hover (pointer enters the island's hit area): the island
  expands outward — width grows, corner radius adjusts proportionally —
  revealing now-playing content, using a spring/bounce easing curve
  (slight overshoot, then settle), 250–350ms.
- **If music is currently playing** (detected via MPRIS or equivalent
  media-player interface): expanded content shows the track's artist/title
  (truncated if long) and a live audio-reactive waveform — thin animated
  bars whose height responds to actual playback data.
- **If no music is playing**: expanded content shows something
  useful-but-quiet instead of an empty waveform — e.g. the currently
  focused application's name, or just the full date. Never show a static
  or fake-animating waveform when nothing is playing.
- The waveform must only animate when audio is actually flowing. At rest
  (paused track, or hover with nothing playing) it must not fake-move.

## 4.4 Collapse behavior

- When the pointer leaves the island, wait a short grace period (~400–
  600ms — enough that briefly overshooting the hit area with the mouse
  doesn't cause flicker) then collapse back to the compact state using
  the same spring easing in reverse (settle back to idle width/shape,
  250–350ms).
- If the pointer re-enters during the grace period, cancel the collapse
  and stay expanded — this should feel like a single continuous
  interaction, not a stutter.

## 4.5 What must NOT happen

- No permanently-expanded island showing a waveform at all times whether
  or not the user is looking at it (this was the V6 mistake).
- No dead/fake waveform animation when nothing is playing.
- No layout jump/flash on expand or collapse — it must be a smooth width
  morph, not a hide/show swap.
- No competing information crammed in at once (e.g. don't show both
  "no music" text and a frozen waveform simultaneously).

## 4.6 Verification required

Two screenshots: (a) idle compact state showing only the "Chef OS"
wordmark, pointer elsewhere on screen; (b) pointer hovering the island
with music actively playing (e.g. via Spotify), showing the expanded
state with a visibly animating waveform and track info. Additionally
confirm via screen recording or described frame-by-frame check that
moving the pointer away causes a delayed, animated collapse back to
compact — not an instant snap.

---

# 5. EVERYTHING BELOW IS UNCHANGED FROM V6 — PRESERVE AS ALREADY SPECIFIED

The following systems were already defined in the V6 spec and remain in
force. Do not re-litigate their design; only repair genuine PARTIAL/FAIL
items found during inspection.

- Core visual identity / color tokens (§5 of V6: Background #F1EBDD,
  Surface #F8F4EA, Surface Alt #E8E0CE, Text #2B2A28, Text Muted #6E6A5F,
  Accent #A6534A, Border #DCD3BE).
- Wallpaper geometry and composition rules.
- Single LEFT vertical dock as primary navigation — no primary horizontal
  top bar (the Dynamic Island in §4 is a separate, small, floating
  element and does NOT count as a "top bar" — it must not stretch
  edge-to-edge or take over top-bar duties like showing every open
  window).
- Left dock information architecture (workspaces, running apps,
  launcher, files, terminal, volume, network, notifications, date,
  settings, power).
- Dynamic workspaces: numbers under the hood, but every NEW workspace
  created through the "+" flow must have a mandatory user-chosen icon
  (no numeric fallback for newly created ones); pre-existing/legacy
  workspaces may still show a plain number until renamed.
- Dynamic running applications, derived from real Hyprland window state.
- Real application icons from desktop entries / icon theme — no emoji,
  no fake 2D placeholders.
- Global theme-consistent hover/focus/active states.
- One central theme engine + theme switching (Chef Cream / Dark / Olive
  / Rose / Midnight) + custom accent/background/surface/text/border
  color pickers + wallpaper selector.
- iOS-style frosted popovers for volume, Wi-Fi, date/calendar,
  notifications, settings — large radii, spring animations, SF-Symbols-
  style consistent icon glyphs, pill-shaped toggles.
- Ctrl+W stays with the focused application (its own tab behavior);
  Super+W is the Chef OS window-close action. Do not globally hijack
  Ctrl+W.
- Typography: Noto Sans/Inter for UI, JetBrains Mono/Fira Code for
  monospace.
- GTK/Qt/icon/cursor consistency across terminal, file manager, launcher.
- No visual leakage: no default GTK colors, no invisible/low-contrast
  text anywhere, no stale accent colors, no duplicate daemons/bars.
- `chef-check` health script.
- Safe configuration practice: backups before edits, no destructive
  blind reinstalls.

---

# 6. IMPLEMENTATION PHASES FOR THIS UPDATE

PHASE A — FIX (blocking)
- REQ-CRITICAL-01: desktop creation, fully debugged and verified.

PHASE B — REPLACE
- Remove the old static top pill/strip entirely.
- Build the Dynamic Island per §4: compact state, hover expansion,
  delayed collapse, conditional waveform, spring easing.

PHASE C — REGRESSION CHECK
- Re-verify every V6 requirement that touches the top of the screen or
  workspace creation still works: dock still full height and unobstructed,
  no leftover process from the old top-strip implementation still running
  (`pgrep`/`ps` check), no duplicate now-playing indicators appearing in
  both the dock and the island.

PHASE D — RECORD
- Update `build_state.md`, `requirements_state.md`, `build_log.md`.
- Re-read this file before declaring anything complete.

---

# 7. FINAL ACCEPTANCE CHECKLIST FOR THIS UPDATE

- [ ] Clicking "Create Desktop" with a label + mandatory icon selected
      produces a new dock pill with that icon, in the same session
- [ ] Focus switches to the newly created workspace automatically
- [ ] `workspaces.json` contains the new entry on disk
- [ ] Old static top pill/strip is fully removed (no leftover process)
- [ ] Dynamic Island renders top-center, floating, frosted, pill-shaped
- [ ] Island is compact/idle by default — no waveform, no track info
      visible without hovering
- [ ] Hovering the island expands it with a visible spring/overshoot
      animation, revealing waveform + track info ONLY if music is
      actually playing
- [ ] If nothing is playing, hover shows a quiet fallback (not a fake or
      frozen waveform)
- [ ] Moving the pointer away triggers a delayed, animated collapse back
      to compact — not an instant snap, not a permanent expanded state
- [ ] Waveform bars only animate while audio is actually flowing
- [ ] No regression: left dock still full height, all icons visible, no
      scrollbars, no duplicate bars
- [ ] All V6 acceptance items remain PASS (theme consistency, popovers,
      contrast, Ctrl+W/Super+W split, etc.)
- [ ] build_state.md / requirements_state.md / build_log.md are current

---

# 8. COMPLETION RULE

Do not say Chef OS is complete while REQ-CRITICAL-01 or the Dynamic
Island requirements are FAIL, PARTIAL, or UNKNOWN. Completion requires
all items in §7 to PASS with actual verification (screenshots/logs/file
contents), plus every still-applicable V6 requirement remaining PASS.

Final response format on completion:

```
CHEF OS V7 UPDATE COMPLETE

Desktop creation: fixed and verified.
Dynamic Island: implemented and verified (idle + hover-expanded states).
Regression check: no V6 requirements broken.

State:    ~/.config/chef-os/build_state.md
Requirements: ~/.config/chef-os/requirements_state.md
Log:      ~/.config/chef-os/build_log.md
```

If anything remains incomplete, do not use this message — keep working.
