#!/usr/bin/env bash
forge_react() {
  # brief red→gold→reset glow when the forge reacts
  for c in 196 202 208 214 220; do
    echo -ne "\e[38;5;${c}m🔥 FORGE REACTING 🔥\e[0m\r"
    sleep 0.07
  done
  echo -ne "\e[0m\r"   # reset color
}
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
      forge_react
      ;;
  *DELETE*)
      echo "💀 [$date $time] File deleted: ${file}"
      forge_react
      ;;
  *MODIFY*)
      echo "🔧 [$date $time] File updated: ${file}"
      forge_react
      ;;
esacdone
