#!/usr/bin/env bash
# 🩸 Severforge Verbs Reference — Colorized Terminal Edition
# Version 2.0 — Amish × Pisces
# Updated: 2025-10-28

# Detect color support
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors)" -ge 8 ]; then
  NC="$(printf '\033[0m')"        # reset
  BOLD="$(printf '\033[1m')"
  DIM="$(printf '\033[2m')"
  RED="$(printf '\033[31m')"
  GREEN="$(printf '\033[32m')"
  YELLOW="$(printf '\033[33m')"
  BLUE="$(printf '\033[34m')"
  MAGENTA="$(printf '\033[35m')"
  CYAN="$(printf '\033[36m')"
else
  NC="" BOLD="" DIM="" RED="" GREEN="" YELLOW="" BLUE="" MAGENTA="" CYAN=""
fi

clear
echo ""
printf "%s%s🩸  SEVERFORGE VERBS REFERENCE%s\n" "$BOLD" "$RED" "$NC"
printf "%s────────────────────────────────────────────────────────────────%s\n" "$DIM" "$NC"

printf "%sVersion:%s %-10s   %sAuthors:%s %s\n" "$BOLD" "$NC" "v2.0" "$BOLD" "$NC" "Amish × Pisces"
printf "%sLast Updated:%s %s\n\n" "$BOLD" "$NC" "$(date '+%Y-%m-%d')"
printf "%s────────────────────────────────────────────────────────────────%s\n" "$DIM" "$NC"

### CORE VERBS
printf "%s%s  🧰  Core Verbs%s\n" "$BOLD" "$BLUE" "$NC"
echo ""
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "$BOLD" " " "$CYAN" "Command" "$NC" "$CYAN" "Typical Use" "$NC"
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "────────────" " " "$DIM" "──────────────────────────────" "$NC" "$DIM" "─────────────────────────" "$NC"
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "sf_banner" " " "$CYAN" "Display the Severforge banner." "$NC" "$YELLOW" "sf banner" "$NC"
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "sf_status" " " "$CYAN" "Display integrity, uptime, hash verification." "$NC" "$YELLOW" "After updates" "$NC"
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "sf_sanitize" " " "$CYAN" "Strip temp files and cached logs." "$NC" "$YELLOW" "Between bounties" "$NC"
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "sf_watch" " " "$CYAN" "Run forge watcher for events." "$NC" "$YELLOW" "Background mode" "$NC"
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "sf_logview" " " "$CYAN" "Pretty-print historical logs." "$NC" "$YELLOW" "Review sessions" "$NC"
echo ""
printf "%s%-18s%s %s\n" "$CYAN" "sf_status" "$NC" "→ Shows current forge status & integrity"
printf "%s%-18s%s %s\n" "$CYAN" "sf_clean" "$NC" "→ Clears temporary files, resets workspace"
printf "%s%-18s%s %s\n" "$CYAN" "sf_sanitize" "$NC" "→ Securely cleans workspace for next project"
printf "%s%-18s%s %s\n" "$CYAN" "sf_sync" "$NC" "→ Displays or syncs PISCES_CONTEXT.md"
printf "%s%-18s%s %s\n" "$CYAN" "sf_resign" "$NC" "→ Re-signs forge integrity baseline (SHA-256)"
echo ""

### RECON & AUTOMATION
printf "%s%s  ⚙️  Recon & Automation Verbs%s\n" "$BOLD" "$MAGENTA" "$NC"
echo ""
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "$BOLD" " " "$CYAN" "Command" "$NC" "$CYAN" "Typical Use" "$NC"
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "────────────" " " "$DIM" "──────────────────────────────" "$NC" "$DIM" "─────────────────────────" "$NC"
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "sf_recon" " " "$CYAN" "Launch Recon Suite (nmap, httpx, nuclei)." "$NC" "$YELLOW" "sf recon target.com" "$NC"
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "sf_scan" " " "$CYAN" "Quick vulnerability sweep." "$NC" "$YELLOW" "Small-scope checks" "$NC"
printf "%-14s %s│ %s%-45s%s │ %s%-25s%s\n" "sf_clone" " " "$CYAN" "Duplicate environment into clean clone." "$NC" "$YELLOW" "Multi-collab / training" "$NC"
echo ""

### PIPELINE
printf "%s%s  🧭  sf pipeline_full — Automated Teaching + Recon Flow%s\n" "$BOLD" "$GREEN" "$NC"
printf "%s────────────────────────────────────────────────────────────────%s\n" "$DIM" "$NC"
echo ""
printf "%sUsage:%s     %s\n" "$BOLD" "$NC" "sf pipeline_full [--auto] [TARGET]"
printf "%sPurpose:%s   %s\n" "$BOLD" "$NC" "Full chained recon run with auto-permission prompts."
printf "%sSequence:%s  %s\n" "$BOLD" "$NC" "amass → httpx → nuclei → pipeline manifest"
printf "%sSafety:%s    %s\n" "$BOLD" "$NC" "Safe by default; push only when confirmed."
printf "%sExamples:%s\n" "$BOLD" "$NC"
printf "  %s\n" "sf pipeline_full"
printf "  %s\n" "sf pipeline_full --auto example.com"
echo ""
printf "%s💫 End of reference — forged knowledge.%s\n\n" "$DIM" "$NC"
