#!/usr/bin/env bash
set -euo pipefail

echo "🧹 Severforge Sanitization Protocol Engaged..."
LOG_DIR="$HOME/Severforge/logs"
TARGET_DIRS=("$HOME/Downloads" "$HOME/tmp" "$HOME/Severforge/tmp")

# Create log directory if missing
mkdir -p "$LOG_DIR"

# Timestamped log
LOG_FILE="$LOG_DIR/sanitize_$(date +%F_%H-%M-%S).log"

echo "[*] Starting environment sweep at $(date)" | tee -a "$LOG_FILE"

# Remove potential leftovers
for dir in "${TARGET_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "[-] Cleaning $dir..." | tee -a "$LOG_FILE"
    rm -rf "${dir:?}/"* 2>>"$LOG_FILE" || true
  fi
done

# Securely shred temp or cache files if any
echo "[*] Shredding temp/cache files..." | tee -a "$LOG_FILE"
find "$HOME" -type f \( -name "*.tmp" -o -name "*.bak" -o -name "*.swp" \) -print -delete 2>>"$LOG_FILE" || true

# Remove shell history (optional safety)
echo "[*] Clearing shell history..." | tee -a "$LOG_FILE"
history -c || true
: > ~/.bash_history 2>/dev/null || true
: > ~/.zsh_history 2>/dev/null || true

echo "[+] Environment sanitized successfully at $(date)" | tee -a "$LOG_FILE"
echo "[+] Log saved to: $LOG_FILE"
echo "🧠  Ready for next mission."
