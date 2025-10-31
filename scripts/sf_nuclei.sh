#!/usr/bin/env bash
# Severforge wrapper — nuclei runner
# Usage: sf nuclei <nuclei-args...>  (example: sf nuclei -t cves/ -l targets.txt)

LOGDIR="$HOME/Severforge/logs"
mkdir -p "$LOGDIR"
TS="$(date +%F_%H-%M-%S)"
OUT="$LOGDIR/nuclei_${TS}.log"

if [ $# -eq 0 ]; then
  echo "Usage: sf nuclei <nuclei-args>"
  echo "Example: sf nuclei -t cves/ -l targets.txt"
  exit 1
fi

echo "🩸 Severforge Nuclei — starting at $(date)"
echo "📝 Logging to: $OUT"

# run nuclei with passed args
nuclei "$@" 2>&1 | tee "$OUT"

echo ""
echo "🔎 Results saved: $OUT"
# show top results
grep -E "Template|Matched|Severity|INFO|WARN|ERROR|^http" "$OUT" | sed -n '1,120p' || true
echo ""
