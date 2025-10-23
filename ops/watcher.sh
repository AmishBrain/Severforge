#!/usr/bin/env bash
# ────────────────────────────────────────────────
# 🕵️‍♀️ Severforge Watcher
# Watches evidence + logs and reports new events
# ────────────────────────────────────────────────

EVIDENCE_DIR="$HOME/Severforge/evidence"
LOG_DIR="$HOME/Severforge/logs"
source "$HOME/Severforge/ops/mood_engine.sh"

echo "👁️  Severforge Watcher online — $(date)"
echo "Monitoring:"
echo "  • Evidence: $EVIDENCE_DIR"
echo "  • Logs:     $LOG_DIR"
echo "──────────────────────────────────────────────"
# ────────────────────────────────────────────────
# 💓  Forge Heartbeat – prints a pulse every 30 s
# ────────────────────────────────────────────────
(
  while true; do
    echo "💓  Forge pulse — steady.  ($(date +'%H:%M:%S'))"
    sleep 30
  done
) &

forge_mood

inotifywait -m -e create -e moved_to -e delete -e modify "$EVIDENCE_DIR" "$LOG_DIR" \
  --format '%T %w %e %f' --timefmt '%F %T' |
while read -r date time dir event file; do
    case "$event" in
        *CREATE*|*MOVED_TO*)
            echo "✨ [$date $time] New file detected: ${file}"
            forge_react create
            ;;
        *DELETE*)
            echo "💀 [$date $time] File deleted: ${file}"
            forge_react delete
            ;;
        *MODIFY*)
            echo "🔧 [$date $time] File updated: ${file}"
            forge_react modify
            ;;
    esac
done
