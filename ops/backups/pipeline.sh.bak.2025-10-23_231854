#!/usr/bin/env bash
# ────────────────────────────────────────────────
# SEVERFORGE PIPELINE — Amish × Pisces Edition
# Modular daily-run orchestrator
# ────────────────────────────────────────────────

set -euo pipefail
LOG_DIR="$HOME/Severforge/logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/pipeline_$(date +%F_%H-%M-%S).log"

echo "🧩 [pipeline] Starting Severforge full-cycle run..." | tee -a "$LOG"

EVIDENCE_ROOT="$HOME/Severforge/evidence"
SCRIPTS="$HOME/Severforge/scripts"

run_step() {
  local desc="$1"
  local cmd="$2"
  echo "⚙️  [$desc]" | tee -a "$LOG"
  eval "$cmd" 2>&1 | tee -a "$LOG"
  echo "───" | tee -a "$LOG"
}

run_step "SANITIZE" "$SCRIPTS/sanitize.sh"
run_step "HASH & VERIFY" "$SCRIPTS/evidence_hash.py $EVIDENCE_ROOT"
run_step "STATUS REPORT" "$SCRIPTS/sf_status"

echo "✅ [pipeline] Completed at $(date)" | tee -a "$LOG"

# Easter egg: Forge blessing
if [ "${SEVERFORGE_SHOW_EASTER_EGG:-0}" = "1" ]; then
  echo "🕯️  Blessings of the Forge: logic, soul, and flame united." | tee -a "$LOG"
fi
