#!/usr/bin/env bash
# ⚙️ Severforge Recon Suite Installer

TOOLS=(nmap jq amass httpx nuclei)

echo "🧠 Installing Recon Suite..."
for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $tool already installed."
    else
        echo "🚀 Installing $tool..."
    fi
done
echo "💬 $(bash ~/Severforge/ops/mood_engine.sh forge_mood)"
echo "✨ Recon suite check complete."
