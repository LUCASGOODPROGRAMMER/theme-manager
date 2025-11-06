#!/usr/bin/env bash

set -e

# --- CONFIG ---
WALLPAPER_DIR="$HOME/wallpapers"
STATE_DIR="$HOME/.cache/wallpaper_manager"
STATE_FILE="$STATE_DIR/current_index"
LINK_TARGET_FILE="$STATE_DIR/current_target"

mkdir -p "$STATE_DIR"

# Resolve o caminho real da pasta (caso seja link simbólico)
REAL_DIR=$(realpath "$WALLPAPER_DIR" 2>/dev/null || echo "$WALLPAPER_DIR")

# Detecta se o destino do link mudou (tema novo)
if [ -f "$LINK_TARGET_FILE" ]; then
    LAST_TARGET=$(cat "$LINK_TARGET_FILE")
else
    LAST_TARGET=""
fi

if [ "$REAL_DIR" != "$LAST_TARGET" ]; then
    echo "🔄 Novo tema detectado, resetando contador..."
    echo "$REAL_DIR" > "$LINK_TARGET_FILE"
    echo "-1" > "$STATE_FILE"
fi

# Lista wallpapers (ordenados)
mapfile -t WALLPAPERS < <(find "$REAL_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort)

TOTAL=${#WALLPAPERS[@]}
if [ "$TOTAL" -eq 0 ]; then
    echo "Nenhum wallpaper encontrado em $REAL_DIR"
    exit 1
fi

# Lê índice atual
if [ -f "$STATE_FILE" ]; then
    CURRENT_INDEX=$(cat "$STATE_FILE")
else
    CURRENT_INDEX=-1
fi

# Calcula próximo índice circular
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % TOTAL ))
NEXT_WALL="${WALLPAPERS[$NEXT_INDEX]}"

# Atualiza o estado
echo "$NEXT_INDEX" > "$STATE_FILE"

# Detecta monitor focado
FOCUSED_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Aplica o wallpaper
hyprctl hyprpaper reload "$FOCUSED_MONITOR","$NEXT_WALL"

# Notificação opcional
if command -v notify-send >/dev/null 2>&1; then
    notify-send "Wallpaper trocado" "$(basename "$NEXT_WALL")"
fi
