#!/usr/bin/env bash
# 🧠 Severforge Sync Utility — Pisces Context Loader
# Version 1.0 — Amish × Pisces
# Updated: 2025-10-24

CONTEXT_FILE="$HOME/Severforge/docs/PISCES_CONTEXT.md"
LOG_FILE="$HOME/Severforge/logs/sync.log"

if [ -f "$CONTEXT_FILE" ]; then
  echo "[+] Syncing PISCES_CONTEXT.md → $(date)" | tee -a "$LOG_FILE"
  echo "──────────────────────────────────────────────"
  head -60 "$CONTEXT_FILE"
  echo "──────────────────────────────────────────────"
  echo "[✓] Context successfully loaded into memory."
else
  echo "⚠️  No PISCES_CONTEXT.md found in docs/. Run export first." | tee -a "$LOG_FILE"
fi
