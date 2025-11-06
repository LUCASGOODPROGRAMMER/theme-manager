#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/wallpaper_manager_loop.pid"

# Evita instâncias duplicadas
if [ -f "$STATE_FILE" ] && kill -0 "$(cat "$STATE_FILE")" 2>/dev/null; then
  exit 0
fi
echo $$ >"$STATE_FILE"

while true; do
  ~/.config/hypr/scripts/next_wallpaper.sh
  sleep 600
done