#!/usr/bin/env bash
# sf_pipeline_full.sh - Severforge: Automated full recon pipeline (safe-by-default)
# Usage:
#   sf pipeline full        -> interactive mode (recommended)
#   sf pipeline full --auto -> non-interactive mode (uses defaults; still --no-push)
#
set -euo pipefail
BASE="$HOME/Severforge"
LOGDIR="$BASE/logs"
TARGETS_DIR="$BASE/targets"
TS=$(date '+%F_%H-%M-%S')
AUTO=false
PUSH=true   # pipeline will be run with --no-push by default below; PUSH controls final optional push prompt

# parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --auto) AUTO=true; shift ;;
    --no-push) PUSH=false; shift ;;
    --help|-h) echo "Usage: $0 [--auto] [--no-push]"; exit 0 ;;
    *) break ;;
  esac
done

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

# setup dirs
TGT_DIR="$TARGETS_DIR/$TARGET"
mkdir -p "$TGT_DIR" "$LOGDIR"

echo "🩸 Starting full pipeline for target: $TARGET"
echo "Logs -> $LOGDIR"
echo "Target work dir -> $TGT_DIR"

# Ask for in-scope and out-of-scope (interactive)
IN_SCOPE_FILE="$TGT_DIR/in-scope.txt"
OUT_SCOPE_FILE="$TGT_DIR/out-of-scope.txt"

if [ "$AUTO" = false ]; then
  echo
  echo "Enter IN-SCOPE items (domains/hosts). Finish with a blank line on its own."
  echo "Examples: api.example.com, app.example.com, *.example.com"
  > "$IN_SCOPE_FILE"
  while IFS= read -r line; do
    [[ -z "$line" ]] && break
    echo "$line" >> "$IN_SCOPE_FILE"
  done
  echo
  echo "Enter OUT-OF-SCOPE items (domains/hosts). Finish with a blank line on its own."
  > "$OUT_SCOPE_FILE"
  while IFS= read -r line; do
    [[ -z "$line" ]] && break
    echo "$line" >> "$OUT_SCOPE_FILE"
  done
else
  # auto mode: empty scope lists (user must review files after run)
  echo "# auto generated - review before push" > "$IN_SCOPE_FILE"
  echo "# no items" > "$OUT_SCOPE_FILE"
fi

# If IN-SCOPE file is empty (no lines), add target as a default
if [ $(wc -l < "$IN_SCOPE_FILE") -eq 0 ]; then
  echo "$TARGET" > "$IN_SCOPE_FILE"
fi

echo "In-scope items saved to: $IN_SCOPE_FILE"
echo "Out-of-scope items saved to: $OUT_SCOPE_FILE"

# Build targets list: start from in-scope, then augment from amass
TARGETS_FILE="$TGT_DIR/targets_initial.txt"
sort -u "$IN_SCOPE_FILE" > "$TARGETS_FILE"

# === RUN Amass (passive+active) ===
AMASS_OUT="$TGT_DIR/amass_${TS}"
echo "🧭 Running amass enum (this can take time)..."
echo "amass output -> ${AMASS_OUT}*"
# do a conservative enum with both passive and active sources; adjust flags if you want different behavior
amass enum -d "$TARGET" -oA "$AMASS_OUT" 2>&1 | tee "$LOGDIR/amass_${TS}.log" || true

# collect amass hosts and add to targets file
if [ -f "${AMASS_OUT}.txt" ]; then
  echo "Adding amass-discovered hosts to targets list..."
  grep -Eo '[A-Za-z0-9._-]+\.[A-Za-z]{2,}' "${AMASS_OUT}.txt" | sort -u >> "$TARGETS_FILE" || true
fi
sort -u -o "$TARGETS_FILE" "$TARGETS_FILE"

echo "Target list prepared: $TARGETS_FILE (first 20 lines):"
head -n 20 "$TARGETS_FILE" || true

# === RUN httpx to probe HTTP(S) endpoints ===
HTTPX_OUT="$TGT_DIR/httpx_${TS}.txt"
echo "🌐 Running httpx to discover live endpoints..."
# using -silent to reduce output; store full json/format if desired
httpx -l "$TARGETS_FILE" -silent -threads 50 -status-code -title -o "$HTTPX_OUT" 2>&1 | tee "$LOGDIR/httpx_${TS}.log" || true

echo "httpx results -> $HTTPX_OUT (first 20 lines):"
head -n 20 "$HTTPX_OUT" || true

# === RUN nuclei on discovered endpoints ===
NUCLEI_OUT="$TGT_DIR/nuclei_${TS}.log"
echo "💥 Running nuclei against discovered HTTP endpoints (templates: default)..."
if [ -s "$HTTPX_OUT" ]; then
  nuclei -l "$HTTPX_OUT" -t cves/ 2>&1 | tee "$NUCLEI_OUT" || true
else
  echo "No HTTP endpoints found by httpx; skipping nuclei." | tee -a "$NUCLEI_OUT"
fi

# Save logs into master logs dir for pipeline bundling
cp -f "$NUCLEI_OUT" "$LOGDIR/" 2>/dev/null || true

# === FINAL: run pipeline (no push) to hash and summarize ===
echo "🏁 Running sf pipeline in audit mode (no push)..."
sf pipeline --no-push

# summarize
echo
echo "=== RUN SUMMARY ==="
echo "Target: $TARGET"
echo "In-scope: $(wc -l < "$IN_SCOPE_FILE") entries -> $IN_SCOPE_FILE"
echo "Out-of-scope: $(wc -l < "$OUT_SCOPE_FILE") entries -> $OUT_SCOPE_FILE"
echo "Targets file: $TARGETS_FILE"
echo "Amass: ${AMASS_OUT}*"
echo "httpx: $HTTPX_OUT"
echo "nuclei: $NUCLEI_OUT"
echo "Pipeline logs: $(ls -1t "$LOGDIR"/pipeline_*.log | head -n1)"
echo "Full logs dir: $LOGDIR"
echo
echo "✅ Done. Nothing was pushed. Review logs and scope files before any push."
echo "If you want to push this pipeline run to your repo, run: sf pipeline (then type 'forge!' when prompted)"
