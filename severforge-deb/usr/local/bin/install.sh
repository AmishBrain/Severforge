#!/usr/bin/env bash
set -euo pipefail

echo "🔥 Installing Severforge..."
sleep 1

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  PKG_MANAGER="sudo apt"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  PKG_MANAGER="brew"
else
  echo "Unsupported OS. Severforge supports Linux and macOS."
  exit 1
fi

# Install dependencies
echo "[*] Installing dependencies..."
if [[ "$PKG_MANAGER" == "sudo apt" ]]; then
  sudo apt update -y && sudo apt install -y git curl python3 python3-venv
else
  brew install git curl python3
fi

# Clone repo if not present
if [ ! -d "$HOME/Severforge" ]; then
  echo "[*] Cloning Severforge..."
  git clone https://github.com/AmishBrain/Severforge.git "$HOME/Severforge"
else
  echo "[*] Existing Severforge directory found — skipping clone."
fi

# Run setup
echo "[*] Running setup..."
bash "$HOME/Severforge/scripts/setup_env.sh"

# Display banner
bash "$HOME/Severforge/scripts/banner.sh"

echo ""
echo "✅ Severforge installed successfully."
echo "Type 'bash ~/Severforge/scripts/banner.sh' to relaunch the forge banner anytime."
