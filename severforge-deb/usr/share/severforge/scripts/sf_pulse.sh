#!/usr/bin/env bash
# 💓 Severforge Pulse — Heartbeat Regulation Loop
PULSE_LOG="$HOME/Severforge/logs/pulse.log"
mkdir -p "$(dirname "$PULSE_LOG")"

# single-instance guard: use a lockfile by PID
LOCK="/tmp/sf_pulse.pid"
if [[ -f "$LOCK" ]]; then
  pid=$(cat "$LOCK" 2>/dev/null)
  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    # already running
    exit 0
  else
    rm -f "$LOCK"
  fi
fi

echo $$ > "$LOCK"
trap 'rm -f "$LOCK"; exit' INT TERM EXIT

while true; do
  ts=$(date '+%Y-%m-%d %H:%M:%S')
  mood_line="💓  Forge pulse — steady.  (${ts})"
  echo "$mood_line" | tee -a "$PULSE_LOG"
  sleep 600  # 600s = 10 minutes
done
