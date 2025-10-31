#!/usr/bin/env bash
# Severforge recon wrapper — lightweight nmap runner + log
# Usage: sf recon <nmap-args...>
LOGDIR="$HOME/Severforge/logs"
mkdir -p "$LOGDIR"
TS="$(date +%F_%H-%M-%S)"
OUT="$LOGDIR/recon_${TS}.log"
# Verify mode (checks tool availability instead of running scans)
if [[ "${1:-}" == "--verify" ]]; then
  echo "🔍 Verifying recon toolchain availability..."
  for tool in nmap httpx nuclei; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "✅ $tool found"
    else
      echo "❌ $tool missing!"
    fi
  done
  echo "Verification complete — all tools responding."
  exit 0
fi
if [ $# -eq 0 ]; then
  echo "Usage: sf recon <nmap-args>"
  echo "Example: sf recon -sV -T4 example.com"
  exit 1
fi

echo "🩸 Severforge Recon — nmap starting at $(date)"
echo "📝 Logging to: $OUT"

# Run nmap; if privileged scan flags are used, you may need sudo.
nmap "$@" | tee "$OUT"

# Save a short summary after completion
echo ""
echo "🔎 Summary saved to: $OUT"
grep -E "Nmap scan report|Host is up|open|closed|filtered" "$OUT" | sed -n '1,120p' || true
echo ""
