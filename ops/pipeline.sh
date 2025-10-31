#!/usr/bin/env bash
# ============================================================
#  SEVERFORGE PIPELINE v2.0 — Amish × Pisces Edition
#  Modular security automation workflow (Local-Only Mode)
# ============================================================

set -euo pipefail
BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGDIR="$BASE/logs"
OUTDIR="$BASE/evidence"
TS=$(date '+%Y-%m-%d_%H-%M-%S')
PIPE_LOG="$LOGDIR/pipeline_${TS}.log"

mkdir -p "$LOGDIR" "$OUTDIR"

echo "💬 The forge stirs — new data fuels its heart."
echo "Severforge pipeline starting: $(date)" | tee -a "$PIPE_LOG"

PHASES=("sanitize" "hash" "verify" "log" "push")
echo "Phases: ${PHASES[*]}"
echo "Output evidence dir: $OUTDIR"
echo ""

# === Helper function ===
run_and_log() {
  echo "──── $* ────" | tee -a "$PIPE_LOG"
  if "$@" | tee -a "$PIPE_LOG"; then
    echo "✅ Success: $*" | tee -a "$PIPE_LOG"
  else
    echo "❌ Command failed: $*" | tee -a "$PIPE_LOG"
  fi
  echo ""
}

# === Capture scope ===
TARGET="${1:-full}"
TGT_DIR="$HOME/Severforge/targets/$TARGET"
mkdir -p "$TGT_DIR"
IN_SCOPE_FILE="$TGT_DIR/in-scope.txt"
OUT_SCOPE_FILE="$TGT_DIR/out-of-scope.txt"

echo "🩸 Define testing boundaries for ${TARGET}"
echo "Enter IN-SCOPE entries (one per line, blank line to end):"
: > "$IN_SCOPE_FILE"
while IFS= read -r line; do
  [ -z "$line" ] && break
  echo "$line" >> "$IN_SCOPE_FILE"
done

echo ""
echo "Enter OUT-OF-SCOPE entries (one per line, blank line to end):"
: > "$OUT_SCOPE_FILE"
while IFS= read -r line; do
  [ -z "$line" ] && break
  echo "$line" >> "$OUT_SCOPE_FILE"
done

echo ""
echo "✅ Scope saved to:"
echo "   $IN_SCOPE_FILE"
echo "   $OUT_SCOPE_FILE"
echo ""

# === Phase execution ===
for phase in "${PHASES[@]}"; do
  case "$phase" in
    sanitize)
      run_and_log bash "$BASE/scripts/sanitize.sh"
      ;;
    hash)
      run_and_log python3 "$BASE/scripts/evidence_hash.py" "$OUTDIR"
      ;;
    verify)
      run_and_log bash "$BASE/scripts/sf_status"
      ;;
    log)
      echo "🧾 Creating pipeline summary log..." | tee -a "$PIPE_LOG"
      echo "Pipeline summary appended to $PIPE_LOG" >> "$PIPE_LOG"
      ;;
    push)
      echo "🧊 Push phase is DISABLED by default for safety." | tee -a "$PIPE_LOG"
      echo "💡 To enable, set ALLOW_PUSH=true and re-run if you *really* intend to sync to GitHub."
      ;;
    *)
      echo "Unknown phase: $phase" | tee -a "$PIPE_LOG"
      ;;
  esac
done

# === Optional final mood pulse ===
if [ -f "$BASE/ops/mood_engine.sh" ] && declare -f forge_react >/dev/null 2>&1; then
  forge_react modify || true
fi

echo ""
echo "✅ Pipeline finished successfully at $(date)" | tee -a "$PIPE_LOG"
echo "🧠 Log saved to: $PIPE_LOG"
echo ""

# === Auto-package artifacts into evidence/<safe_target> ===
# (creates a self-contained evidence bundle with summary + manifest)
safe_target=$(echo "$TARGET" | sed 's|[:/]|_|g')
EVIDENCE_TARGET_DIR="$OUTDIR/$safe_target"
mkdir -p "$EVIDENCE_TARGET_DIR"

# helper: copy the most recent matching file if present
copy_latest_if_exists() {
  local pattern="$1" destname="$2"
  local src
  src=$(ls -1t "$TGT_DIR"/$pattern 2>/dev/null | head -n1 || true)
  if [ -n "$src" ]; then
    cp -v "$src" "$EVIDENCE_TARGET_DIR/${destname}" 2>/dev/null || cp -v "$src" "$EVIDENCE_TARGET_DIR/" 2>/dev/null || true
  fi
}

# Copy latest amass, httpx, nuclei outputs into the evidence bundle
copy_latest_if_exists "amass_*.txt"    "amass_latest.txt"
copy_latest_if_exists "amass_*.json"   "amass_latest.json"
copy_latest_if_exists "httpx_*.txt"    "httpx_latest.txt"
copy_latest_if_exists "nuclei_*.log"   "nuclei_latest.log"

# Write a small summary and samples
SUMMARY="${EVIDENCE_TARGET_DIR}/summary_${TS}.txt"
{
  echo "Severforge Evidence Summary"
  echo "Target: $TARGET"
  echo "Safe target id: $safe_target"
  echo "Run timestamp: $TS"
  echo ""
  echo "Target dir: $TGT_DIR"
  echo "Evidence dir: $EVIDENCE_TARGET_DIR"
  echo ""
  echo "Amass lines: $(wc -l < "$TGT_DIR"/amass_*.txt 2>/dev/null || echo 0)"
  echo "HTTPX lines: $(wc -l < "$TGT_DIR"/httpx_*.txt 2>/dev/null || echo 0)"
  echo "Nuclei size (bytes): $(stat -c%s "$TGT_DIR"/nuclei_*.log 2>/dev/null || echo 0)"
  echo ""
  echo "--- sample httpx (first 10 lines) ---"
  head -n 10 "$TGT_DIR"/httpx_*.txt 2>/dev/null || echo "(no httpx sample)"
  echo ""
  echo "--- sample nuclei (first 20 lines) ---"
  head -n 20 "$TGT_DIR"/nuclei_*.log 2>/dev/null || echo "(no nuclei sample)"
  echo ""
} | tee "$SUMMARY"

# Generate a hash manifest for the evidence bundle (JSON + text)
if command -v python3 >/dev/null 2>&1; then
  python3 "$BASE/scripts/evidence_hash.py" "$EVIDENCE_TARGET_DIR" --output "$EVIDENCE_TARGET_DIR" || python3 "$BASE/scripts/evidence_hash.py" "$EVIDENCE_TARGET_DIR"
fi

echo "✅ Evidence bundle created: $EVIDENCE_TARGET_DIR"
echo "✅ Summary: $SUMMARY"
