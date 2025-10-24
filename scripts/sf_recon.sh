#!/usr/bin/env bash
# Severforge recon wrapper — lightweight nmap runner + log
# Usage: sf recon <nmap-args...>
LOGDIR="$HOME/Severforge/logs"
mkdir -p "$LOGDIR"
TS="$(date +%F_%H-%M-%S)"
OUT="$LOGDIR/recon_${TS}.log"

if [ $# -eq 0 ]; then
  echo "Usage: sf recon <nmap-args>"
  echo "Example: sf recon -sV -T4 example.com"
  exit 1
fi

echo "🩸 Severforge Recon — nmap starting at $(date)"
echo "📝 Logging to: $OUT"

# Run nmap; if privileged scan flags are used, you may need sudo.
nmap "$@" | tee "$OUT"

# Save a short summary
echo ""
echo "🔎 Summary saved to: $OUT"
grep -E "Nmap scan report|Host is up|open|closed|filtered" "$OUT" | sed -n '1,120p'
echo ""
