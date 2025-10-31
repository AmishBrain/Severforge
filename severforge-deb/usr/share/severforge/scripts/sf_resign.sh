#!/usr/bin/env bash
# 🔐 Severforge — sf_resign
# Recalculates SHA256 integrity baseline for core scripts

BASELINE="$HOME/Severforge/config/integrity_baseline.txt"
TMPFILE="/tmp/sf_rehash.$$.tmp"

echo "🔧 Rebuilding integrity baseline..."
find "$HOME/Severforge/scripts" "$HOME/Severforge/ops" -type f -exec sha256sum {} \; | sort > "$TMPFILE"

if [ -s "$TMPFILE" ]; then
  mv "$TMPFILE" "$BASELINE"
  echo "✅ New baseline written to: $BASELINE"
else
  echo "❌ Error: no files hashed, baseline not updated."
  rm -f "$TMPFILE"
  exit 1
fi

echo "🔏 Integrity baseline re-signed successfully."
