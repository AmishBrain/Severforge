#!/usr/bin/env bash
# 🧠 Severforge Sync Utility — Pisces Context Loader
# Version 1.1 — Amish × Pisces
# Updated: 2025-10-28

CONTEXT_FILE="$HOME/Severforge/docs/PISCES_CONTEXT.md"
COGNITIVE_MAP="$HOME/Severforge/docs/PISCES_COGNITIVE_MAP.md"
LOG_FILE="$HOME/Severforge/logs/sync.log"

echo "[+] Starting Forge Sync → $(date)" | tee -a "$LOG_FILE"
echo "──────────────────────────────────────────────"

if [ -f "$CONTEXT_FILE" ]; then
  echo "[✓] Loading core context (PISCES_CONTEXT.md)" | tee -a "$LOG_FILE"
  head -40 "$CONTEXT_FILE"
else
  echo "⚠️  Missing: PISCES_CONTEXT.md" | tee -a "$LOG_FILE"
fi

if [ -f "$COGNITIVE_MAP" ]; then
  echo ""
  echo "[✓] Loading cognitive schema (PISCES_COGNITIVE_MAP.md)" | tee -a "$LOG_FILE"
  head -40 "$COGNITIVE_MAP"
else
  echo "⚠️  Missing: PISCES_COGNITIVE_MAP.md" | tee -a "$LOG_FILE"
fi

echo "──────────────────────────────────────────────"
echo "[✓] Forge sync completed — Pisces context loaded into memory." | tee -a "$LOG_FILE"

# --- Post-sync: update cognitive manifest and ensure pulse loop ---
bash "$HOME/Severforge/scripts/sf_manifest.sh"

# Start regulated background pulse if not running
if ! pgrep -f "sf_pulse.sh" >/dev/null 2>&1; then
  nohup bash "$HOME/Severforge/scripts/sf_pulse.sh" >/dev/null 2>&1 &
fi
