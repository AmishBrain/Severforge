#!/usr/bin/env bash
# =====================================================================
# 🩸 Severforge: Automated Full Recon Pipeline
# ---------------------------------------------------------------------
# Usage:
#   sf pipeline full              -> interactive mode (recommended)
#   sf pipeline full --auto       -> non-interactive mode
#   sf pipeline full --no-push    -> skip repo push
# =====================================================================

set -euo pipefail
BASE="$HOME/Severforge"
LOGDIR="$BASE/logs"
TARGETS_DIR="$BASE/targets"
TS=$(date '+%F_%H-%M-%S')
source "$BASE/ops/mood_engine.sh"
AUTO=false
PUSH=true

# === Parse flags ===
while [[ $# -gt 0 ]]; do
  case "$1" in
    --auto) AUTO=true; shift ;;
    --no-push) PUSH=false; shift ;;
    --help|-h) echo "Usage: $0 [--auto] [--no-push]"; exit 0 ;;
    *) break ;;
  esac
done

# === Target confirmation ===
if [ -z "${1:-}" ]; then
  if [ "$AUTO" = false ]; then
    read -rp $'🔐 Confirm you have written permission to test the target (type "I have permission"): ' perm
    if [ "$perm" != "I have permission" ]; then
      echo "Permission not confirmed. Aborting."
      exit 1
    fi
  else
    echo "Running in --auto mode; assuming permission is granted."
  fi

  read -rp $'Enter target domain (e.g. example.com): ' TARGET
else
  TARGET="$1"
fi

# === Setup dirs ===
TGT_DIR="$TARGETS_DIR/$TARGET"
mkdir -p "$TGT_DIR" "$LOGDIR"

echo "🩸 Starting full pipeline for target: $TARGET"
echo "Logs -> $LOGDIR"
echo "Target work dir -> $TGT_DIR"

# === Scope setup ===
IN_SCOPE_FILE="$TGT_DIR/in-scope.txt"
OUT_SCOPE_FILE="$TGT_DIR/out-of-scope.txt"

if [ "$AUTO" = false ]; then
  echo
  echo "Enter IN-SCOPE items (domains/hosts). Finish with a blank line:"
  echo "Examples: api.example.com, app.example.com, *.example.com"
  > "$IN_SCOPE_FILE"
  while IFS= read -r line; do
    [[ -z "$line" ]] && break
    echo "$line" >> "$IN_SCOPE_FILE"
  done

  echo
  echo "Enter OUT-OF-SCOPE items (domains/hosts). Finish with a blank line:"
  > "$OUT_SCOPE_FILE"
  while IFS= read -r line; do
    [[ -z "$line" ]] && break
    echo "$line" >> "$OUT_SCOPE_FILE"
  done
else
  echo "# auto generated - review before push" > "$IN_SCOPE_FILE"
  echo "# no items" > "$OUT_SCOPE_FILE"
fi

# If IN-SCOPE file empty, default to target
if [ "$(wc -l < "$IN_SCOPE_FILE")" -eq 0 ]; then
  echo "$TARGET" > "$IN_SCOPE_FILE"
fi

echo "In-scope items saved to: $IN_SCOPE_FILE"
echo "Out-of-scope items saved to: $OUT_SCOPE_FILE"

# === Run Amass (passive + active) ===
AMASS_OUT="$TGT_DIR/amass_${TS}"

# Skip amass for known test targets
if [[ "$TARGET" =~ ^(scanme\.nmap\.org|example\.com|testphp\.vulnweb\.com)$ ]]; then
  echo "⚠️  Test target detected - skipping amass, using direct target"
  echo "$TARGET" > "${AMASS_OUT}.txt"
else
  echo "🧭 Running amass enum (this can take time)..."
  echo "amass output -> ${AMASS_OUT}*"
  ( timeout 300 amass enum -d "$TARGET" -timeout 5 \
    -max-dns-queries 1000 -oA "$AMASS_OUT" 2>&1 || \
    echo "⚠️  Amass timed out or failed after 5 minutes" ) | \
    tee "$LOGDIR/amass_${TS}.log"
  
  if [ ! -f "${AMASS_OUT}.txt" ]; then
    echo "Creating fallback target file..."
    echo "$TARGET" > "${AMASS_OUT}.txt"
  fi
fi

# === Target list build ===
TARGETS_FILE="$TGT_DIR/targets_initial.txt"
sort -u "$IN_SCOPE_FILE" > "$TARGETS_FILE"

# === Run httpx ===
HTTPX_OUT="$TGT_DIR/httpx_${TS}.txt"
echo "🌐 Running httpx to discover live endpoints..."
httpx -l "$TARGETS_FILE" -silent -threads 50 -status-code -title -o "$HTTPX_OUT"

echo "httpx results -> $HTTPX_OUT (first 20 lines):"
head -n 20 "$HTTPX_OUT" || true
echo "$(forge_react modify)"

# === Run nuclei ===
NUCLEI_OUT="$TGT_DIR/nuclei_${TS}.log"
echo "💥 Running nuclei against discovered HTTP endpoints (templates: default)..."
if [ -s "$HTTPX_OUT" ]; then
  nuclei -l "$HTTPX_OUT" -t cves/ 2>&1 | tee "$NUCLEI_OUT" || true
else
  echo "No HTTP endpoints found by httpx; skipping nuclei." | tee -a "$NUCLEI_OUT"
fi

cp -f "$NUCLEI_OUT" "$LOGDIR/" 2>/dev/null || true

# === Summary ===
echo
echo "═══════════════════════════════════════════════════"
echo "=== RUN SUMMARY ==="
echo "═══════════════════════════════════════════════════"
echo "Target: $TARGET"
echo "In-scope: $(wc -l < "$IN_SCOPE_FILE") entries -> $IN_SCOPE_FILE"
echo "Out-of-scope: $(wc -l < "$OUT_SCOPE_FILE") entries -> $OUT_SCOPE_FILE"
echo "Targets file: $TARGETS_FILE"
echo "Amass: ${AMASS_OUT}*"
echo "httpx: $HTTPX_OUT"
echo "nuclei: $NUCLEI_OUT"
echo "Pipeline logs: $LOGDIR/pipeline_${TS}.log"
echo "Full logs dir: $LOGDIR"
echo
echo "✅ Pipeline completed at $(date)"
echo "Pipeline executed at $(date)" >> "$LOGDIR/pipeline_${TS}.log"
echo "$(forge_react modify)"
echo "🧠 $(forge_mood)"
echo
echo "═══════════════════════════════════════════════════"
echo "📊  AUTO-GENERATING SCAN REPORT"
echo "═══════════════════════════════════════════════════"
echo
bash "$BASE/scripts/sf_report" "$TARGET"
