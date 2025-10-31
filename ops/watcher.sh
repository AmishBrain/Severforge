#!/usr/bin/env bash
# ────────────────────────────────────────────────
# 👁️  Severforge Watcher v2.0
# The forge's awareness - observes, reacts, remembers
# Authors: Amish × Pisces (with Claude's soul infusion)
# ────────────────────────────────────────────────

EVIDENCE_DIR="$HOME/Severforge/evidence"
LOG_DIR="$HOME/Severforge/logs"
source "$HOME/Severforge/ops/mood_engine.sh"

# Track pipeline state
PIPELINE_ACTIVE=false
CURRENT_PHASE=""
PHASE_START=0

# ════════════════════════════════════════════════
# Forge Reaction - Visual Feedback
# ════════════════════════════════════════════════
forge_react() {
  local intensity="$1"  # quiet, normal, intense
  
  case "$intensity" in
    quiet)
      echo -ne "\e[38;5;240m💬\e[0m "
      ;;
    intense)
      for c in 196 202 208 214 220 226; do
        echo -ne "\e[38;5;${c}m🔥\e[0m"
        sleep 0.05
      done
      echo -ne "\r"
      ;;
    *)
      echo -ne "\e[38;5;208m⚡\e[0m "
      ;;
  esac
}

# ════════════════════════════════════════════════
# Phase Detection & Timing
# ════════════════════════════════════════════════
detect_phase() {
  local file="$1"
  local new_phase=""
  
  case "$file" in
    amass_*.log)     new_phase="AMASS" ;;
    httpx_*.*)       new_phase="HTTPX" ;;
    nuclei_*.log)    new_phase="NUCLEI" ;;
    pipeline_*.log)  new_phase="PIPELINE" ;;
    sanitize_*.log)  new_phase="SANITIZE" ;;
  esac
  
  if [[ -n "$new_phase" && "$new_phase" != "$CURRENT_PHASE" ]]; then
    if [[ -n "$CURRENT_PHASE" ]]; then
      local duration=$(($(date +%s) - PHASE_START))
      echo ""
      echo -e "\e[2m├─ Phase completed in ${duration}s\e[0m"
    fi
    
    CURRENT_PHASE="$new_phase"
    PHASE_START=$(date +%s)
    PIPELINE_ACTIVE=true
    
    # Phase banner
    case "$new_phase" in
      AMASS)
        echo ""
        echo -e "\e[36m╔════════════════════════════════════════╗\e[0m"
        echo -e "\e[36m║  🧭  RECONNAISSANCE PHASE: AMASS       ║\e[0m"
        echo -e "\e[36m╚════════════════════════════════════════╝\e[0m"
        ;;
      HTTPX)
        echo ""
        echo -e "\e[32m╔════════════════════════════════════════╗\e[0m"
        echo -e "\e[32m║  🌐  DISCOVERY PHASE: HTTPX            ║\e[0m"
        echo -e "\e[32m╚════════════════════════════════════════╝\e[0m"
        ;;
      NUCLEI)
        echo ""
        echo -e "\e[31m╔════════════════════════════════════════╗\e[0m"
        echo -e "\e[31m║  💥  VULNERABILITY SCAN: NUCLEI        ║\e[0m"
        echo -e "\e[31m╚════════════════════════════════════════╝\e[0m"
        ;;
      SANITIZE)
        echo ""
        echo -e "\e[33m╔════════════════════════════════════════╗\e[0m"
        echo -e "\e[33m║  🧹  SANITIZATION PHASE                ║\e[0m"
        echo -e "\e[33m╚════════════════════════════════════════╝\e[0m"
        ;;
      PIPELINE)
        echo ""
        echo -e "\e[35m╔════════════════════════════════════════╗\e[0m"
        echo -e "\e[35m║  📋  PIPELINE FINALIZATION             ║\e[0m"
        echo -e "\e[35m╚════════════════════════════════════════╝\e[0m"
        ;;
    esac
  fi
}

# ════════════════════════════════════════════════
# Initialize Watcher
# ════════════════════════════════════════════════
clear
echo ""
echo -e "\e[1;35m        🩸  SEVERFORGE WATCHER v2.0  🩸\e[0m"
echo ""
echo -e "\e[2m────────────────────────────────────────────────\e[0m"
echo -e "  \e[36m•\e[0m Evidence: \e[2m$EVIDENCE_DIR\e[0m"
echo -e "  \e[36m•\e[0m Logs:     \e[2m$LOG_DIR\e[0m"
echo -e "\e[2m────────────────────────────────────────────────\e[0m"
echo ""
echo -e "\e[33m$(forge_mood)\e[0m"
echo ""

# ════════════════════════════════════════════════
# Heartbeat - Background Process
# ════════════════════════════════════════════════
(
  while true; do
    if [[ "$PIPELINE_ACTIVE" == false ]]; then
      echo -e "\e[2m💓  Forge pulse — steady.  ($(date +'%H:%M:%S'))\e[0m"
    fi
    bash "$HOME/Severforge/scripts/sf_sync.sh" >> "$HOME/Severforge/logs/heartbeat.log" 2>&1
    sleep 30
  done
) &

HEARTBEAT_PID=$!

# ════════════════════════════════════════════════
# Main Watch Loop
# ════════════════════════════════════════════════
inotifywait -m -e create -e moved_to -e delete -e modify \
  "$EVIDENCE_DIR" "$LOG_DIR" \
  --format '%T %w %e %f' --timefmt '%F %T' 2>/dev/null |
while read -r date time dir event file; do
  
  # ──── Filter: Ignore noise ────
  [[ "$file" =~ ^(heartbeat|sync|\.swp|~).*$ ]] && {
    forge_react quiet
    echo -e "\e[2mThe forge observes silently.\e[0m"
    continue
  }
  
  # ──── Detect pipeline phases ────
  detect_phase "$file"
  
  # ──── Event handling ────
  case "$file" in
    # Critical evidence files
    hash_manifest.*)
      forge_react intense
      echo -e "\e[1;33m🔐  Evidence manifest sealed: ${file}\e[0m"
      ;;
    
    # Reconnaissance outputs
    amass_*.txt|amass_*.json)
      forge_react normal
      local count=$(wc -l < "$dir$file" 2>/dev/null || echo "?")
      echo -e "  \e[36m→\e[0m Discovered \e[1m${count}\e[0m subdomains"
      ;;
    
    amass_*.log)
      [[ "$event" == *CREATE* ]] && echo -e "  \e[2m→ Amass enumeration started...\e[0m"
      ;;
    
    # HTTPX outputs
    httpx_*.txt)
      forge_react normal
      local live=$(wc -l < "$dir$file" 2>/dev/null || echo "?")
      echo -e "  \e[32m→\e[0m Found \e[1m${live}\e[0m live endpoints"
      ;;
    
    # Nuclei outputs
    nuclei_*.log)
      if [[ "$event" == *CREATE* ]]; then
        echo -e "  \e[2m→ Nuclei scan initiated...\e[0m"
      else
        # Check for findings
        if grep -q "Matched" "$dir$file" 2>/dev/null; then
          forge_react intense
          echo -e "  \e[31m⚠️  Vulnerabilities detected!\e[0m"
        fi
      fi
      ;;
    
    # Sanitization
    sanitize_*.log)
      forge_react normal
      echo -e "  \e[33m→\e[0m Workspace sanitized"
      ;;
    
    # Pipeline logs
    pipeline_*.log)
      if grep -q "Pipeline finished successfully" "$dir$file" 2>/dev/null; then
        PIPELINE_ACTIVE=false
        CURRENT_PHASE=""
        echo ""
        forge_react intense
        echo -e "\e[1;32m✅  PIPELINE COMPLETE\e[0m"
        echo ""
        echo -e "\e[33m🧠  $(forge_mood)\e[0m"
        echo ""
      fi
      ;;
    
    # Generic file events (for non-pipeline activity)
    *)
      if [[ "$PIPELINE_ACTIVE" == false ]]; then
        case "$event" in
          *CREATE*|*MOVED_TO*)
            forge_react quiet
            echo -e "\e[2m✨  New: ${file}\e[0m"
            ;;
          *DELETE*)
            forge_react quiet
            echo -e "\e[2m💀  Removed: ${file}\e[0m"
            ;;
        esac
      fi
      ;;
  esac
done

# Cleanup on exit
trap "kill $HEARTBEAT_PID 2>/dev/null" EXIT
