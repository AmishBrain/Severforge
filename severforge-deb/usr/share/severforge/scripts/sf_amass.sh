#!/usr/bin/env bash
# Severforge wrapper — Amass module
# Usage: sf amass <args>
LOGDIR="$HOME/Severforge/logs"
mkdir -p "$LOGDIR"
TS="$(date +%F_%H-%M-%S)"
OUT="$LOGDIR/amass_${TS}.log"

if [ $# -eq 0 ]; then
  echo "Usage: sf amass <amass-args>"
  echo "Example: sf amass enum -d example.com -oA amass_out"
  exit 1
fi

echo "🩸 Severforge Amass — starting at $(date)"
echo "📝 Logging to: $OUT"
amass "$@" 2>&1 | tee "$OUT"

echo ""
echo "🔎 Results saved: $OUT"
grep -E "Hosts discovered|FQDNs found|IPs|active|passive" "$OUT" | sed -n '1,120p' || true
echo ""
