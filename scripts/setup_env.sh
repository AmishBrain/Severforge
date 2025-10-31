#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Severforge Environment Setup"
echo "Authors: Anita & Pisces"

ROOT_DIR="$HOME/Severforge"
PY_ENV="$ROOT_DIR/.venv"

echo "[*] Updating system..."
sudo apt update -y && sudo apt install -y git curl jq python3 python3-venv unzip build-essential

echo "[*] Creating Python virtual environment..."
python3 -m venv "$PY_ENV"
source "$PY_ENV/bin/activate"
pip install --upgrade pip wheel requests rich

echo "[*] Creating core directories..."
mkdir -p "$ROOT_DIR"/{scripts,ops,docs,config,logs}
touch "$ROOT_DIR"/logs/install_$(date +%F_%H-%M-%S).log

echo "[*] Registering Severforge path..."
if ! grep -q "Severforge" ~/.zshrc; then
  echo 'export PATH="$HOME/Severforge/scripts:$PATH"' >> ~/.zshrc
  echo 'export SEVERFORGE_HOME="$HOME/Severforge"' >> ~/.zshrc
fi

echo "[*] Initializing Git repository..."
cd "$ROOT_DIR"
git init
git config user.name "Anita & Pisces"
git config user.email "severforge@local"
echo ".venv/" > .gitignore
echo "logs/" >> .gitignore

echo "[*] Environment ready. Reload shell or run:"
echo "  source ~/.zshrc"
echo
echo "✨ Severforge is ready to roll!"
