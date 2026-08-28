# Chef OS

A security-focused Linux distro: **Omarchy's real desktop** (vendored from
upstream, unmodified) + **the full BlackArch tool catalog** + **Chef AI**, a
Gemini-CLI-backed agent that can read the OS and propose changes.

Everything here is open source and used as such:
- **Omarchy** — `vendor/omarchy/` is a direct copy of upstream Omarchy's
  `config/`, `bin/`, and `install/` (MIT licensed, © David Heinemeier Hansson,
  LICENSE included as required by the license). Not reimplemented, not
  reinterpreted — the actual thing, so you get the actual Omarchy feel.
- **BlackArch** — `packages/blackarch-categories.txt` lists all ~48 official
  BlackArch category groups. Installing all of them pulls in the full
  ~2800-tool catalog via BlackArch's own repo (added by their official
  `strap.sh`), not a reinvented subset.
- **Chef AI** — original code, `ai-agent/chef-ai.sh`, wrapping the `gemini`
  CLI with real system context and a confirm-before-execute loop.

## Status: v0.2 — installable scaffold, not yet a shrink-wrapped ISO
`build/chef-install.sh` is a real, runnable installer: it runs Omarchy's own
install flow, adds the BlackArch repo and installs every category, then
drops in Chef AI. Run it inside a booted Arch Linux install — bare metal or,
for your case, a fresh **Arch Linux VM in VMware** (see `docs/vmware-testing.md`
for VM setup, then boot the Arch ISO, get network up, clone this repo, run
the script from inside that VM).

`build/build-iso.sh` is the alternate path if you want a redistributable
`.iso` file instead of installing live — it's an archiso profile that bakes
in the same three layers so you can hand the ISO to another machine.

Both scripts need to run on real Arch (with network access to Arch,
BlackArch, and GitHub mirrors) — that's not available in this chat
environment, so this repo is the complete, ready-to-run build system, not
a pre-built image.

## Layout
```
chef-os/
├── vendor/omarchy/            # Upstream Omarchy, vendored as-is (MIT, DHH)
│   ├── config/                # Hyprland/Waybar/theme configs
│   ├── bin/                   # Omarchy's ~440 helper CLI scripts
│   ├── install/                # Omarchy's own installer + base package list
│   └── LICENSE
├── packages/
│   └── blackarch-categories.txt   # All official BlackArch groups
├── ai-agent/chef-ai.sh          # Gemini CLI wrapper — reads system, confirms before acting
├── branding/                    # Makes it visibly "Chef OS", not just Omarchy underneath
│   ├── chef-logo.txt            # ASCII logo
│   ├── bin/chef-ascii            # Prints the logo
│   ├── bin/chef-welcome          # First-login banner + status (pkg count, BlackArch groups, Chef AI status)
│   ├── autostart/chef-welcome.desktop
│   ├── chef-boot-splash.service  # Shows "Chef OS" text on the Plymouth boot splash
│   ├── motd.txt                  # Terminal login banner
│   └── chef-waybar-badge.sh      # Adds a "Chef OS" badge to the Waybar bar
├── build/
│   ├── chef-install.sh         # Install live onto a booted Arch system/VM
│   └── build-iso.sh            # Build a redistributable .iso via archiso
└── docs/vmware-testing.md
```

## Where "Chef OS" actually shows up
- **Boot**: a `systemd` oneshot fires `plymouth display-message --text="Chef OS"` early in boot, overlaid on whatever graphical splash Omarchy/Plymouth is already running — reliable text branding without needing a hand-built graphics theme.
- **First login of a session**: `chef-welcome` autostarts, prints the ASCII logo plus a live status line (packages installed, BlackArch groups present, whether Chef AI can reach `gemini`).
- **Every terminal/SSH login**: `/etc/motd` shows a short Chef OS banner.
- **The Waybar bar**: run `branding/chef-waybar-badge.sh` once Hyprland/Waybar has launched at least once, and a " Chef OS" badge is added to the left side of the bar. (It rewrites the config as plain JSON, so any `//` comments in your waybar config get dropped in the process — it backs the original up first.)
- **Anytime**: `chef-ascii` prints the logo, `chef-welcome --force` reprints the status banner on demand.

This is a first branding pass, not a full custom desktop shell — it layers visible Chef OS identity on top of Omarchy rather than replacing Omarchy's UI code. A deeper rebrand (custom SDDM login theme, custom Waybar style sheet, boot logo image instead of text) is a reasonable v0.3 if you want it.

## Design principles
1. **Don't reinvent Omarchy — vendor it.** You said you love the interface;
   the most faithful way to get it is the real upstream files, kept in sync,
   not a guess at recreating it.
2. **BlackArch's full catalog, not a curated slice** — you asked for
   everything, so the install layer targets every official category group.
3. **Chef AI never executes silently.** It reads real system state (packages,
   services, disk, network), proposes a plan, and asks before running
   anything — non-negotiable on a machine full of pentest tools and creds.

## Next steps
- Actually running `chef-install.sh` needs to happen on Arch itself (your
  VMware VM), since this sandbox can't reach Arch/BlackArch mirrors.
- If you want this in your own GitHub repo instead of a zip, say the word
  and I'll connect a GitHub tool and push it.
- Omarchy updates upstream — periodically re-pull `vendor/omarchy/` from
  `github.com/basecamp/omarchy` to stay current.
