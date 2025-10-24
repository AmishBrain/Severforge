#!/bin/bash
# ==============================================================
#  SEVERFORGE PIPELINE
#  Modular security automation workflow
#  Version: v1.0.0 — Amish × Pisces Edition
# ==============================================================

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

# === helper ===
run_and_log() {
  echo "──── $* ────" | tee -a "$PIPE_LOG"
  if "$@" | tee -a "$PIPE_LOG"; then
    echo "✅ Success: $*" | tee -a "$PIPE_LOG"
  else
    echo "❌ Command failed: $*" | tee -a "$PIPE_LOG"
  fi
}

# === scope capture ===
TARGET="$1"
TGT_DIR="$HOME/Severforge/targets/$TARGET"
mkdir -p "$TGT_DIR"

IN_SCOPE_FILE="$TGT_DIR/in-scope.txt"
OUT_SCOPE_FILE="$TGT_DIR/out-of-scope.txt"

echo ""
echo "🩸 Define testing boundaries for $TARGET"
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

# === phases ===
for phase in "${PHASES[@]}"; do
  case $phase in

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
      echo "Creating pipeline summary log..." | tee -a "$PIPE_LOG"
      echo "Pipeline summary appended to $PIPE_LOG" >> "$PIPE_LOG"
      ;;

    push)
      if [ "$DO_PUSH" = false ]; then
        echo "Push disabled via --no-push; skipping git push"
      else
        echo -ne "\n🧠  To confirm remote push, type: forge! "
        read -r confirm
        if [[ "$confirm" != "forge!" ]]; then
          echo "🧊 Push locked — incorrect incantation."
          continue
        fi
        echo "🩸  The forge accepts your command..."

        if [ -d "$BASE/.git" ]; then
          if git -C "$BASE" rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
            git -C "$BASE" add .
            git -C "$BASE" commit -m "chore(pipeline): $(date)"
            git -C "$BASE" push origin HEAD && echo "🔥  The forge has spoken."
          else
            echo "No upstream configured; skipping push" | tee -a "$PIPE_LOG"
          fi
        else
          echo "Not a git repo — skipping push" | tee -a "$PIPE_LOG"
        fi
      fi
      ;;
    *)
      echo "Unknown phase: $phase" | tee -a "$PIPE_LOG"
      ;;
  esac
done

# Final mood pulse
if [ -f "$BASE/ops/mood_engine.sh" ]; then
  if declare -f forge_react >/dev/null 2>&1; then
    forge_react modify || true
  fi
fi

echo "Pipeline finished: $(date)" | tee -a "$PIPE_LOG"
echo "Log: $PIPE_LOG"
