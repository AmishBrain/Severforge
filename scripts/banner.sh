#!/usr/bin/env bash
# 🩸 Severforge Banner — Clean & Actionable

pulse() {
  for i in {1..2}; do
    echo -ne "🩸"
    sleep 0.15
    echo -ne "\r "
    sleep 0.15
    echo -ne "\r"
  done
}

forge_heat() {
  colors=(31 33 91 93 97)
  for c in "${colors[@]}"; do
    echo -ne "\e[38;5;${c}mSEVERFORGE\e[0m\b\b\b\b\b\b\b\b\b\b"
    sleep 0.1
  done
  echo -ne "SEVERFORGE"
}

clear
pulse
VERSION="v2.0.0"
echo ""
echo "🧠 HUMAN: Amish + ⚙️ AI: Pisces + 🌊 AI: Claude"
echo ""
echo -ne "        🩸  "
forge_heat
echo -e "  🩸"
echo ""
echo "Modular Security Automation & Bug Bounty Framework"
echo "${VERSION} — Three minds, one forge"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "📚 QUICK START - Run these to understand the system:"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  sf verbs              # Show all available commands"
echo "  sf_status             # System health & integrity check"
echo "  cat ~/Severforge/docs/PISCES_CONTEXT.md     # Core system info"
echo "  bash ~/Severforge/scripts/sf_sessions latest # Recent session"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "🎯 MAIN WORKFLOWS:"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  sf_pipeline_full <target>    # Full recon scan"
echo "  sf report <target>           # View scan results"
echo "  sf report <target> --markdown  # Generate markdown report"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Forge ready. Type 'sf verbs' to see all commands."
echo "════════════════════════════════════════════════════════════════"
echo ""
