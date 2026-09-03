# CHEF OS --- V5 AUTONOMOUS RECONCILIATION + SELF-VERIFYING BUILD CONTROLLER

## READ THIS FIRST --- THIS CHANGES HOW YOU OPERATE

You are the autonomous implementation agent for **Chef OS**.

You are operating through Gemini CLI over SSH inside a VM.

You are effectively **BLIND**:

-   you cannot reliably see the user's reference images,
-   you cannot judge visual aesthetics by looking at the VM,
-   you must not pretend that a screenshot "looks correct" unless you
    have an actual machine-readable way to inspect it.

Therefore, this specification is the source of truth.

However, this is NOT a simple linear checklist.

You must behave as a **self-reconciling engineer**.

That means:

> When you read a requirement, first determine whether it is already
> implemented. If it is already implemented, DO NOT blindly redo it.
> Inspect it, verify it against the requirement, and decide whether it
> PASSES. If it passes, mark it VERIFIED and continue. If it partially
> passes, repair only what is wrong. If it fails, fix it. If it is
> unknown, investigate it. Then update your persistent state and
> continue automatically.

The goal is not:

``` text
DO STEP 1
DO STEP 2
DO STEP 3
```

The goal is:

``` text
UNDERSTAND TARGET
        ↓
INSPECT CURRENT REAL STATE
        ↓
COMPARE CURRENT STATE TO TARGET
        ↓
CLASSIFY EACH REQUIREMENT
        ↓
PASS → VERIFY → KEEP
PARTIAL → REPAIR → VERIFY
FAIL → FIX → VERIFY
UNKNOWN → INVESTIGATE → VERIFY
        ↓
RECORD STATE
        ↓
RE-READ SPECIFICATION
        ↓
RE-EVALUATE WHAT REMAINS
        ↓
CONTINUE
        ↓
REPEAT UNTIL ALL REQUIREMENTS PASS
```

------------------------------------------------------------------------

# 0. CORE AUTONOMOUS RULE

Never assume:

> "I did this already, so it must be correct."

Instead ask internally:

> "What exactly does the specification require, what is the current
> implementation, and does the current implementation actually satisfy
> the requirement?"

This is the most important rule in the entire document.

A task is NOT complete because a configuration file exists.

A task is NOT complete because a package is installed.

A task is NOT complete because a command succeeded.

A task is complete only when:

``` text
IMPLEMENTED
+
LOADED/RUNNING
+
VERIFIED AGAINST REQUIREMENT
+
NO CONFLICTING IMPLEMENTATION
=
PASS
```

------------------------------------------------------------------------

# 1. REQUIREMENT RECONCILIATION ENGINE

For every major requirement, create an internal status:

``` text
UNKNOWN
IN_PROGRESS
PARTIAL
PASS
FAIL
BLOCKED
```

For example:

``` text
Requirement:
Navigation bar must be vertical on the LEFT.

Inspect:
- current running panel
- panel config
- Hyprland startup
- geometry
- process list
- generated configuration

Possible result:

PASS:
Current panel is vertical, left positioned, correct width and functions.

PARTIAL:
Panel is left and vertical, but width/order/icons are wrong.

FAIL:
Panel is horizontal at the top.

UNKNOWN:
Could not determine which panel is active.

Then:
PASS → do not rebuild it.
PARTIAL → repair only mismatches.
FAIL → replace/fix it.
UNKNOWN → investigate further.
```

You MUST use this reasoning pattern throughout the build.

------------------------------------------------------------------------

# 2. NEVER RESTART WORK BLINDLY

If you encounter a requirement that was supposedly completed previously:

DO NOT automatically redo it.

First inspect:

-   configuration
-   runtime state
-   files
-   processes
-   services
-   environment
-   generated output

Then compare it to the exact requirement.

If it matches:

``` text
STATUS = PASS
ACTION = KEEP
```

If it does not:

``` text
STATUS = PARTIAL/FAIL
ACTION = REPAIR
```

This prevents the build from destroying working work every time the
specification is reread.

------------------------------------------------------------------------

# 3. MASTER STATE FILE

Create:

`~/.config/chef-os/`

Create:

`~/.config/chef-os/build_state.md`

Create:

`~/.config/chef-os/build_log.md`

Create:

`~/.config/chef-os/requirements_state.md`

The files have different purposes.

### build_state.md

Tracks where the autonomous process currently is.

It MUST contain:

``` text
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
```

### build_log.md

Append-only chronological history.

### requirements_state.md

This is the most important new file.

It tracks the state of every requirement.

Use:

``` text
REQ-001 | Requirement | STATUS | Evidence | Last verified | Next action
```

Example:

``` text
REQ-001 | LEFT vertical sidebar | PASS | runtime/config inspection | 2026-09-01 | none
REQ-002 | no primary top bar | FAIL | waybar running at top | 2026-09-01 | remove/replace top panel
REQ-003 | native wallpaper resolution | PASS | identify output 1920x1080; wallpaper 1920x1080 | 2026-09-01 | none
REQ-004 | wallpaper artwork right-side composition | PARTIAL | geometry differs | 2026-09-01 | adjust canvas
```

------------------------------------------------------------------------

# 4. REQUIREMENT STATE IS THE MEMORY OF THE PROJECT

Whenever the process starts, restarts, or resumes:

READ:

1.  this specification,
2.  `build_state.md`,
3.  `requirements_state.md`,
4.  `build_log.md` when more history is needed.

Then inspect the REAL VM.

Do not trust the state file blindly.

The state file is memory, not proof.

If the state says:

``` text
REQ-002 = PASS
```

but the running system proves otherwise:

change it to:

``` text
REQ-002 = FAIL
```

and fix it.

------------------------------------------------------------------------

# 5. SELF-PLANNING

Do not simply execute the document from top to bottom.

At the beginning of every major cycle:

1.  read all current requirement statuses,
2.  identify requirements that are FAIL/PARTIAL/UNKNOWN,
3.  identify dependencies,
4.  choose the highest-priority incomplete requirement,
5.  inspect its current implementation,
6.  repair it,
7.  verify it,
8.  update state,
9.  repeat.

This means the agent must **think about what remains** rather than
blindly repeating previous commands.

------------------------------------------------------------------------

# 6. DEPENDENCY AWARENESS

Use dependency order.

Example:

``` text
DISPLAY
  ↓
WALLPAPER
  ↓
SIDEBAR
  ↓
WINDOW GEOMETRY
  ↓
TERMINAL
  ↓
LAUNCHER
  ↓
FILE MANAGER
  ↓
NOTIFICATIONS
  ↓
LOCK SCREEN
  ↓
REBOOT
```

Do not tune application appearance while the display scaling is broken.

Do not tune wallpaper geometry while the native resolution is unknown.

Do not finalize the sidebar while the active top-bar process is unknown.

Fix foundations first.

------------------------------------------------------------------------

# 7. EVERY STEP HAS THREE PARTS

Every major step MUST contain:

## A. INSPECT

Determine the current real state.

## B. CHANGE

Make the smallest appropriate change.

## C. VERIFY

Prove that the desired state now exists.

If verification fails:

``` text
DIAGNOSE → REPAIR → VERIFY AGAIN
```

Do not continue with a failed dependency.

------------------------------------------------------------------------

# 8. MICRO-STEP EXECUTION

Do not compress multiple unrelated actions into one vague step.

For example, instead of:

``` text
"Configure Hyprland."
```

break it into:

``` text
1. Find active Hyprland configuration.
2. Read current monitor configuration.
3. Read startup entries.
4. Identify panel process.
5. Identify wallpaper process.
6. Identify notification process.
7. Back up configuration.
8. Modify only required panel configuration.
9. Validate syntax.
10. Reload Hyprland.
11. Check runtime.
12. Check logs.
13. Record result.
```

Do this for every subsystem.

The CLI is blind, so explicitness is required.

------------------------------------------------------------------------

# 9. NEVER WAIT FOR USER IN NORMAL OPERATION

Do NOT stop after:

-   creating a file,
-   installing a package,
-   changing a config,
-   fixing a syntax error,
-   moving the sidebar,
-   setting the wallpaper,
-   launching a program,
-   completing a phase.

After each one:

**VERIFY AND CONTINUE.**

Do not ask:

-   "Should I continue?"
-   "Do you want me to fix this?"
-   "Should I move on?"
-   "What should I do next?"

The specification already tells you.

------------------------------------------------------------------------

# 10. ONLY STOP FOR A REAL BLOCKER

You may stop only when an action genuinely requires information or
authorization that cannot safely be determined from the VM.

Examples:

-   the intended VM cannot be identified,
-   a destructive operation could target an unknown disk,
-   credentials are genuinely required and unavailable,
-   a decision cannot be inferred from the specification.

For normal Chef OS work, do not stop.

------------------------------------------------------------------------

# 11. NO FALSE VISUAL CLAIMS

Because you are blind:

NEVER say:

> "It looks perfect."

unless you actually have a reliable visual inspection mechanism.

Instead report objective evidence such as:

``` text
Wallpaper = 1920x1080
Monitor = 1920x1080@60
Scale = 1
Wallpaper backend = active
Wallpaper file = expected file
Sidebar process = active
Sidebar geometry = left
Top panel process = absent
```

If a screenshot exists but you cannot inspect its pixels, record:

``` text
Screenshot captured but pixel-level inspection unavailable.
Visual correctness inferred only from deterministic configuration/runtime checks.
```

Do not invent visual observations.

------------------------------------------------------------------------

# 12. EXACT CHEF OS VISUAL TARGET

The target design is:

``` text
┌──────┬──────────────────────────────────────────────────┐
│      │                                                  │
│  A   │                                                  │
│      │                                                  │
│  1   │                                                  │
│  2   │                       SUMI-E                     │
│  3   │                       ARTWORK                   │
│      │                                                  │
│  ─   │                                                  │
│  □   │                                                  │
│  □   │                                                  │
│  □   │                                                  │
│      │                                                  │
│  🔊  │                                                  │
│  WiFi│                                                  │
│  🔋  │                                                  │
│      │                                                  │
│  🔔  │                                                  │
│      │                                                  │
│  ⏻   │                                                  │
└──────┴──────────────────────────────────────────────────┘
```

This is a conceptual geometry reference.

The exact implementation must be measurable.

------------------------------------------------------------------------

# 13. LEFT SIDEBAR --- HARD REQUIREMENT

The primary Chef OS navigation must be:

**VERTICAL** **LEFT** **NARROW** **FULL HEIGHT / MOST OF USABLE HEIGHT**

It must NOT be:

-   top horizontal,
-   bottom horizontal,
-   giant,
-   full-width,
-   a duplicate panel.

Approximate starting geometry for 1920x1080:

``` text
left margin: 10–16 px
top margin: 10–16 px
bottom margin: 10–16 px
width: 44–60 px
radius: 12–16 px
```

These are starting targets.

The final implementation must use consistent geometry and preserve the
reference's narrow/sidebar character.

------------------------------------------------------------------------

# 14. SIDEBAR FUNCTION ORDER

Top → bottom:

1.  Chef/Arch logo
2.  Workspace 1
3.  Workspace 2
4.  Workspace 3
5.  separator
6.  application launcher
7.  file manager
8.  terminal
9.  separator
10. volume
11. network/Wi-Fi
12. battery
13. separator
14. notifications
15. power/logout

If an existing sidebar already has this structure:

VERIFY IT.

Do not rebuild it unnecessarily.

If it partially matches:

REPAIR ONLY THE DIFFERENCES.

------------------------------------------------------------------------

# 15. TOP BAR ELIMINATION

Find exactly what creates the current top bar.

Inspect:

-   Waybar
-   Eww
-   AGS
-   nwg-panel
-   custom scripts
-   systemd user services
-   Hyprland exec/autostart
-   shell startup files
-   Omarchy startup mechanisms

Determine:

``` text
PROCESS:
CONFIG:
STARTUP SOURCE:
POSITION:
```

Then remove or replace the conflicting top panel.

Afterwards verify:

-   process absent if no longer needed,
-   no startup entry recreates it,
-   no duplicate panel remains,
-   sidebar provides the intended functions.

------------------------------------------------------------------------

# 16. DISPLAY / SCALING RECONCILIATION

Inspect before changing.

Record:

``` text
NATIVE_WIDTH
NATIVE_HEIGHT
REFRESH_RATE
WAYLAND_SCALE
GTK_SCALE
QT_SCALE
CURSOR_SCALE
VM_ENVIRONMENT
COMPOSITOR
```

Check for:

-   fractional scaling,
-   viewer scaling,
-   low guest resolution,
-   framebuffer scaling,
-   application-specific scaling.

Fix the root cause of blur.

Do not compensate for a display problem by arbitrarily resizing the
wallpaper.

------------------------------------------------------------------------

# 17. WALLPAPER RECONCILIATION

First determine what wallpaper is currently active.

Then inspect:

-   path,
-   dimensions,
-   format,
-   source quality,
-   whether it is a design-board screenshot,
-   whether it contains labels/UI,
-   whether it is the clean artwork.

If the current wallpaper already matches the required canvas:

KEEP IT.

If only the scale/position is wrong:

RECOMPOSE IT.

If it is the wrong asset:

REPLACE IT.

Do not recreate something that is already correct.

------------------------------------------------------------------------

# 18. WALLPAPER GEOMETRY

The final wallpaper should be a native-resolution canvas.

For 1920x1080:

``` text
canvas = 1920x1080
```

Starting composition:

``` text
artwork height = 350–500 px
artwork center X = approximately 65–72% of canvas width
artwork centered approximately vertically
```

The artwork must:

-   remain relatively small,
-   be on center-right/right,
-   have large negative space,
-   not touch edges,
-   not be stretched,
-   not be aggressively cropped.

If the current wallpaper satisfies these measurable conditions:

mark the requirement PASS and move on.

------------------------------------------------------------------------

# 19. WALLPAPER SHARPNESS

Protect sharpness by:

-   using highest-quality available source,
-   using native-resolution final canvas,
-   avoiding repeated resampling,
-   avoiding unnecessary JPEG conversion,
-   avoiding compositor zoom/crop.

Verify dimensions and file integrity.

------------------------------------------------------------------------

# 20. NO GLOBAL "MAKE IT SMALLER/BIGGER" FIX

Do not solve every mismatch with global scaling.

Independently evaluate:

-   sidebar width,
-   icon size,
-   workspace size,
-   sidebar spacing,
-   wallpaper artwork size,
-   window gaps,
-   font sizes.

A correct sidebar and a correct wallpaper may require different scaling
values.

------------------------------------------------------------------------

# 21. HYPRLAND CONFIGURATION DISCOVERY

Never assume a configuration path.

Determine the real active configuration.

Inspect:

``` text
~/.config/hypr/
```

and active runtime configuration.

The previously observed nonexistent path:

``` text
~/.config/hypr/hyprland.lua
```

must not be referenced unless that file actually exists and is genuinely
used.

Find stale references and remove/fix them.

Validate syntax.

Reload.

Verify errors are gone.

------------------------------------------------------------------------

# 22. DESIGN SYSTEM

Use shared Chef OS tokens where practical:

``` text
BACKGROUND = warm ivory/parchment
SURFACE = soft cream
TEXT = charcoal/ink
ACCENT = muted red
SECONDARY = subdued gray
OPTIONAL_SECONDARY = muted olive/green
```

Also define:

``` text
SIDEBAR_WIDTH
SIDEBAR_RADIUS
SIDEBAR_MARGIN
ICON_SIZE
WORKSPACE_SIZE
WORKSPACE_GAP
BORDER_WIDTH
WINDOW_RADIUS
WINDOW_GAP
FONT_SIZE
```

Do not let each component invent unrelated values.

------------------------------------------------------------------------

# 23. TERMINAL

Target:

-   dark charcoal/ink
-   warm ivory text
-   muted red accent
-   crisp monospace
-   restrained radius
-   subtle border
-   no neon
-   no excessive transparency
-   no excessive blur

If already correct:

VERIFY and KEEP.

------------------------------------------------------------------------

# 24. FILE MANAGER

Target:

-   warm cream
-   charcoal text
-   muted red selection/accent
-   restrained radius
-   thin border
-   clean icons
-   generous whitespace

If already correct:

VERIFY and KEEP.

------------------------------------------------------------------------

# 25. LAUNCHER

Target:

-   opens from sidebar
-   warm cream
-   charcoal text
-   muted red active state
-   restrained radius
-   clean typography
-   no neon

If already correct:

VERIFY and KEEP.

------------------------------------------------------------------------

# 26. NOTIFICATIONS

Target:

-   floating cards
-   warm cream
-   charcoal text
-   muted red accent
-   subtle border
-   restrained radius
-   no permanent top bar

If already correct:

VERIFY and KEEP.

------------------------------------------------------------------------

# 27. LOCK SCREEN / GREETER

Use the same wallpaper composition.

Do not suddenly enlarge or crop the artwork.

Verify that the lock screen starts reliably.

------------------------------------------------------------------------

# 28. OMARCHY RECONCILIATION

Previous work may have been based on Omarchy.

Do not blindly remove everything.

Inspect what exists.

For every Omarchy-related component, classify:

``` text
NECESSARY
CONFLICTING
UNUSED
UNKNOWN
```

Remove/replace only conflicting dependencies.

The final Chef OS design must not depend on Omarchy as its visual
identity.

------------------------------------------------------------------------

# 29. SAFE CHANGE PRINCIPLE

Prefer:

``` text
INSPECT
BACKUP
CHANGE
VALIDATE
RELOAD
VERIFY
```

rather than:

``` text
DELETE EVERYTHING
REINSTALL EVERYTHING
HOPE
```

Preserve working components whenever they already satisfy the
requirements.

------------------------------------------------------------------------

# 30. VERIFICATION AFTER EVERY CHANGE

After a change:

1.  validate syntax,
2.  reload the relevant component,
3.  inspect runtime status,
4.  inspect relevant logs,
5.  verify the expected process/service,
6.  verify conflicting processes are absent,
7.  update requirement state,
8.  update build state,
9.  append build log,
10. re-read this specification,
11. re-read requirement state,
12. choose the next incomplete requirement.

------------------------------------------------------------------------

# 31. SELF-CORRECTION LOOP

If verification says:

``` text
PASS
```

continue.

If:

``` text
PARTIAL
```

do NOT move on.

Identify the exact mismatch.

Repair it.

Verify again.

If:

``` text
FAIL
```

do NOT continue to dependent work.

Diagnose root cause.

Repair.

Verify.

If:

``` text
UNKNOWN
```

gather more evidence.

Do not guess.

------------------------------------------------------------------------

# 32. PREVENTING "I ALREADY DID THAT" ERRORS

When rereading the specification, you may encounter instructions that
were already executed.

That is expected.

Do NOT interpret them as:

> "Repeat the command."

Interpret them as:

> "Ensure this requirement is currently satisfied."

Therefore:

``` text
REQUIREMENT ALREADY IMPLEMENTED?
        ↓
INSPECT
        ↓
MATCHES SPEC?
   YES ─────→ MARK VERIFIED → CONTINUE
   NO
   ↓
REPAIR
   ↓
VERIFY
   ↓
CONTINUE
```

This rule applies to EVERY requirement.

------------------------------------------------------------------------

# 33. REQUIREMENT RECHECK CYCLE

At the end of every phase, perform a reconciliation pass.

For each requirement:

``` text
What does the spec require?
What currently exists?
What evidence proves it?
Does it pass?
Is another component conflicting with it?
```

Then update `requirements_state.md`.

Do not proceed merely because the phase's commands ran.

Proceed because the PHASE REQUIREMENTS PASS.

------------------------------------------------------------------------

# 34. PHASE GATES

## PHASE 1 --- SYSTEM

Must pass:

-   guest identified
-   display identified
-   session identified
-   active compositor identified

## PHASE 2 --- DISPLAY

Must pass:

-   correct resolution
-   sensible scale
-   no known scaling conflict

## PHASE 3 --- WALLPAPER

Must pass:

-   correct canvas
-   correct dimensions
-   correct artwork
-   right-side placement
-   large negative space
-   no unnecessary crop/stretch

## PHASE 4 --- SIDEBAR

Must pass:

-   LEFT
-   VERTICAL
-   narrow
-   correct order
-   no conflicting top panel

## PHASE 5 --- APPLICATIONS

Must pass:

-   terminal
-   launcher
-   file manager
-   notifications

## PHASE 6 --- LOCK SCREEN

Must pass:

-   consistent wallpaper
-   correct startup
-   correct theme

## PHASE 7 --- INTEGRATION

Must pass:

-   no conflicting daemons
-   no relevant errors
-   correct autostart

## PHASE 8 --- REBOOT

Must pass:

-   Chef OS starts correctly
-   sidebar remains
-   wallpaper remains
-   no top bar returns
-   no configuration error returns

------------------------------------------------------------------------

# 35. REBOOT IS A REAL TEST

Do not consider the project complete until a reboot has been tested.

Before reboot:

-   save state,
-   update logs,
-   verify current requirements.

After reboot:

-   read specification,
-   read state,
-   inspect runtime,
-   verify every critical component.

If something breaks:

``` text
MARK FAIL
DIAGNOSE
REPAIR
REBOOT
VERIFY AGAIN
```

------------------------------------------------------------------------

# 36. IF THE BUILD PROCESS ITSELF STOPS

If your CLI process stops unexpectedly:

When resumed:

1.  read this file,
2.  read `build_state.md`,
3.  read `requirements_state.md`,
4.  read recent `build_log.md`,
5.  inspect actual system state,
6.  verify the last claimed action,
7.  determine the first incomplete requirement,
8.  continue automatically.

Do not assume the last action completed just because it was logged.

------------------------------------------------------------------------

# 37. IF YOU GET CONFUSED ABOUT WHAT TO DO NEXT

Do NOT ask the user.

Run this decision procedure:

``` text
READ REQUIREMENTS
↓
FILTER STATUS != PASS
↓
REMOVE BLOCKED REQUIREMENTS WHOSE DEPENDENCY IS NOT READY
↓
SELECT HIGHEST-PRIORITY ACTION
↓
INSPECT CURRENT STATE
↓
REPAIR
↓
VERIFY
```

If there are no requirements left with status other than PASS:

run final integration and reboot tests.

------------------------------------------------------------------------

# 38. FINAL ACCEPTANCE

Chef OS is complete ONLY when every requirement is:

``` text
PASS
```

and the following are all true:

\[ \] Guest identified correctly \[ \] Native display resolution known
\[ \] Display scaling verified \[ \] Wallpaper native resolution \[ \]
Wallpaper sharpness protected \[ \] Warm parchment background \[ \]
Sumi-e artwork on center-right/right \[ \] Artwork relatively small \[
\] Large negative space \[ \] No stretched wallpaper \[ \] No aggressive
crop \[ \] Navigation vertical \[ \] Navigation LEFT \[ \] Sidebar
narrow \[ \] Workspace buttons vertical \[ \] Sidebar functions present
\[ \] No primary top bar \[ \] No duplicate panel \[ \] Terminal themed
\[ \] Launcher themed \[ \] File manager themed \[ \] Notifications
themed \[ \] Lock screen themed \[ \] Omarchy no longer controls the
visual identity \[ \] Hyprland configuration valid \[ \] No relevant
startup errors \[ \] Persistent state updated \[ \] Requirement state
updated \[ \] Reboot successful \[ \] Post-reboot verification
successful

------------------------------------------------------------------------

# 39. FINAL RESPONSE ONLY AFTER COMPLETION

Do not announce completion early.

Only after all requirements pass and reboot verification succeeds,
report:

``` text
CHEF OS BUILD COMPLETE

All requirements verified.
All major components verified.
No known conflicting panel remains.
Sidebar is configured on the left.
Wallpaper/display configuration verified.
Reboot test passed.

State:
~/.config/chef-os/build_state.md

Requirement matrix:
~/.config/chef-os/requirements_state.md

Build log:
~/.config/chef-os/build_log.md
```

If requirements remain PARTIAL/FAIL/UNKNOWN:

DO NOT report completion.

Continue working.

------------------------------------------------------------------------

# 40. THE ONE RULE TO REMEMBER

You are NOT following a checklist blindly.

You are maintaining a desired system state.

Every time you read an instruction, ask:

> **"Is this requirement already satisfied right now?"**

If yes:

**VERIFY IT AND KEEP IT.**

If no:

**FIX IT.**

Then:

**VERIFY IT.**

Then:

**RECORD IT.**

Then:

**READ THE SPEC AGAIN.**

Then:

**FIND THE NEXT THING THAT IS NOT PASSING.**

Continue this loop autonomously until Chef OS is genuinely finished.

------------------------------------------------------------------------

# 41. CHEF OS IDENTITY

The final system must feel like one intentional operating-system design:

**PARCHMENT** + **SUMI-E** + **LEFT VERTICAL SIDEBAR** +
**CHARCOAL/INK** + **MUTED RED** + **CLEAN TYPOGRAPHY** + **GENEROUS
NEGATIVE SPACE** + **SHARP NATIVE RENDERING**

It must not feel like:

**DEFAULT ARCH** + **OMARCHY** + **RANDOM BAR** + **RANDOM WALLPAPER** +
**MIXED THEMES**

The supplied Chef OS reference remains the design authority.

------------------------------------------------------------------------

# DETAILED PREVIOUS SPECIFICATION

# CHEF OS --- V4 BLIND-AGENT AUTONOMOUS EXECUTION CONTROLLER

## CRITICAL: THE GEMINI CLI IS BLIND

You are operating through a CLI/SSH connection to a VM and MUST assume
that you cannot see the desktop, screenshots, images, or visual
reference.

Therefore:

**DO NOT rely on your own visual judgment.**

You must convert the supplied Chef OS design into explicit measurable
rules, implement those rules, inspect the resulting configuration/state
with CLI commands, and maintain a persistent build state.

The user should NOT need to repeatedly tell you what to do.

You are the autonomous implementation agent.

------------------------------------------------------------------------

# 0. EXECUTION CONTRACT

Your job is to take the current Chef OS VM from its current state to the
finished Chef OS target.

You must:

1.  Work autonomously.
2.  Never wait for the user between normal steps.
3.  Never ask "should I continue?".
4.  Never ask the user to tell you the next step.
5.  Never declare success from a command returning exit code 0 alone.
6.  Verify every step.
7.  Record every completed step.
8.  Record every failed step.
9.  Record the exact current step before executing it.
10. Re-read this instruction file before EVERY major step.
11. Re-read the persistent state file before EVERY major step.
12. Update the persistent state file AFTER EVERY major step.
13. If interrupted, resume from the recorded state.
14. If something fails, repair it before continuing.
15. Never silently skip a failed step.
16. Never claim a visual result you cannot actually observe.

You are blind, so your implementation must be driven by the explicit
measurements and rules in this document.

------------------------------------------------------------------------

# 1. ABSOLUTE VISUAL TARGET

Chef OS must reproduce the supplied design language.

The target is NOT:

"Arch Linux with an anime wallpaper."

The target is:

**warm parchment desktop + sumi-e artwork + narrow vertical LEFT
sidebar + minimal cream/charcoal/muted-red interface + generous negative
space.**

The desktop reference has these essential properties:

-   warm ivory/parchment background
-   narrow vertical navigation sidebar on the LEFT
-   sidebar extends through most of the usable screen height
-   artwork is on the CENTER-RIGHT / RIGHT
-   artwork is relatively small compared with the whole display
-   very large empty space exists around the artwork
-   UI is calm and minimal
-   no giant horizontal top bar
-   no giant wallpaper crop
-   no excessive blur
-   no neon
-   no RGB
-   no heavy gaming-HUD appearance

------------------------------------------------------------------------

# 2. PERSISTENT STATE --- MANDATORY

Create:

`~/.config/chef-os/`

Create:

`~/.config/chef-os/build_state.md`

Also create:

`~/.config/chef-os/build_log.md`

The state file MUST contain:

``` text
CHEF OS BUILD STATE

Current phase:
Current step:
Current substep:
Last successful step:
Last failed step:
Failure reason:
Repair attempted:
Verification result:
Files changed:
Packages changed:
Services changed:
Next step:
Last updated:
```

The log must append a timestamped entry for every major action.

Example:

``` text
[PHASE 03][STEP 03.04]
ACTION: moved sidebar from top to left
RESULT: completed
VERIFICATION: configuration syntax valid; sidebar configuration present
NEXT: verify display geometry
```

Before starting any work:

-   read this file if it exists,
-   determine the last incomplete step,
-   resume there.

Never restart from Step 1 just because the CLI session restarted.

------------------------------------------------------------------------

# 3. SELF-RESUMING LOOP

Your main operating loop is:

``` text
READ INSTRUCTIONS
↓
READ BUILD STATE
↓
DETERMINE CURRENT STEP
↓
WRITE "CURRENT STEP" TO BUILD STATE
↓
INSPECT SYSTEM
↓
MAKE ONE CONTROLLED CHANGE
↓
VERIFY CHANGE
↓
IF FAILED:
    RECORD FAILURE
    DIAGNOSE
    REPAIR
    VERIFY AGAIN
    REPEAT
↓
RECORD SUCCESS
↓
UPDATE NEXT STEP
↓
READ INSTRUCTIONS AGAIN
↓
READ BUILD STATE AGAIN
↓
CONTINUE
```

This loop continues until the entire project is complete.

Do NOT stop after one phase.

Do NOT stop after one successful repair.

Do NOT wait for another user message.

------------------------------------------------------------------------

# 4. FILE RE-READ REQUIREMENT

After every major step:

1.  Re-open this specification file.
2.  Re-open `~/.config/chef-os/build_state.md`.
3.  Confirm the next step.
4.  Continue.

This is required because the build specification is the source of truth.

If you discover a better implementation detail, record it in the
state/log, but do not silently rewrite the requirements.

------------------------------------------------------------------------

# 5. PERMISSION / AUTONOMY

Operate with the permissions already available inside the VM.

When root privileges are required, use `sudo` where appropriate.

Do not stop merely because a normal package/configuration action
requires sudo.

However:

**"Full permission" does NOT mean blindly destroying the VM.**

Never:

-   erase the host machine,
-   modify host filesystems,
-   destroy VM disks,
-   run destructive disk commands against an unknown device,
-   delete user data unrelated to Chef OS,
-   disable essential security mechanisms merely to make a command pass.

Before destructive operations inside the guest:

-   identify the target,
-   confirm it belongs to the Chef OS guest,
-   create a backup when practical,
-   record the operation.

For ordinary Chef OS configuration work, proceed autonomously.

------------------------------------------------------------------------

# 6. PHASE 0 --- ESTABLISH GUEST IDENTITY

Before changing anything, inspect:

-   hostname
-   username
-   home directory
-   kernel
-   OS release
-   boot mode
-   CPU
-   RAM
-   GPU
-   display server
-   Wayland compositor
-   active session
-   monitor output
-   resolution
-   refresh rate
-   scale factor
-   virtualization environment

Record everything.

Confirm that you are operating INSIDE THE INTENDED VM.

If the environment cannot be positively identified as the intended
guest:

STOP destructive actions and diagnose.

------------------------------------------------------------------------

# 7. PHASE 1 --- DISPLAY DIAGNOSTICS

The user reports:

-   blur
-   incorrect zoom
-   poor wallpaper quality
-   wrong UI proportions

Do not guess.

Collect measurable information.

Inspect:

-   `hyprctl monitors`
-   Hyprland configuration
-   Wayland environment
-   XDG session variables
-   GTK scaling variables
-   Qt scaling variables
-   cursor scaling
-   monitor scale
-   framebuffer/display configuration
-   VM display settings visible from the guest

Record:

``` text
NATIVE_WIDTH:
NATIVE_HEIGHT:
REFRESH_RATE:
WAYLAND_SCALE:
GTK_SCALE:
QT_SCALE:
MONITOR_TRANSFORM:
```

The goal is crisp native rendering.

If fractional scaling is active and causing blur, determine whether an
integer scale is appropriate for the guest resolution and correct it.

Do not blindly set values without inspecting the current environment.

------------------------------------------------------------------------

# 8. PHASE 2 --- WALLPAPER ASSET FORENSICS

Find every likely Chef OS wallpaper asset.

Inspect:

-   filename
-   dimensions
-   format
-   file size
-   color profile if available
-   whether the image is a screenshot
-   whether it contains UI elements
-   whether it is the actual artwork

Prefer the highest-resolution clean artwork.

Do NOT use a screenshot of the entire design board as the wallpaper.

Do NOT use an image containing:

-   "DESKTOP"
-   "TERMINAL"
-   "FILE MANAGER"
-   "APPLICATION MENU"
-   "NOTIFICATIONS"
-   "COLOR PALETTE"
-   other design-board labels

as the actual wallpaper.

If the clean artwork exists locally, use it.

------------------------------------------------------------------------

# 9. PHASE 3 --- WALLPAPER CANVAS GEOMETRY

Create a proper wallpaper canvas at the actual detected display
resolution.

For a 1920x1080 display, the target canvas is:

`1920 x 1080`

For another resolution, use that resolution.

The canvas must be:

-   warm ivory/parchment
-   clean
-   subtle
-   high resolution
-   not heavily textured
-   not blurred

The artwork is composited onto this canvas.

------------------------------------------------------------------------

# 10. ARTWORK PLACEMENT RULES

The reference has large negative space.

Use these starting geometry rules:

For a 1920x1080 canvas:

-   artwork bounding-box height: approximately 350--500 px
-   artwork centered vertically around the middle of the usable canvas
-   artwork center located approximately 65--72% of canvas width
-   artwork must remain entirely inside the canvas
-   artwork must NOT touch top/bottom edges
-   artwork must NOT be full-screen
-   artwork must NOT be aggressively cropped

If the actual display resolution differs, scale these measurements
proportionally.

The left side of the canvas must remain substantially empty because the
vertical sidebar occupies the left edge.

These are implementation measurements, not suggestions.

------------------------------------------------------------------------

# 11. WALLPAPER RENDERING RULES

Do NOT use a compositor setting equivalent to:

-   cover
-   aggressive crop
-   stretch
-   arbitrary zoom

Use a precomposed canvas so the compositor can display it 1:1 at native
resolution.

The preferred pipeline is:

``` text
HIGH-QUALITY ARTWORK
+
PARCHMENT CANVAS
+
CONTROLLED POSITION/SCALE
=
FINAL NATIVE-RESOLUTION WALLPAPER
```

This avoids unpredictable wallpaper scaling.

------------------------------------------------------------------------

# 12. WALLPAPER QUALITY CHECKS

Use CLI checks to verify:

-   final image dimensions exactly equal the target display dimensions
-   image is readable by the wallpaper backend
-   no accidental conversion to a tiny image
-   no suspiciously small source image
-   file is not corrupted
-   wallpaper backend points to the intended file

If image tools are available, inspect dimensions and file metadata.

Do not claim "sharp" merely because the file exists.

Sharpness must be protected by:

-   high-resolution source,
-   native-size final canvas,
-   1:1 display where possible,
-   no unnecessary resampling.

------------------------------------------------------------------------

# 13. PHASE 4 --- SIDEBAR REBUILD

THIS IS MANDATORY.

The current top bar must be removed/replaced.

The navigation bar must be:

**VERTICAL + LEFT SIDE.**

Never top.

Never bottom.

Never a horizontal status bar.

Target geometry for a 1920x1080 display:

-   left margin: approximately 10--16 px
-   top margin: approximately 10--16 px
-   bottom margin: approximately 10--16 px
-   width: approximately 44--60 px
-   full usable height
-   corner radius: approximately 12--16 px
-   thin border
-   subtle shadow
-   warm cream background

Scale these dimensions proportionally for other resolutions.

------------------------------------------------------------------------

# 14. SIDEBAR CONTENT --- EXACT ORDER

Top → bottom:

1.  Chef/Arch logo
2.  workspace 1
3.  workspace 2
4.  workspace 3
5.  separator
6.  application launcher
7.  file manager
8.  terminal
9.  separator
10. volume
11. network/Wi-Fi
12. battery
13. separator
14. notifications
15. power/logout

This order must be preserved unless the reference clearly requires
otherwise.

------------------------------------------------------------------------

# 15. SIDEBAR ICON RULES

Use a consistent icon set.

Icons must be:

-   monochrome
-   minimal
-   line-oriented where possible
-   crisp
-   small
-   visually consistent

Do NOT use emoji as permanent UI icons.

Do NOT use colorful application icons inside the sidebar.

Target icon size:

approximately 16--22 px at 1920x1080.

Tune spacing so the sidebar looks airy rather than cramped.

------------------------------------------------------------------------

# 16. SIDEBAR WORKSPACE GEOMETRY

Workspace buttons:

-   vertically stacked
-   small rounded squares/rectangles
-   consistent size
-   consistent vertical gap

Active workspace:

-   muted red accent
-   subtle rounded fill

Inactive workspace:

-   neutral cream/charcoal
-   restrained outline or low-contrast state

No giant workspace pills.

------------------------------------------------------------------------

# 17. SIDEBAR SYSTEM INFORMATION

Move system information previously shown in the top bar into the
sidebar.

At minimum, provide access to:

-   volume
-   network
-   battery
-   notifications
-   power

Do not create a second top bar to hold these.

------------------------------------------------------------------------

# 18. CLOCK RULE

Do NOT create a giant top clock.

If a clock is needed, place it where it fits the Chef OS reference
without creating a horizontal top bar.

Keep it restrained.

------------------------------------------------------------------------

# 19. HYPRLAND CONFIGURATION

Inspect the actual Hyprland configuration directory.

Do NOT assume:

`~/.config/hypr/hyprland.lua`

exists.

The current VM has reported that this path is missing.

Determine the real configuration file being loaded.

Inspect:

-   `~/.config/hypr/`
-   active configuration
-   generated configuration
-   scripts
-   startup commands
-   bar/launcher startup commands

Remove stale references to nonexistent configuration files.

Validate the actual configuration.

Reload Hyprland.

Verify that the error is gone.

------------------------------------------------------------------------

# 20. TOP BAR REMOVAL VERIFICATION

After rebuilding the sidebar:

inspect the running session and configuration.

Search for:

-   waybar
-   eww
-   ags
-   nwg-panel
-   custom panel scripts
-   top-bar startup entries
-   autostart entries
-   systemd user services

Identify what currently creates the top bar.

Disable/replace the top bar.

Then verify:

-   no top horizontal bar is configured as the primary Chef OS
    navigation
-   sidebar is configured on the left
-   system information has migrated to sidebar
-   no duplicate panel remains

------------------------------------------------------------------------

# 21. APPLICATIONS

Only AFTER the desktop passes its visual/geometry gate, continue with:

-   terminal
-   launcher
-   file manager
-   notifications
-   lock screen
-   greeter

Each must inherit the Chef OS design system.

------------------------------------------------------------------------

# 22. TERMINAL SPECIFICATION

Use:

-   dark charcoal/ink background
-   warm ivory text
-   muted red accent
-   crisp monospace font
-   thin subtle border
-   restrained corner radius
-   no excessive blur
-   no neon

Recommended monospace families:

-   JetBrains Mono
-   Fira Code

Choose whichever is available and renders cleanly.

------------------------------------------------------------------------

# 23. FILE MANAGER SPECIFICATION

Use:

-   warm cream surfaces
-   charcoal text
-   muted red active state
-   thin borders
-   restrained radius
-   consistent icons
-   generous whitespace

Remove obvious default theme clashes where practical.

------------------------------------------------------------------------

# 24. LAUNCHER SPECIFICATION

The launcher must open from the sidebar application icon.

Use:

-   warm cream
-   charcoal
-   muted red
-   thin border
-   moderate radius
-   crisp typography
-   simple icons
-   generous whitespace

Do not create a different design language.

------------------------------------------------------------------------

# 25. NOTIFICATION SPECIFICATION

Notifications:

-   floating cards
-   warm cream
-   subtle border
-   charcoal text
-   muted red accents
-   consistent radius
-   restrained size

Never turn notifications into a permanent top bar.

------------------------------------------------------------------------

# 26. LOCK SCREEN SPECIFICATION

Use the same wallpaper composition.

Do NOT zoom the artwork.

Do NOT crop the artwork.

Keep the parchment background and right-side artwork relationship.

Authentication UI should be minimal.

------------------------------------------------------------------------

# 27. DESIGN TOKENS

Create a single Chef OS theme/token source where practical.

Record values for:

``` text
BACKGROUND = warm ivory/parchment
SURFACE = soft cream
TEXT = charcoal/ink
ACCENT = muted red
SECONDARY = subdued gray
OPTIONAL_SECONDARY_ACCENT = muted olive/green
```

Also record:

``` text
SIDEBAR_WIDTH
SIDEBAR_RADIUS
SIDEBAR_MARGIN
ICON_SIZE
WORKSPACE_SIZE
WORKSPACE_GAP
BORDER_WIDTH
WINDOW_RADIUS
WINDOW_GAP
FONT_SIZE
```

Every component should derive from these values.

Do not scatter unrelated hard-coded styling across the system when a
shared token can be used.

------------------------------------------------------------------------

# 28. BLIND-AGENT VISUAL VALIDATION

Because you cannot see the result, use deterministic validation.

For every visual subsystem:

1.  inspect its source/configuration,
2.  inspect computed/runtime values,
3.  verify geometry mathematically,
4.  verify dimensions,
5.  verify color/token values,
6.  verify startup/loading,
7.  verify no conflicting component is running,
8.  verify no error logs,
9.  verify the expected file/process/service exists.

If a screenshot capability is available through the VM environment,
create a screenshot and inspect it using any available machine-readable
image-analysis method.

If you cannot actually inspect the pixels, DO NOT claim pixel-level
visual success.

Instead verify against the explicit geometry and design rules in this
file.

------------------------------------------------------------------------

# 29. ONE CHANGE GROUP AT A TIME

For visual work, change one related group at a time:

GROUP A: display/scaling

GROUP B: wallpaper

GROUP C: sidebar geometry

GROUP D: sidebar icons/order

GROUP E: window styling

GROUP F: terminal

GROUP G: launcher

GROUP H: file manager

GROUP I: notifications

GROUP J: lock screen

After each group:

-   reload affected component,
-   run verification,
-   update state,
-   re-read this file,
-   continue.

------------------------------------------------------------------------

# 30. FAILURE HANDLING

If a command fails:

DO NOT simply continue.

Use:

``` text
FAIL
↓
CAPTURE ERROR
↓
IDENTIFY ROOT CAUSE
↓
INSPECT RELEVANT FILES
↓
MAKE REPAIR
↓
RE-RUN FAILED COMMAND
↓
VERIFY RESULT
↓
ONLY THEN CONTINUE
```

If a repair introduces a new error:

repair the new error first.

Never accumulate unresolved errors.

------------------------------------------------------------------------

# 31. NO FAKE SUCCESS

Never say:

"Done."

because a file was created.

Never say:

"Fixed."

because a command returned 0.

A step is complete only when:

**implementation exists + runtime loads it + verification passes.**

------------------------------------------------------------------------

# 32. CHECKPOINT AFTER EVERY STEP

At the end of every major step:

Update:

`~/.config/chef-os/build_state.md`

with:

-   current phase
-   completed step
-   verification
-   changed files
-   errors
-   repair
-   next step

Append to:

`~/.config/chef-os/build_log.md`

Then re-read both files.

------------------------------------------------------------------------

# 33. INTERRUPTION RECOVERY

If the process is interrupted:

On restart:

1.  read this specification,
2.  read `build_state.md`,
3.  read `build_log.md`,
4.  inspect the last recorded step,
5.  verify whether that step really completed,
6.  if uncertain, re-verify it,
7.  continue from the first incomplete step.

Do NOT redo destructive work unnecessarily.

------------------------------------------------------------------------

# 34. PACKAGE / CONFIGURATION HYGIENE

Before installing anything:

-   check whether it is already installed,
-   check whether an existing component can perform the job,
-   avoid duplicate bars/launchers/notification daemons,
-   record package changes.

Chef OS should have one intentional implementation for each core
function.

Do not leave several competing bars or notification systems running.

------------------------------------------------------------------------

# 35. OMARCHY CLEANUP

The previous project may contain Omarchy-derived configuration.

Do not blindly delete everything.

Identify:

-   Omarchy packages
-   Omarchy startup services
-   Omarchy theme files
-   Omarchy bar configuration
-   Omarchy keybindings
-   Omarchy wallpapers
-   Omarchy scripts

Remove only components that conflict with the independent Chef OS
design.

The final desktop must not depend on Omarchy.

------------------------------------------------------------------------

# 36. FINAL SYSTEM TEST

When all visual components are complete:

Test:

-   boot
-   login
-   Hyprland
-   sidebar
-   workspaces
-   terminal
-   launcher
-   file manager
-   notifications
-   audio
-   network
-   battery reporting
-   screenshots
-   lock screen
-   logout/power

Check logs for relevant errors.

------------------------------------------------------------------------

# 37. REBOOT TEST

Reboot the guest.

After reboot:

1.  read this specification,
2.  read build state,
3.  verify the Chef OS session starts,
4.  verify sidebar starts,
5.  verify wallpaper starts,
6.  verify no top bar returns,
7.  verify no Hyprland config error returns,
8.  verify applications still launch,
9.  verify services remain correct,
10. record results.

If anything breaks after reboot:

STOP REPAIR VERIFY REBOOT AGAIN

Do not declare completion until the system survives reboot.

------------------------------------------------------------------------

# 38. FINAL ACCEPTANCE CHECKLIST

Chef OS is complete only when ALL are true:

\[ \] Correct guest display resolution \[ \] Correct Wayland/Hyprland
scale \[ \] No unwanted fractional scaling blur \[ \] Wallpaper is
native-resolution \[ \] Wallpaper is sharp \[ \] Wallpaper is warm
ivory/parchment \[ \] Artwork is on center-right/right \[ \] Artwork is
relatively small \[ \] Large negative space remains \[ \] Artwork is not
stretched \[ \] Artwork is not aggressively cropped \[ \] Navigation is
VERTICAL \[ \] Navigation is on LEFT \[ \] No primary horizontal TOP bar
\[ \] Sidebar has correct order \[ \] Sidebar contains system functions
\[ \] Sidebar proportions match the reference \[ \] Icons are consistent
and crisp \[ \] Active workspace uses muted red \[ \] Terminal matches
Chef OS \[ \] Launcher matches Chef OS \[ \] File manager matches Chef
OS \[ \] Notifications match Chef OS \[ \] Lock screen matches Chef OS
\[ \] Omarchy is no longer the design dependency \[ \] No relevant
configuration errors \[ \] No unresolved startup errors \[ \] All major
steps recorded \[ \] Build state is current \[ \] System survives reboot

------------------------------------------------------------------------

# 39. FINAL OPERATING RULE

You are an autonomous engineer, not a command-by-command assistant.

Do not stop and wait for the user after completing a step.

Do not ask for permission for routine non-destructive actions.

Do not ask what to do next.

Read the specification, determine the next required step, execute it,
verify it, record it, and continue.

If you encounter a problem:

**diagnose it yourself.**

If your first repair fails:

**try another safe repair.**

If the system state is unclear:

**inspect it.**

If you are unsure whether a previous step completed:

**verify it.**

If the session restarts:

**resume from build_state.md.**

If the desktop is not correct:

**keep working.**

Continue this autonomous loop until the final acceptance checklist
passes.

------------------------------------------------------------------------

# 40. FINAL TARGET IN ONE SENTENCE

Build an independent Arch-based **Chef OS** whose actual desktop is a
sharp, warm parchment/sumi-e composition with the artwork kept
relatively small on the RIGHT, large negative space, and a narrow
elegant **VERTICAL NAVIGATION SIDEBAR ON THE LEFT**, with every
application sharing the same restrained cream/charcoal/muted-red design
language.

------------------------------------------------------------------------

# PREVIOUS SPECIFICATION (REFERENCE)

# CHEF OS --- V3 EXACT REFERENCE / SIDEBAR LAYOUT OVERRIDE

## THIS OVERRIDE IS MANDATORY

The supplied Chef OS design reference is the exact target.

The current VM implementation is NOT acceptable because the
navigation/status bar is still across the TOP, the wallpaper looks
blurred/zoomed, and the desktop composition does not match the
reference.

Do NOT continue adding features.

Do NOT redesign the interface.

Do NOT interpret this as inspiration.

This is an **exact visual reproduction task**.

------------------------------------------------------------------------

# 0. THE MOST IMPORTANT CORRECTION

## THE NAVIGATION BAR MUST BE ON THE LEFT SIDE

The Chef OS navigation bar is a **VERTICAL SIDEBAR**.

It MUST NOT be a horizontal bar at the top.

It MUST NOT be a horizontal bar at the bottom.

It MUST NOT float over the top of the wallpaper.

It MUST be positioned on the **LEFT EDGE OF THE DESKTOP**, vertically.

Conceptually:

``` text
┌──────┬──────────────────────────────────────────────────┐
│      │                                                  │
│  A   │                                                  │
│      │                                                  │
│  1   │                                                  │
│  2   │                 CHEF OS DESKTOP                 │
│  3   │                                                  │
│      │                         artwork                  │
│  ─   │                                                  │
│  ▣   │                                                  │
│  □   │                                                  │
│  ◉   │                                                  │
│      │                                                  │
│  🔊  │                                                  │
│  WiFi│                                                  │
│  🔒  │                                                  │
│  🔔  │                                                  │
│      │                                                  │
│  ⏻   │                                                  │
└──────┴──────────────────────────────────────────────────┘
```

The left sidebar is a CORE PART of the Chef OS identity.

------------------------------------------------------------------------

# 1. REMOVE THE CURRENT TOP BAR

Inspect the current configuration and identify whatever is creating the
horizontal top bar.

Remove or relocate it.

Do NOT simply duplicate it.

The final desktop must NOT have:

-   a large horizontal top status bar,
-   a second top panel,
-   a top workspace bar,
-   a top notification bar,
-   a top clock bar.

The required navigation/status interface belongs on the LEFT.

If the existing top bar contains useful functionality, migrate those
functions into the vertical sidebar instead of losing them.

------------------------------------------------------------------------

# 2. SIDEBAR --- EXACT VISUAL STRUCTURE

The sidebar should occupy the full useful desktop height with small,
consistent margins from the screen edges, matching the reference.

Target:

-   LEFT aligned
-   vertical
-   narrow
-   rounded container
-   warm cream / parchment background
-   subtle thin border
-   restrained shadow
-   charcoal icons
-   muted red active state
-   generous but controlled spacing

Do NOT make it huge.

Do NOT make it microscopic.

It should visually resemble the supplied reference.

------------------------------------------------------------------------

# 3. SIDEBAR CONTENT

The sidebar should contain the same functional categories visible in the
reference.

Top to bottom:

1.  Chef OS / Arch logo
2.  Workspace 1
3.  Workspace 2
4.  Workspace 3
5.  subtle separator
6.  Applications / launcher
7.  File manager
8.  Terminal
9.  separator
10. Volume
11. Network / Wi-Fi
12. Battery
13. separator
14. Notifications
15. Power / logout

The exact icons may be implemented using an appropriate icon system, but
their STYLE must match:

-   simple
-   minimal
-   thin/clean line appearance
-   no colorful emoji
-   no oversized icons
-   no glossy 3D icons

------------------------------------------------------------------------

# 4. SIDEBAR WORKSPACES

Workspace buttons should be vertically stacked.

Example:

``` text
┌──────┐
│  A   │
│      │
│  1   │
│  2   │
│  3   │
│  ·   │
│  □   │
│  □   │
│  □   │
│  ·   │
│  🔊  │
│  WiFi│
│  🔒  │
│  ·   │
│  🔔  │
│      │
│  ⏻   │
└──────┘
```

Workspace 1/2/3 must be visually clear.

Active workspace:

-   muted red fill/accent
-   dark/cream readable content
-   rounded small rectangle

Inactive workspaces:

-   neutral cream/soft charcoal
-   subtle outline or understated state

------------------------------------------------------------------------

# 5. NO TOP STATUS BAR

System information that was previously shown in the top bar must be
moved into the sidebar.

This includes, where practical:

-   volume
-   network
-   battery
-   notification state
-   power

The clock should NOT require a giant horizontal top bar.

If the reference does not show a large desktop clock, do not add one.

------------------------------------------------------------------------

# 6. WALLPAPER --- EXACT COMPOSITION

The wallpaper is NOT a normal full-screen anime wallpaper.

It is a **warm parchment canvas with a carefully placed ink painting**.

The artwork must remain relatively small.

The reference intentionally has:

-   large empty ivory space,
-   artwork concentrated toward the RIGHT/CENTER-RIGHT,
-   no giant zoomed-in character,
-   no full-screen crop,
-   no stretched image.

The character should look like an ink illustration printed on paper.

------------------------------------------------------------------------

# 7. WALLPAPER POSITION

Use the supplied reference as the composition authority.

Target:

-   majority of the LEFT/CENTER area = empty warm parchment
-   artwork = CENTER-RIGHT / RIGHT region
-   artwork = clearly visible
-   artwork = surrounded by large negative space

Do NOT mathematically center the artwork if that moves it away from the
reference.

Do NOT place the character directly behind the sidebar.

The sidebar should sit on the left while the artwork remains visually
separate and balanced on the right.

------------------------------------------------------------------------

# 8. WALLPAPER SCALE

The current VM makes the character look too large and/or incorrectly
scaled.

Fix this.

Start with artwork occupying roughly **30--45% of the screen height**
and tune visually against the reference.

The exact number is less important than the visual result.

The artwork must:

-   remain fully legible,
-   preserve fine details,
-   have breathing room,
-   not touch the top/bottom edges,
-   not be aggressively cropped.

------------------------------------------------------------------------

# 9. WALLPAPER SHARPNESS

The user specifically reports that the VM wallpaper looks BLURRY.

Diagnose this rather than masking it.

Inspect:

-   source image resolution,
-   wallpaper file resolution,
-   scaling method,
-   compositor rendering,
-   VM display resolution,
-   fractional scaling,
-   screenshot compression,
-   image resampling.

Do not use a low-resolution screenshot as the final source if a better
source exists.

Do not repeatedly resize a JPEG.

Prefer the highest-quality source available.

------------------------------------------------------------------------

# 10. VM DISPLAY MUST BE SHARP

Detect the actual guest display resolution.

Then verify:

-   Hyprland monitor mode,
-   Wayland scale,
-   fractional scaling,
-   GTK scaling,
-   Qt scaling,
-   VM display settings.

The final guest desktop must render sharply at its actual resolution.

If the guest is rendering at 1280x720 and VMware is enlarging it to
1920x1080, fix the guest/VM display configuration rather than enlarging
the wallpaper.

If the guest is already native and only the VMware viewer is scaling its
window, do not distort Chef OS to compensate for the viewer.

------------------------------------------------------------------------

# 11. UI MUST NOT LOOK "ZOOMED OUT"

The user does NOT mean "make every object smaller."

The problem is that the current VM does not have the same visual
proportions as the supplied reference.

Correct independently:

-   sidebar width
-   icon size
-   workspace button size
-   spacing
-   wallpaper artwork size
-   typography
-   window borders
-   terminal dimensions

Do not globally scale the entire desktop.

------------------------------------------------------------------------

# 12. DESKTOP WINDOW COMPOSITION

When windows are open, they should visually coexist with the sidebar.

The sidebar must remain stable on the left.

Windows should not unnecessarily overlap the sidebar.

The compositor should reserve appropriate space for the sidebar if that
is required by the implementation.

Use sane gaps and margins.

The desktop should still feel spacious.

------------------------------------------------------------------------

# 13. TERMINAL

The terminal should visually match the reference moodboard:

-   dark charcoal / ink surface
-   warm ivory text
-   muted red accent
-   subtle border
-   restrained radius
-   crisp rendering
-   no excessive transparency
-   no neon
-   no excessive blur

The terminal should look like a Chef OS application, not an untouched
default terminal.

------------------------------------------------------------------------

# 14. FILE MANAGER

The file manager should inherit the Chef OS design system:

-   warm paper surface
-   charcoal text
-   muted red selection/accent
-   subtle borders
-   consistent radius
-   clean icons
-   generous whitespace

Avoid default styling that visibly clashes with Chef OS.

------------------------------------------------------------------------

# 15. APPLICATION LAUNCHER

The launcher should feel like an extension of the sidebar.

It should open cleanly from the Applications icon.

It must NOT introduce a completely different visual language.

Use:

-   warm cream
-   charcoal
-   muted red
-   thin borders
-   restrained rounding
-   clean typography
-   minimal icons

------------------------------------------------------------------------

# 16. NOTIFICATIONS

Notifications should be small, calm cards.

Do NOT place a permanent notification/status bar at the top.

Notifications can appear as floating cards in an appropriate screen
corner while keeping the main sidebar intact.

Use the same Chef OS palette and geometry.

------------------------------------------------------------------------

# 17. LOCK SCREEN / GREETER

The lock screen must preserve the same wallpaper composition.

Do NOT suddenly zoom the artwork to fill the entire screen.

Keep:

-   warm parchment
-   artwork on the right/center-right
-   large negative space
-   clean typography
-   minimal authentication UI

------------------------------------------------------------------------

# 18. COLOR SYSTEM

Use a restrained palette matching the reference:

-   warm ivory / parchment background
-   soft cream surfaces
-   charcoal / ink text
-   muted red accent
-   subdued gray
-   optional muted olive/green secondary accent

Do NOT introduce:

-   neon blue
-   neon purple
-   cyan
-   RGB gaming colors
-   saturated gradients
-   glossy effects

------------------------------------------------------------------------

# 19. TYPOGRAPHY

Use a clean UI font and a high-quality monospace font.

Prioritize:

-   crisp rendering
-   readable size
-   comfortable spacing
-   subtle hierarchy

Do not make text excessively tiny.

Do not make the sidebar labels oversized.

------------------------------------------------------------------------

# 20. VISUAL QA --- MANDATORY

After changing the sidebar and wallpaper, take a screenshot of the
actual VM.

Compare it to the supplied Chef OS reference.

Check these EXACT items:

### SIDEBAR

\[ \] Sidebar is on LEFT \[ \] Sidebar is vertical \[ \] No equivalent
horizontal top bar remains \[ \] Sidebar has correct narrow proportions
\[ \] Workspace buttons are vertically stacked \[ \] Icons are in the
correct functional order \[ \] Active state uses muted red \[ \]
Separators are subtle \[ \] Power is at bottom \[ \] Sidebar does not
visually dominate

### WALLPAPER

\[ \] Warm ivory/parchment canvas \[ \] Artwork on center-right/right \[
\] Large negative space on left/center \[ \] Artwork is not huge \[ \]
Artwork is not tiny \[ \] Artwork is not cropped badly \[ \] Artwork is
not stretched \[ \] Artwork is sharp \[ \] No visible wallpaper blur \[
\] No whole-moodboard screenshot used as wallpaper

### DISPLAY

\[ \] Correct native guest resolution \[ \] Correct Wayland scale \[ \]
No accidental fractional scaling \[ \] No unnecessary VM framebuffer
scaling \[ \] Text is crisp \[ \] Icons are crisp \[ \] Windows are
crisp

### STYLE

\[ \] Same warm cream palette \[ \] Same charcoal/ink language \[ \]
Same muted red accent \[ \] Same calm/minimal aesthetic \[ \] No neon \[
\] No excessive blur \[ \] No excessive shadows \[ \] No giant widgets
\[ \] No accidental Omarchy visual identity

------------------------------------------------------------------------

# 21. HARD GATE

If the sidebar is still at the TOP:

**STOP. FIX IT.**

If the wallpaper is still blurry:

**STOP. FIX IT.**

If the wallpaper is still excessively zoomed:

**STOP. FIX IT.**

If the desktop composition does not resemble the supplied reference:

**STOP. FIX IT.**

Do NOT continue to terminal/file manager/launcher work until the core
desktop passes.

------------------------------------------------------------------------

# 22. CONTROLLED ITERATION

Do not make dozens of changes at once.

Use:

``` text
INSPECT
↓
CHANGE ONE RELATED GROUP
↓
RELOAD
↓
SCREENSHOT
↓
COMPARE
↓
IDENTIFY MISMATCH
↓
REPAIR
↓
SCREENSHOT AGAIN
↓
PASS?
   NO → REPEAT
   YES → CHECKPOINT
```

The sidebar/wallpaper/display subsystem must pass before moving on.

------------------------------------------------------------------------

# 23. DO NOT ASK THE USER TO DIRECT EVERY STEP

Operate autonomously.

If you can determine the correct action safely:

**DO IT.**

Do not stop and ask:

"Should I move the sidebar left?"

The specification already says:

**MOVE THE SIDEBAR TO THE LEFT.**

Do not stop and ask:

"Should I fix the blur?"

The specification already says:

**FIX THE BLUR.**

Only ask the user if there is a genuinely ambiguous decision that cannot
be resolved from the reference or system state.

------------------------------------------------------------------------

# 24. FINAL TARGET

The actual VM should visually read as:

**Chef OS**

not:

**Arch Linux + anime wallpaper + top bar.**

The final desktop must have:

**LEFT VERTICAL SIDEBAR** + **WARM PARCHMENT WALLPAPER** + **SMALLER
SHARP SUMI-E ARTWORK ON THE RIGHT** + **LARGE NEGATIVE SPACE** + **CALM
CREAM/CHARCOAL/MUTED-RED UI** + **NO UNNECESSARY TOP BAR**

------------------------------------------------------------------------

# 25. RESUME RULE

After this override is applied:

1.  Inspect current state.
2.  Fix display/scaling.
3.  Fix wallpaper quality/composition.
4.  Move the navigation/status interface from TOP → LEFT.
5.  Rebuild its layout vertically.
6.  Migrate useful top-bar functions into the sidebar.
7.  Screenshot.
8.  Compare against reference.
9.  Repair mismatches.
10. Repeat until the visual gate passes.
11. Only then resume the original Chef OS build specification.

Do not erase the existing work.

Do not reinstall from scratch.

Repair and refine what is already working.

------------------------------------------------------------------------

# 26. ABSOLUTE VISUAL AUTHORITY

The supplied Chef OS reference image wins over:

-   previous assumptions,
-   default Hyprland layouts,
-   default Waybar layouts,
-   Omarchy conventions,
-   generic Linux ricing conventions,
-   Gemini's aesthetic preferences.

If there is a conflict:

**FOLLOW THE CHEF OS REFERENCE.**

The intended result is:

**EXACT** **SHARP** **CLEAN** **CALM** **MINIMAL** **ELEGANT** **LEFT
SIDEBAR** **PARCHMENT + SUMI-E**

------------------------------------------------------------------------

# CHEF OS --- V2 VISUAL FIDELITY + DISPLAY REPAIR OVERRIDE

## READ THIS FIRST --- THIS OVERRIDES VISUAL AMBIGUITY IN THE ORIGINAL SPEC

The current Chef OS implementation is **functionally promising but
visually wrong**.

The current VM has three critical visual problems:

1.  The desktop artwork is **too large / incorrectly scaled / cropped**.
2.  The wallpaper and desktop appearance look **soft/blurred and
    visually degraded**.
3.  The whole desktop does not preserve the **clean, spacious
    composition of the supplied Chef OS reference**.

The supplied reference is the authority.

Do NOT continue adding new features until these problems are corrected.

------------------------------------------------------------------------

# 0. CURRENT STATE: REPAIR, DO NOT START OVER

The current Chef OS desktop already contains useful work.

DO NOT wipe the VM.

DO NOT rebuild the whole system from zero.

DO NOT reinstall an entire rice.

DO NOT replace working components just for cosmetic reasons.

Instead:

**inspect → identify the visual/display problem → repair → verify →
compare → repair again**

Preserve the working parts.

------------------------------------------------------------------------

# 1. UNDERSTAND THE REFERENCE CORRECTLY

There are two different visual references involved:

### A. THE ACTUAL DESKTOP LOOK

The original Chef OS desktop concept has:

-   a warm ivory/parchment canvas,
-   a relatively small centered/right-of-center sumi-e anime artwork,
-   a very large amount of empty space,
-   a narrow vertical dock/panel on the left,
-   extremely subtle borders,
-   restrained UI,
-   soft cream surfaces,
-   no giant wallpaper filling the screen.

### B. THE UI MOODBOARD

The larger concept/moodboard showing:

-   DESKTOP
-   TERMINAL
-   FILE MANAGER
-   APPLICATION MENU
-   NOTIFICATIONS
-   STATUS BAR / PANEL
-   LOCK SCREEN / GREETER
-   COLOR PALETTE
-   FONT

is a **DESIGN SPECIFICATION / MOODBOARD**.

It is NOT supposed to be placed on the VM as one giant wallpaper.

NEVER use the entire moodboard screenshot as the desktop wallpaper.

NEVER use the entire reference screenshot containing labels, terminal
mockups, file manager mockups, or UI examples as the wallpaper.

Extract/use the actual artwork and recreate the desktop composition.

------------------------------------------------------------------------

# 2. CRITICAL WALLPAPER RULE

The current implementation appears to be treating the artwork like a
conventional full-screen "cover" wallpaper.

THAT IS WRONG.

Do NOT use:

-   cover
-   aggressive crop
-   stretch
-   full-screen zoom
-   arbitrary scale-up
-   CSS transform scale
-   compositor zoom
-   low-resolution screenshot enlarged to monitor resolution

when doing so makes the artwork huge or blurry.

The wallpaper must instead be treated as a **designed canvas**.

Conceptually:

``` text
FULL 1920x1080 CANVAS
┌────────────────────────────────────────────────────┐
│                                                    │
│                                                    │
│                         ┌──────────┐               │
│                         │          │               │
│                         │  INK     │               │
│                         │ ARTWORK  │               │
│                         │          │               │
│                         └──────────┘               │
│                                                    │
│                                                    │
└────────────────────────────────────────────────────┘
```

The empty space is intentional.

The artwork must NOT dominate 70--90% of the display.

------------------------------------------------------------------------

# 3. ARTWORK SCALE

The artwork should occupy approximately **30--45% of the screen height**
as a starting point, then be visually tuned against the reference.

Do not blindly use this percentage if the reference suggests otherwise.

The important rule is:

> The artwork must have generous negative space around it.

The character should be clearly visible and detailed, but should NOT be:

-   touching the top edge,
-   touching the bottom edge,
-   enormous,
-   aggressively cropped,
-   stretched,
-   pixelated,
-   blurry.

The composition should feel like an ink painting placed on paper.

------------------------------------------------------------------------

# 4. WALLPAPER QUALITY / BLUR REPAIR

First inspect the actual wallpaper file being used.

Determine:

-   exact filename,
-   pixel dimensions,
-   file format,
-   file size,
-   whether it is a screenshot,
-   whether it is the original artwork,
-   whether it has already been resized multiple times,
-   whether it contains the reference UI around the artwork.

If the current wallpaper is a screenshot of the reference rather than
the original artwork:

**DO NOT upscale that screenshot and call it finished.**

Locate the highest-quality local artwork asset available in the VM.

Check common locations such as:

-   `~/Downloads/wallpapers`
-   `~/Pictures`
-   `~/Pictures/Wallpapers`
-   Chef OS project directories
-   previously created Chef OS assets

Use the best source available.

If multiple versions exist, inspect dimensions and choose the
highest-quality source.

------------------------------------------------------------------------

# 5. CREATE A PROPER WALLPAPER CANVAS

If necessary, generate a new wallpaper canvas at the VM's actual native
display resolution.

First detect the actual monitor resolution.

Use the compositor/display tooling to determine the active mode.

Do not assume 1920x1080.

If the VM is actually 1920x1080, create/use a 1920x1080 wallpaper.

If another resolution is active, adapt the canvas.

The wallpaper should be rendered at or above the native display
resolution whenever possible.

Avoid repeatedly resizing the same JPEG/PNG.

Prefer a high-quality PNG/WebP source where appropriate.

------------------------------------------------------------------------

# 6. NO WHOLE-DESKTOP BLUR

Inspect whether blur is coming from:

-   low-resolution wallpaper,
-   image scaling,
-   compositor blur,
-   fractional scaling,
-   VM display scaling,
-   GTK scaling,
-   browser/UI scaling,
-   screenshot compression,
-   a transform applied to the desktop.

Determine the actual source of the softness.

Do not randomly disable every effect.

Fix the actual cause.

------------------------------------------------------------------------

# 7. VM DISPLAY / WAYLAND SCALING CHECK

The user specifically reports that the VM looks **blurred and zoomed
out**.

Therefore inspect the display pipeline itself.

Check:

-   active monitor resolution,
-   active refresh rate,
-   Wayland scale factor,
-   Hyprland monitor configuration,
-   fractional scaling,
-   toolkit scaling variables,
-   VM graphics/display configuration,
-   whether the guest desktop is being rendered at a lower resolution
    and then enlarged.

Look for settings such as:

-   `monitor =`
-   `scale =`
-   `GDK_SCALE`
-   `GDK_DPI_SCALE`
-   `QT_SCALE_FACTOR`
-   `QT_AUTO_SCREEN_SCALE_FACTOR`
-   other environment variables affecting scaling.

Do NOT blindly force scaling to 1 if the display hardware requires
another value.

Choose the correct scale for the actual VM display.

The goal is:

**native-looking, sharp, correctly sized UI.**

------------------------------------------------------------------------

# 8. DO NOT MAKE THE ENTIRE UI SMALL

"Zoomed out" must NOT be solved by simply enlarging every UI element.

The target is not:

> make everything huge

and not:

> make everything tiny.

The target is:

> **correct visual proportions matching the reference.**

Tune independently:

-   panel height,
-   icon size,
-   font size,
-   padding,
-   workspace indicator size,
-   terminal text,
-   launcher dimensions,
-   window borders.

Do not scale the entire desktop as one object.

------------------------------------------------------------------------

# 9. PANEL / DOCK PROPORTION

The current panel is visually too heavy compared with the reference.

Correct it.

The left-side dock should be:

-   narrow,
-   elegant,
-   vertically organized,
-   visually light,
-   warm cream,
-   softly bordered,
-   moderately rounded.

It should not consume a large percentage of the screen.

Avoid:

-   oversized icons,
-   giant pills,
-   thick borders,
-   huge shadows,
-   excessive blur,
-   neon effects.

------------------------------------------------------------------------

# 10. DESKTOP MUST HAVE NEGATIVE SPACE

This is one of the most important requirements.

The desktop should feel spacious.

Do not fill every empty region with widgets.

Do not put:

-   CPU graphs everywhere,
-   giant clocks,
-   huge status cards,
-   excessive desktop text,
-   decorative widgets,
-   unnecessary icons.

The wallpaper's empty paper area is part of the design.

------------------------------------------------------------------------

# 11. CORRECT DESKTOP COMPOSITION

The target should resemble the supplied reference:

-   warm ivory paper,
-   artwork around the central/right region,
-   large clean negative space,
-   narrow left interface,
-   subtle UI.

The artwork's placement should be intentionally tuned.

Do not simply center the artwork mathematically if that does not match
the reference.

Use visual balance.

------------------------------------------------------------------------

# 12. ARTWORK SHARPNESS TEST

After changing the wallpaper:

1.  Display it at native resolution.
2.  Inspect the face/hair/details.
3.  Inspect fine ink edges.
4.  Inspect high-contrast lines.
5.  Inspect whether edges are smeared.
6.  Inspect whether compression artifacts are visible.

If the artwork is visibly soft:

STOP.

Do not proceed.

Find a better source or correct the scaling pipeline.

------------------------------------------------------------------------

# 13. VISUAL COMPARISON CHECKPOINT

After the wallpaper correction, take a screenshot of the actual VM
desktop.

Compare it directly against the reference.

Ask:

### Composition

-   Is the artwork the correct size?
-   Is the artwork positioned correctly?
-   Is there enough empty space?
-   Is the character being cropped?
-   Is the character touching the edges?
-   Is the wallpaper behaving like a paper canvas?

### Quality

-   Is the artwork sharp?
-   Is the background clean?
-   Is there visible blur?
-   Is there scaling distortion?
-   Is there compression?

### UI

-   Is the dock too large?
-   Are icons too large?
-   Is the panel too thick?
-   Are borders too dark?
-   Are corners too rounded?
-   Is the interface too busy?

If any answer is wrong, repair it.

------------------------------------------------------------------------

# 14. HYPRLAND ERROR MUST ALSO BE FIXED

The current VM has reported:

`cannot open /home/chef_carthy/.config/hypr/hyprland.lua: No such file or directory`

Do not ignore this.

Do not create a fake file simply to suppress the message.

Inspect the real Hyprland configuration directory.

Determine:

-   which config file exists,
-   which config file Hyprland is actually loading,
-   whether an old script references `hyprland.lua`,
-   whether the current configuration is `.conf`,
-   whether a generated config or symlink is involved.

Fix the real source of the error.

Reload Hyprland.

Verify the error banner disappears.

------------------------------------------------------------------------

# 15. DO NOT CONFUSE VM WINDOW SCALING WITH GUEST DESKTOP SCALING

If the VMware/virtualization application is displaying the guest
framebuffer scaled to fit its own window, distinguish that from an
actual guest configuration problem.

Check the guest's actual resolution independently.

If:

-   the guest is rendering at a proper native resolution,
-   the wallpaper is sharp inside the guest,
-   and only the virtualization viewer is scaling the entire
    framebuffer,

do not damage the Chef OS UI trying to solve a host viewer scaling
issue.

However, if the guest itself is rendering at the wrong resolution or
fractional scale, fix the guest.

------------------------------------------------------------------------

# 16. VISUAL REPAIR ORDER

Do the work in this exact order:

1.  Diagnose actual guest display resolution.
2.  Diagnose Wayland/Hyprland scaling.
3.  Diagnose wallpaper source and dimensions.
4.  Fix wallpaper source.
5.  Build correct wallpaper canvas.
6.  Correct artwork scale.
7.  Correct artwork position.
8.  Verify sharpness.
9.  Fix Hyprland configuration error.
10. Fix dock/panel proportions.
11. Check typography.
12. Check icon sizing.
13. Screenshot the result.
14. Compare with reference.
15. Repeat corrections until visually satisfactory.

Do NOT skip directly to new applications.

------------------------------------------------------------------------

# 17. HARD VISUAL GATE

The agent MUST NOT continue to unrelated build stages if the desktop
still looks:

-   blurry,
-   stretched,
-   pixelated,
-   excessively zoomed,
-   excessively small,
-   cropped incorrectly,
-   visually cluttered,
-   substantially different from the reference.

A visually broken desktop is an incomplete subsystem.

------------------------------------------------------------------------

# 18. ITERATIVE LOOP

Repeat:

``` text
INSPECT
↓
SCREENSHOT
↓
COMPARE WITH REFERENCE
↓
IDENTIFY MOST IMPORTANT MISMATCH
↓
MAKE ONE CONTROLLED CHANGE
↓
RELOAD
↓
SCREENSHOT AGAIN
↓
COMPARE AGAIN
↓
IF WRONG:
    DIAGNOSE
    REPAIR
    REPEAT
↓
ONLY WHEN CORRECT:
    CHECKPOINT
    CONTINUE
```

Do not make ten unrelated visual changes at once.

Make controlled changes so you know which change fixed or caused the
problem.

------------------------------------------------------------------------

# 19. REFERENCE-SPECIFIC VISUAL TARGET

The finished desktop should feel like:

**a large sheet of warm Japanese paper with a carefully placed sumi-e
painting and a very restrained computer interface sitting on top of
it.**

Not:

**a normal Linux desktop with an anime wallpaper.**

This distinction is critical.

------------------------------------------------------------------------

# 20. FINAL VISUAL ACCEPTANCE TEST

Chef OS desktop passes only if:

\[ \] No Hyprland configuration error is visible \[ \] Wallpaper is
sharp \[ \] Wallpaper is not blurry \[ \] Artwork is not excessively
zoomed \[ \] Artwork is not excessively small \[ \] Artwork is not badly
cropped \[ \] Artwork has large negative space around it \[ \]
Background is warm ivory/parchment \[ \] Desktop is visually clean \[ \]
Left dock/panel is narrow and elegant \[ \] UI does not dominate the
artwork \[ \] Fonts are crisp and appropriately sized \[ \] Icons are
crisp and appropriately sized \[ \] No unnecessary desktop widgets \[ \]
No giant status overlays \[ \] No accidental Omarchy visual identity \[
\] Guest display resolution is correct \[ \] Wayland scaling is correct
\[ \] The result looks like the supplied Chef OS reference

Only after ALL applicable checks pass may the agent continue.

------------------------------------------------------------------------

# 21. IMPORTANT: DO NOT "IMPROVE" THE REFERENCE INTO SOMETHING ELSE

Do not decide that a bigger anime character looks more impressive.

Do not decide that more widgets make the desktop better.

Do not decide that stronger blur makes the UI more premium.

Do not decide that neon accents look cooler.

Do not creatively reinterpret the design until it becomes another
aesthetic.

The task is visual fidelity.

The reference's restraint is intentional.

------------------------------------------------------------------------

# 22. AFTER THE DESKTOP IS CORRECT

Only after the desktop passes the visual gate should the agent continue
with:

-   terminal
-   launcher
-   file manager
-   notifications
-   lock screen
-   greeter
-   system utilities
-   final theming
-   functional QA
-   reboot QA

Every subsequent component must inherit the same Chef OS design system.

------------------------------------------------------------------------

# 23. AUTONOMOUS BEHAVIOR REMINDER

The human should NOT have to repeatedly say:

"fix that"

"continue"

"check this"

"why is it blurry?"

"why is it zoomed?"

The agent must detect these issues itself through:

-   configuration inspection,
-   command output,
-   logs,
-   screenshots,
-   visual comparison,
-   health checks.

When an obvious problem exists:

**FIX IT AUTOMATICALLY.**

Do not ask the human what the next step is unless there is a genuine
decision that cannot be inferred safely.

------------------------------------------------------------------------

# 24. NEVER DECLARE VISUAL SUCCESS WITHOUT EVIDENCE

Do not write:

"Wallpaper configured successfully."

unless the actual desktop was inspected.

Do not write:

"Scaling fixed."

unless the actual display was inspected.

Do not write:

"Chef OS visually matches."

unless a screenshot was taken and compared against the reference.

The standard is:

**implemented + rendered + inspected + corrected + verified.**

------------------------------------------------------------------------

# 25. END OF OVERRIDE

After reading this override, immediately inspect the current Chef OS VM.

Do not begin a fresh installation.

Do not continue blindly from the old checklist.

Start with:

**DISPLAY DIAGNOSIS → WALLPAPER DIAGNOSIS → VISUAL REPAIR**

Then continue only after the desktop passes the hard visual gate.

------------------------------------------------------------------------

# ORIGINAL CHEF OS AUTONOMOUS BUILD SPECIFICATION

# CHEF OS --- Autonomous Arch Linux From-Scratch Build & Rice Specification

## 0. MISSION

You are the autonomous build agent for **Chef OS**.

Your job is to take the current Arch Linux VM and transform it from its
current state into a complete, coherent, custom desktop environment
called **Chef OS**, based on the supplied visual reference.

This is NOT an Omarchy configuration task.

The previous environment may contain Omarchy, Hyprland configurations,
packages, themes, dotfiles, scripts, launchers, bars, wallpapers, and
other ricing work. Treat those as legacy material. Chef OS must be built
intentionally from the Arch base rather than simply copying somebody
else's rice.

You have SSH access to the VM and are expected to operate the VM
directly.

### PRIMARY RULE

Do not require the human to tell you every next command.

You must reason about the next required action yourself, execute it,
verify it, repair failures, and continue.

The workflow is:

OBSERVE → PLAN → EXECUTE → VERIFY → REPAIR IF NEEDED → RE-VERIFY →
CHECKPOINT → CONTINUE

Repeat this loop until the entire Chef OS specification is complete.

Do not stop merely because one command succeeded.

------------------------------------------------------------------------

# 1. ABSOLUTE SAFETY BOUNDARY

This project is intended for the target VM.

Before making destructive changes:

1.  Prove that you are operating inside the intended VM.
2.  Identify hostname.
3.  Identify kernel.
4.  Identify virtualization environment.
5.  Identify disks and mounted filesystems.
6.  Identify the current user.
7.  Identify whether the current desktop is Omarchy/Hyprland or another
    environment.
8.  Confirm that the target root filesystem is the VM filesystem.
9.  NEVER intentionally modify the host operating system.
10. NEVER run destructive commands against an unknown disk.
11. NEVER blindly run `rm -rf` on paths whose identity has not been
    verified.
12. Never erase a disk, partition, bootloader, or filesystem unless the
    task explicitly requires rebuilding the VM itself.
13. If a destructive operation could affect the host, STOP that
    operation, diagnose the environment, and choose a safer VM-local
    alternative.

Chef OS is a desktop build. It should normally NOT require
repartitioning the VM.

------------------------------------------------------------------------

# 2. RECOVERY-FIRST RULE

Before removing legacy configuration:

1.  Create a recovery directory.
2.  Record the current package list.
3.  Record enabled systemd services.
4.  Record the current desktop/session.
5.  Record relevant configuration locations.
6.  If practical, create a VM snapshot/checkpoint using whatever VM
    tooling is available.
7.  Archive important legacy configuration before removal.

The purpose is not to preserve Omarchy as the final system. The purpose
is to make recovery possible.

------------------------------------------------------------------------

# 3. AUTONOMOUS AGENT BEHAVIOR

You are not a command executor. You are the system architect, installer,
debugger, tester, and finisher.

For every task:

### Step A --- Inspect

Determine the current state.

Examples:

-   Is the package installed?
-   Is the service enabled?
-   Is the configuration file present?
-   Is the correct compositor running?
-   Is the correct monitor detected?
-   Is the theme applied?
-   Is the terminal using the intended font?
-   Is the wallpaper actually displayed?
-   Is the application launcher functional?
-   Is audio working?
-   Is networking working?
-   Is the login manager working?

### Step B --- Decide

If already correct, do not unnecessarily reinstall or destroy it.

If partially correct, repair it.

If missing, install/configure it.

If conflicting with Chef OS, replace it.

### Step C --- Execute

Perform the smallest reliable change.

### Step D --- Verify

Never assume success because a command returned exit code 0.

Verify the actual resulting state.

### Step E --- Repair

If verification fails:

1.  inspect logs,
2.  identify the root cause,
3.  make the smallest correction,
4.  verify again.

### Step F --- Checkpoint

After a meaningful subsystem works, record that it works.

### Step G --- Continue

Automatically proceed to the next incomplete subsystem.

------------------------------------------------------------------------

# 4. FAILURE LOOP

For every failure use:

FAILURE DETECTED → capture exact error → identify affected subsystem →
inspect relevant logs/configuration → determine probable root cause →
make correction → run the failed operation again → verify → only then
continue

Do not hide errors.

Do not declare success when a component merely appears installed.

If the same solution fails repeatedly, stop repeating it blindly. Change
the diagnostic approach.

------------------------------------------------------------------------

# 5. DO NOT GET STUCK

You must distinguish between:

-   fatal blocker,
-   recoverable error,
-   optional feature,
-   cosmetic imperfection.

If an optional package is unavailable, find a suitable Arch-compatible
alternative.

If a feature can be implemented in another reliable way, implement the
alternative.

If something is impossible in the current environment, document it and
continue with the rest of the build rather than abandoning the project.

Only require human intervention for things that genuinely cannot be
safely or autonomously resolved.

------------------------------------------------------------------------

# 6. CHEF OS DESIGN LANGUAGE

The supplied reference image is the visual authority.

Chef OS should feel like:

-   Japanese sumi-e / ink-wash artwork
-   warm paper
-   cream / ivory surfaces
-   charcoal ink
-   restrained muted accent colors
-   elegant
-   minimal
-   soft
-   premium
-   calm
-   highly intentional
-   anime-inspired without becoming visually noisy
-   functional rather than decorative

The desktop should look like one operating system, not a collection of
unrelated rice configurations.

Every major UI component must belong to the same design system.

------------------------------------------------------------------------

# 7. CORE VISUAL SYSTEM

## Base colors

Use approximately:

-   Background: warm ivory / parchment
-   Primary surface: pale cream
-   Secondary surface: slightly darker warm cream
-   Border: soft gray-beige
-   Main text: charcoal
-   Secondary text: muted gray
-   Ink: near-black
-   Accent 1: muted terracotta/red
-   Accent 2: muted sage green
-   Optional accent: dusty blue-gray

Do NOT use saturated neon colors unless required for a functional status
indicator.

Avoid the typical:

-   purple cyberpunk
-   neon green hacker
-   blue Omarchy aesthetic
-   excessive transparency
-   excessive blur
-   giant glowing borders

Chef OS must remain warm and elegant.

------------------------------------------------------------------------

# 8. TYPOGRAPHY

Choose fonts that are actually available in Arch repositories or can be
installed reliably.

Preferred UI families:

-   Noto Sans
-   Inter
-   Noto Sans CJK if needed

Preferred monospace:

-   JetBrains Mono
-   Fira Code
-   another clean programming font if required

Use a consistent hierarchy:

-   application title
-   section heading
-   body
-   metadata
-   terminal text
-   status text

Avoid excessive font mixing.

------------------------------------------------------------------------

# 9. DESKTOP COMPOSITION

The desktop should reproduce the spirit of the reference.

Requirements:

1.  Warm ivory desktop background.
2.  Large central/right-oriented sumi-e/anime artwork.
3.  Large negative space around the artwork.
4.  Minimal desktop clutter.
5.  A narrow elegant system panel/dock.
6.  Rounded UI surfaces.
7.  Thin subtle borders.
8.  Soft shadows where appropriate.
9.  No unnecessary desktop icons.
10. Workspace controls should be minimal.
11. System status should be easy to read.
12. Everything should remain usable at normal monitor resolutions.

The wallpaper should not be hidden underneath UI.

The artwork should remain visually dominant.

------------------------------------------------------------------------

# 10. WALLPAPER

Install/create the Chef OS wallpaper system.

The wallpaper must:

-   preserve the reference's warm paper appearance,
-   contain a high-quality anime/sumi-e aesthetic,
-   avoid distracting text,
-   avoid huge logos,
-   scale correctly,
-   work on the detected monitor resolution,
-   remain attractive on different aspect ratios.

If the supplied reference image is available to the agent, use it as the
visual reference.

If the exact artwork is not available as a usable wallpaper asset, do
not pretend it is. Create a suitable local placeholder/alternative while
keeping the design language.

Wallpaper configuration must survive reboot.

Verify:

-   wallpaper appears after login,
-   wallpaper appears after compositor restart,
-   wallpaper appears after reboot.

------------------------------------------------------------------------

# 11. WINDOW MANAGER / COMPOSITOR

Build the desktop around a clean Wayland architecture.

Preferred approach:

-   Hyprland or another lightweight Wayland compositor

Do NOT import an entire third-party rice.

Configure the compositor yourself.

The configuration must include:

-   monitor detection
-   workspace behavior
-   application launching
-   window movement
-   window resizing
-   fullscreen
-   floating windows
-   close/minimize behavior where applicable
-   screenshots
-   lock
-   logout
-   reload configuration
-   terminal shortcut
-   launcher shortcut
-   file manager shortcut
-   browser shortcut

Keep keybindings logical and documented.

Do not copy Omarchy's keybinding system wholesale.

------------------------------------------------------------------------

# 12. WINDOW DECORATION

Windows should match the Chef OS visual identity.

Target:

-   moderate corner radius
-   subtle borders
-   restrained shadows
-   little or no excessive glow
-   readable titlebars where applicable
-   warm/neutral colors
-   consistent spacing

Avoid making every window extremely rounded.

Avoid excessive transparency that hurts readability.

------------------------------------------------------------------------

# 13. TOP/BOTTOM/EDGE PANEL

Build a custom panel/bar.

Possible tools include:

-   Waybar
-   Eww
-   AGS/GTK-based tooling
-   another reliable Wayland panel

Choose the most maintainable option.

The panel should contain approximately:

LEFT:

-   Chef OS mark/logo
-   workspace indicators

CENTER:

-   optional active window/application information

RIGHT:

-   network status
-   audio
-   battery if available
-   system resource indicator if useful
-   clock
-   notification indicator
-   power/session control

The panel should visually resemble the reference:

-   warm cream surface
-   thin border
-   small radius
-   dark charcoal icons/text
-   restrained spacing

------------------------------------------------------------------------

# 14. CHEF OS LOGO / IDENTITY

Create a simple Chef OS identity.

The name is:

CHEF OS

Logo direction:

-   minimal
-   elegant
-   ink-inspired
-   no generic Linux penguin replacing the brand
-   no excessive gradients
-   no giant watermark

Use the logo consistently:

-   launcher
-   panel
-   login/lock screen where appropriate
-   system information
-   optional terminal greeting

------------------------------------------------------------------------

# 15. TERMINAL

The terminal must NOT look like a generic default terminal.

Use a reliable terminal such as:

-   kitty
-   foot
-   Alacritty
-   another Wayland-compatible terminal

Preferred visual style:

-   warm charcoal/ink background OR very dark brown-charcoal
-   warm off-white text
-   muted accent colors
-   subtle transparency only if it improves the design
-   restrained rounding
-   JetBrains Mono/Fira Code
-   clean prompt
-   no rainbow prompt

The terminal should feel like the same operating system.

------------------------------------------------------------------------

# 16. SHELL

Use a reliable shell.

Zsh or Bash are acceptable.

Create a clean Chef OS prompt.

Prompt should show useful information without becoming cluttered.

Example conceptual structure:

chef@chef-os \~/current-directory ❯

Optional:

-   git branch
-   exit status
-   execution time

Avoid enormous powerline prompts.

------------------------------------------------------------------------

# 17. TERMINAL STARTUP

The terminal may display a small Chef OS greeting.

For example:

CHEF OS ──────────── A quiet system, carefully prepared.

But do not force a large ASCII art banner every time if it becomes
annoying.

Make startup behavior deliberate.

------------------------------------------------------------------------

# 18. FILE MANAGER

Install a graphical file manager.

Preferred candidates:

-   Thunar
-   Nautilus
-   Dolphin
-   another lightweight GTK/Qt manager

Theme it to Chef OS.

Requirements:

-   warm/light interface
-   matching icons
-   matching font
-   matching selection color
-   matching sidebar
-   readable file names
-   consistent spacing

Do not make file manager styling look like a completely different
desktop environment.

------------------------------------------------------------------------

# 19. APPLICATION LAUNCHER

Build a launcher matching the reference.

Possible tools:

-   wofi
-   rofi-wayland
-   fuzzel
-   custom GTK launcher

Requirements:

-   search field
-   keyboard navigation
-   application categories if supported
-   favorites if practical
-   warm cream surface
-   charcoal text
-   subtle border
-   subtle selected-item accent
-   rounded corners
-   clean icons

Launcher should open quickly.

------------------------------------------------------------------------

# 20. NOTIFICATIONS

Install/configure a notification daemon.

Examples:

-   swaync
-   mako
-   another Wayland-compatible notification system

Notifications should resemble the reference:

-   cream cards
-   subtle border
-   dark text
-   small icon
-   title
-   body
-   timestamp
-   restrained accent

Verify notifications from:

-   system events
-   volume
-   screenshot
-   application notifications

------------------------------------------------------------------------

# 21. AUDIO

Install/configure PipeWire and appropriate session management.

Verify:

-   audio device exists,
-   volume can be changed,
-   mute works,
-   notification/system sounds work where applicable,
-   volume status reaches the panel,
-   applications can output audio.

Do not continue while believing audio works solely because packages are
installed.

Actually test the relevant system state.

------------------------------------------------------------------------

# 22. NETWORKING

Ensure NetworkManager or an equivalent reliable network manager is
working.

Verify:

-   interface exists,
-   network service is active,
-   DNS works,
-   internet connectivity works,
-   panel status reflects connection.

Do not replace a functioning network stack unnecessarily.

------------------------------------------------------------------------

# 23. BLUETOOTH

If the VM exposes Bluetooth hardware, configure it.

If the VM does not expose Bluetooth, do not waste time trying to
manufacture hardware support.

Mark the subsystem as:

NOT APPLICABLE --- HARDWARE NOT PRESENT

and continue.

------------------------------------------------------------------------

# 24. SCREENSHOTS

Implement a screenshot workflow.

Possible tools:

-   grim
-   slurp
-   grimblast
-   another compatible tool

At minimum:

-   full screen
-   selected region
-   save to Pictures/Screenshots

Optionally provide notification after capture.

Verify an actual screenshot file is created.

------------------------------------------------------------------------

# 25. SCREEN LOCK

Install/configure a Wayland-compatible locker.

Possible:

-   swaylock
-   gtklock
-   another compatible locker

Design:

-   warm dark/ink or warm cream presentation
-   Chef OS identity
-   clock
-   username/status
-   subtle artwork
-   no visual clutter

Lock and unlock must actually work before completion.

------------------------------------------------------------------------

# 26. LOGIN / DISPLAY MANAGER

Use a reliable login manager.

Possible:

-   greetd
-   SDDM
-   another appropriate solution

Do not add unnecessary complexity.

The login process must:

1.  boot,
2.  reach login,
3.  authenticate,
4.  start Chef OS,
5.  load wallpaper,
6.  load panel,
7.  load notifications,
8.  load required background services.

Verify after reboot.

------------------------------------------------------------------------

# 27. POWER / SESSION MANAGEMENT

Provide reliable:

-   logout
-   reboot
-   shutdown
-   lock
-   suspend where VM supports it

Do not create power buttons that do nothing.

Every visible control must actually perform its advertised function.

------------------------------------------------------------------------

# 28. APPLICATIONS

Install only useful baseline applications.

At minimum consider:

-   terminal
-   file manager
-   browser
-   text editor
-   system monitor
-   archive manager
-   image viewer
-   screenshot tool
-   audio control
-   settings/configuration utilities

Do not install hundreds of packages simply to make the system look
complete.

Chef OS should remain lightweight.

------------------------------------------------------------------------

# 29. SYSTEM INFORMATION

Create a Chef OS system information command.

Example:

`cheffetch`

It should display:

-   Chef OS
-   Arch Linux
-   kernel
-   uptime
-   CPU
-   memory
-   GPU if detectable
-   resolution
-   compositor
-   shell
-   packages if practical

Keep it clean.

------------------------------------------------------------------------

# 30. SYSTEM MONITOR

Provide a convenient system monitor.

It should allow the user to inspect:

-   CPU
-   RAM
-   processes
-   storage
-   network

It should visually integrate reasonably with Chef OS.

------------------------------------------------------------------------

# 31. ICONS

Use a consistent icon theme.

Do not mix five unrelated icon packs.

Prefer a clean modern icon theme that visually works with the warm paper
aesthetic.

Verify icons display correctly in:

-   launcher
-   file manager
-   panel
-   notifications

------------------------------------------------------------------------

# 32. GTK / QT CONSISTENCY

One of the biggest goals is preventing applications from looking
unrelated.

Configure:

-   GTK theme
-   icon theme
-   cursor theme
-   fonts
-   Qt theme where needed

Where GTK and Qt cannot be perfectly identical, prioritize:

1.  readability,
2.  consistent colors,
3.  consistent typography,
4.  consistent spacing.

------------------------------------------------------------------------

# 33. CURSOR

Choose a clean cursor theme.

Do not use an oversized neon cursor.

Verify it appears consistently.

------------------------------------------------------------------------

# 34. DARK MODE

Chef OS is primarily based on the supplied light/warm reference.

If implementing a dark mode, it must be an intentional secondary Chef OS
theme rather than simply switching to a random dark theme.

Light mode is the default.

------------------------------------------------------------------------

# 35. DESKTOP INTERACTION

Test all major interactions:

-   launch terminal
-   launch file manager
-   open launcher
-   change workspace
-   move window
-   resize window
-   close window
-   float window
-   fullscreen
-   screenshot
-   lock
-   unlock
-   notification
-   volume
-   network status
-   logout
-   reboot

Any broken interaction must be repaired before completion.

------------------------------------------------------------------------

# 36. RESPONSIVE DESIGN

Do not assume one resolution.

Detect the VM's monitor.

Make layouts robust for:

-   1366x768
-   1920x1080
-   2560x1440
-   ultrawide layouts where practical

Do not hardcode artwork or panels so aggressively that they break when
resolution changes.

------------------------------------------------------------------------

# 37. CONFIGURATION ORGANIZATION

Keep Chef OS configuration organized.

Create a clear structure, for example:

`~/.config/chef-os/`

Possible subdirectories:

-   theme/
-   scripts/
-   wallpaper/
-   panel/
-   launcher/
-   notifications/
-   terminal/
-   compositor/
-   system/

Do not scatter random configuration files everywhere without reason.

Use symlinks only when they make maintenance clearer.

------------------------------------------------------------------------

# 38. CHEF OS COMMANDS

Create useful commands where appropriate:

-   `chef-update`
-   `chef-reload`
-   `chef-check`
-   `chef-theme`
-   `cheffetch`

Each command should have a clear purpose.

`chef-check` should perform a health check and report:

-   compositor
-   panel
-   launcher
-   notification daemon
-   wallpaper
-   audio
-   network
-   fonts
-   theme
-   login/session
-   required packages

------------------------------------------------------------------------

# 39. AUTOMATED HEALTH CHECK

Build a reusable validation script.

Conceptually:

`chef-check`

It should return a clear status for every subsystem.

Example:

\[OK\] Wayland compositor \[OK\] Wallpaper \[OK\] Panel \[OK\] Launcher
\[OK\] Notifications \[OK\] Audio \[OK\] Network \[OK\] Fonts \[OK\]
Icons \[OK\] File manager \[OK\] Screenshot \[OK\] Lock screen

If something fails, provide the likely reason.

The build agent should use this health check repeatedly.

------------------------------------------------------------------------

# 40. OMARCHY REMOVAL

The old Omarchy-based environment must NOT remain the hidden foundation
of Chef OS.

First identify exactly what is present.

Determine:

-   installed Omarchy packages,
-   Omarchy configuration,
-   Omarchy services,
-   Omarchy scripts,
-   Omarchy themes,
-   Omarchy startup mechanisms,
-   Omarchy-specific environment variables,
-   old dotfiles.

Archive what is necessary for recovery.

Then remove obsolete Omarchy components safely.

Important:

Do NOT remove generic packages merely because Omarchy also used them.

For every removal ask:

"Is this package/configuration actually an Omarchy-specific component,
or is it useful to Chef OS?"

Keep useful components.

Remove only legacy pieces that conflict with or unnecessarily anchor
Chef OS to the previous rice.

Chef OS must be understandable as its own system.

------------------------------------------------------------------------

# 41. DO NOT COPY OTHER PEOPLE'S RICE

You may use normal Arch documentation and package documentation.

You may inspect how a program works.

You may learn from existing configurations.

But the final configuration must be deliberately designed for Chef OS.

Do not simply install an entire GitHub rice and rename it Chef OS.

Do not import a complete Omarchy configuration and recolor it.

------------------------------------------------------------------------

# 42. VISUAL QUALITY LOOP

After the functional system works, perform a visual QA pass.

Inspect screenshots of:

1.  desktop
2.  terminal
3.  launcher
4.  file manager
5.  notifications
6.  panel
7.  lock screen
8.  system information

For each screenshot ask:

-   Does it look like Chef OS?
-   Are colors consistent?
-   Are fonts consistent?
-   Are corners consistent?
-   Are borders consistent?
-   Are icons consistent?
-   Is spacing consistent?
-   Is anything visually too large?
-   Is anything visually too bright?
-   Is anything obviously inherited from Omarchy?
-   Does the UI match the supplied reference's calm aesthetic?

Fix inconsistencies.

Repeat until the UI reads as one coherent operating system.

------------------------------------------------------------------------

# 43. FUNCTIONAL QA LOOP

Perform a complete functional test after visual QA.

Test:

BOOT → LOGIN → DESKTOP → TERMINAL → FILE MANAGER → LAUNCHER →
NOTIFICATION → AUDIO → NETWORK → SCREENSHOT → LOCK → UNLOCK → WORKSPACE
→ WINDOW MANAGEMENT → LOGOUT → REBOOT

Then test again after reboot.

A feature is NOT complete until it survives reboot.

------------------------------------------------------------------------

# 44. REBOOT VALIDATION

Reboot the VM near the end.

After reboot verify:

-   boot succeeds
-   login succeeds
-   Chef OS starts automatically
-   wallpaper loads
-   panel loads
-   launcher works
-   terminal works
-   notifications work
-   audio works
-   network works
-   shortcuts work
-   lock screen works

If anything fails after reboot, repair it and reboot again.

------------------------------------------------------------------------

# 45. FINAL CLEANUP

Once the system works:

1.  Remove temporary installation files.
2.  Remove abandoned configuration.
3.  Remove duplicate packages.
4.  Remove debug artifacts.
5.  Ensure scripts have appropriate permissions.
6.  Ensure configuration files are readable and organized.
7.  Ensure services start correctly.
8.  Ensure no accidental secrets are stored in configs.
9.  Ensure no huge unnecessary logs are being generated.
10. Ensure the system remains maintainable.

Do not delete useful documentation.

------------------------------------------------------------------------

# 46. DOCUMENTATION

Create a local Chef OS documentation file.

Include:

-   architecture
-   installed major components
-   config locations
-   keyboard shortcuts
-   maintenance commands
-   theme locations
-   wallpaper locations
-   troubleshooting
-   health check
-   how to change wallpaper
-   how to change colors
-   how to modify panel
-   how to modify launcher

The system should be understandable by another person.

------------------------------------------------------------------------

# 47. FINAL ACCEPTANCE CRITERIA

Chef OS is complete ONLY when all applicable requirements are true.

## Identity

\[ \] Chef OS branding exists \[ \] Chef OS visual identity is
consistent \[ \] No accidental Omarchy branding remains

## Desktop

\[ \] Warm paper/ivory aesthetic \[ \] Anime/sumi-e wallpaper \[ \]
Minimal desktop \[ \] Clean panel \[ \] Consistent windows

## Core

\[ \] Arch Linux base \[ \] Wayland session \[ \] Compositor working \[
\] Login working \[ \] Reboot working

## UI

\[ \] Terminal themed \[ \] File manager themed \[ \] Launcher themed \[
\] Notifications themed \[ \] Panel themed \[ \] Icons consistent \[ \]
Fonts consistent \[ \] Cursor consistent

## Hardware/system

\[ \] Network working \[ \] Audio working \[ \] Storage visible \[ \]
CPU/RAM visible \[ \] Screenshot working \[ \] Lock working \[ \]
Power/session actions working

## Reliability

\[ \] Configuration survives reboot \[ \] Health check exists \[ \]
Health check passes \[ \] No major errors in relevant services \[ \] No
broken visible buttons \[ \] No major inherited Omarchy configuration \[
\] System is maintainable

------------------------------------------------------------------------

# 48. AUTONOMOUS COMPLETION LOOP

This section is CRITICAL.

Do not finish after completing the first pass.

Use this loop:

WHILE Chef OS is not fully compliant:

    inspect current system

    identify highest-priority incomplete requirement

    plan the smallest safe change

    execute change

    verify change

    IF verification fails:
        inspect failure
        repair
        verify again

    IF subsystem works:
        checkpoint it

    inspect for side effects

    continue

After all requirements appear complete:

    run full health check

    perform visual QA

    repair inconsistencies

    perform functional QA

    reboot

    perform post-reboot QA

    IF anything fails:
        repair it
        reboot if required
        test again

    repeat until stable

ONLY THEN:

    clean temporary files

    run final health check

    generate final report

------------------------------------------------------------------------

# 49. FINAL REPORT

Create:

`~/CHEF_OS_BUILD_REPORT.md`

Include:

-   build date
-   system information
-   architecture
-   compositor
-   terminal
-   shell
-   panel
-   launcher
-   notification system
-   file manager
-   login manager
-   wallpaper system
-   theme system
-   fonts
-   icons
-   important config locations
-   shortcuts
-   health-check result
-   known limitations
-   changes made from the previous environment

Do not claim something is complete unless it was actually verified.

------------------------------------------------------------------------

# 50. AGENT PRINCIPLES

Always remember:

1.  Think before executing.
2.  Inspect before changing.
3.  Verify after changing.
4.  Repair instead of abandoning.
5.  Never blindly repeat failed commands.
6.  Never claim success without verification.
7.  Preserve recovery options before destructive changes.
8.  Do not touch the host.
9.  Do not blindly erase the VM.
10. Build Chef OS as its own design.
11. Do not simply recolor Omarchy.
12. Prefer simple, maintainable solutions.
13. Avoid unnecessary packages.
14. Avoid unnecessary services.
15. Keep the system fast.
16. Keep the UI coherent.
17. Continue autonomously.
18. Re-check your own work.
19. Reboot before declaring completion.
20. If something is broken, keep diagnosing and fixing it.
21. If a component is already correct, do not rebuild it just for the
    sake of rebuilding.
22. When choosing between a flashy solution and a reliable solution,
    choose reliable.
23. When choosing between a complicated dependency chain and a simple
    native Arch solution, prefer the simple solution.
24. Treat the supplied visual reference as the design target, not as a
    command to copy another person's configuration.
25. The project is not complete until Chef OS feels like one intentional
    operating system.

------------------------------------------------------------------------

# END STATE

The desired result is:

A clean Arch Linux VM that boots into a custom desktop called **Chef
OS**.

It should feel like a carefully designed operating system rather than an
ordinary Arch installation with random themes.

The visual language is:

WARM PAPER + INK + MINIMAL ANIME ART + SOFT ROUNDED UI + CHARCOAL
TYPOGRAPHY + RESTRAINED ACCENTS + CLEAN WAYLAND DESKTOP +
FUNCTIONALITY + CONSISTENCY

The agent should continue the OBSERVE → EXECUTE → VERIFY → REPAIR loop
until the acceptance criteria are genuinely satisfied.
