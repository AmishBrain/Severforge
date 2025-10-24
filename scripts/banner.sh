#!/usr/bin/env bash
# 🩸 Severforge Banner — Forge Heatwave Edition

pulse() {
  for i in {1..3}; do
    echo -ne "🩸"
    sleep 0.2
    echo -ne "\r "
    sleep 0.2
    echo -ne "\r"
  done
}

forge_heat() {
  colors=(31 33 91 93 97) # red → orange → bright gold → white
  for c in "${colors[@]}"; do
    echo -ne "\e[38;5;${c}mSEVERFORGE\e[0m\b\b\b\b\b\b\b\b\b\b"
    sleep 0.15
  done
  echo -ne "SEVERFORGE"
}

clear
pulse
VERSION="v1.0.0"
BUILD_DATE="$(date '+%Y-%m-%d %H:%M:%S')"

echo ""
echo "🧠  HUMAN: Amish   ⚙️  AI: Pisces"
echo ""
pulse
echo -ne "        🩸  "
forge_heat
echo -e "  🩸"
echo ""
echo "Modular Security Automation Environment"
echo "Built with logic and soul — forged by two"
echo ""
echo "${VERSION} — Amish × Pisces Edition"
echo "Build Date: ${BUILD_DATE}"
echo ""
