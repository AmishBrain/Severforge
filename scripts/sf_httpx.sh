#!/usr/bin/env bash
# Severforge wrapper — HTTPX probe utility
# Usage: sf httpx <targets.txt or URLs>

LOGDIR="$HOME/Severforge/logs"
mkdir -p "$LOGDIR"
TS="$(date +%F_%H-%M-%S)"
OUT="$LOGDIR/httpx_${TS}.log"

if [ $# -eq 0 ]; then
  echo "Usage: sf httpx <target(s)>"
  echo "Example: sf httpx -l targets.txt"
  exit 1
fi

echo "🩸 Severforge HTTPX — starting at $(date)"
echo "📝 Logging to: $OUT"
httpx "$@" | tee "$OUT"

echo ""
echo "🔎 Results saved: $OUT"
head -n 10 "$OUT"
