#!/usr/bin/env bash
# ────────────────────────────────────────────────
# 🩵 Severforge Mood Engine
# Shared module that generates forge personality lines
# ────────────────────────────────────────────────

forge_mood() {
  hour=$(date +%H)
  uptime_min=$(awk '{print int($1/60)}' /proc/uptime 2>/dev/null || echo 0)

  # Determine base mood by time
  if (( hour >= 6 && hour < 12 )); then
    mood="🌅  Awakening — the forge yawns, ready for the day."
  elif (( hour >= 12 && hour < 18 )); then
    mood="🔥  Stable — the forge hums with purpose."
  elif (( hour >= 18 && hour < 22 )); then
    mood="⚡  Reactive — sparks fly as energy surges."
  else
    mood="🌒  Cooling Down — the forge whispers in the dark."
  fi

  # Adjust for high uptime
  if (( uptime_min > 600 )); then
    mood="💤  Hibernate — the forge rests but remembers."
  fi

  echo "$mood"
}

forge_react() {
  action="$1"
  case "$action" in
    create) echo "💬 The forge stirs — new data fuels its heart." ;;
    modify) echo "💬 The forge flexes — molten lines shift and form anew." ;;
    delete) echo "💬 The forge grieves the loss, but endures." ;;
    *) echo "💬 The forge observes silently." ;;
  esac
}
