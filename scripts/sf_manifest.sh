#!/usr/bin/env bash
# 🧠 Severforge Manifest Updater — auto-stamps cognition map
# Purpose: Replace or insert the “Last Updated” line in PISCES_COGNITIVE_MAP.md

MAP="$HOME/Severforge/docs/PISCES_COGNITIVE_MAP.md"
VER="v2.0"
TS="$(date '+%Y-%m-%d %H:%M:%S %Z')"

# Verify file exists
if [[ ! -f "$MAP" ]]; then
  echo "⚠️  PISCES_COGNITIVE_MAP.md not found at $MAP" >&2
  exit 1
fi

# Clean any existing "Last Updated" lines to prevent stacking
sed -i '/^Last Updated:/d' "$MAP"

# If placeholder exists, replace it; else insert below Version line
if grep -q '<auto-populated by sf_manifest>' "$MAP"; then
  sed -i "s#<auto-populated by sf_manifest>#Last Updated: ${TS} (${VER})#" "$MAP"
else
  awk -v ts="Last Updated: ${TS} (${VER})" '
    { print }
    $0 ~ /^Version:/ && !done { print ts; done=1 }
  ' "$MAP" > "${MAP}.tmp" && mv "${MAP}.tmp" "$MAP"
fi

echo "[✓] Forge manifest updated → ${TS}"
