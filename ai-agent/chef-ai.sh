#!/usr/bin/env bash
# Chef AI — a system-aware assistant for Chef OS, backed by Gemini CLI.
#
# Requires: `gemini` CLI installed and authenticated (https://github.com/google-gemini/gemini-cli)
#
# Philosophy: this agent gathers real system context, asks Gemini for a plan,
# then SHOWS you the plan and any proposed shell commands and asks for
# confirmation before running anything. It never auto-executes silently —
# that's a bad idea on a machine full of pentesting tools and creds.

set -euo pipefail

CONTEXT_FILE="$(mktemp)"
trap 'rm -f "$CONTEXT_FILE"' EXIT

gather_context() {
  {
    echo "## System"
    uname -a
    echo
    echo "## OS release"
    cat /etc/os-release 2>/dev/null || true
    echo
    echo "## Disk usage"
    df -h --output=target,size,used,avail,pcent 2>/dev/null | head -20
    echo
    echo "## Memory"
    free -h
    echo
    echo "## Installed packages (count + sample)"
    pacman -Q 2>/dev/null | wc -l
    pacman -Q 2>/dev/null | tail -30
    echo
    echo "## Active services"
    systemctl list-units --type=service --state=running --no-pager 2>/dev/null | head -30
    echo
    echo "## Network interfaces"
    ip -brief addr 2>/dev/null
  } > "$CONTEXT_FILE"
}

usage() {
  cat << 'USAGE'
chef-ai <command> [args]

Commands:
  ask "<question>"         Ask Chef AI anything about the current system state
  fix "<problem>"          Describe a problem; Chef AI proposes a fix (asks before applying)
  install-category <name>  Pull in a BlackArch tool category (e.g. wireless, web, forensics)
  status                   Print the raw context Chef AI currently sees
USAGE
}

ask_gemini() {
  local prompt="$1"
  gather_context
  gemini << PROMPT
You are Chef AI, the built-in system assistant for Chef OS (an Arch + Hyprland
pentesting distro). Below is the current system context, followed by the
user's request. If the request requires running shell commands, list them
clearly in a fenced bash block and briefly explain what each does and why —
do not assume they will be run automatically.

=== SYSTEM CONTEXT ===
$(cat "$CONTEXT_FILE")

=== USER REQUEST ===
$prompt
PROMPT
}

confirm_and_run() {
  echo "Chef AI proposed the commands above."
  read -r -p "Run them now? [y/N] " reply
  if [[ "$reply" =~ ^[Yy]$ ]]; then
    echo "(paste-and-run flow — copy the commands you want executed)"
  else
    echo "Skipped. Nothing was changed."
  fi
}

case "${1:-}" in
  ask)
    ask_gemini "${2:?Usage: chef-ai ask \"<question>\"}"
    ;;
  fix)
    ask_gemini "Problem: ${2:?Usage: chef-ai fix \"<problem>\"}. Diagnose and propose a fix."
    confirm_and_run
    ;;
  install-category)
    cat="${2:?Usage: chef-ai install-category <name>}"
    echo "Available BlackArch categories: recon, web, wireless, exploitation, forensics, reversing, cracker"
    echo "Proposed: sudo pacman -Sy blackarch-${cat}"
    read -r -p "Run this now? [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]] && sudo pacman -Sy "blackarch-${cat}"
    ;;
  status)
    gather_context
    cat "$CONTEXT_FILE"
    ;;
  *)
    usage
    ;;
esac
