#!/usr/bin/env bash

# --- CONFIG ---
WALLPAPER_DIR="$HOME/wallpapers"
STATE_DIR="$HOME/.cache/wallpaper_manager"
STATE_FILE="$STATE_DIR/current_index"
LINK_TARGET_FILE="$STATE_DIR/current_target"

mkdir -p "$STATE_DIR"

# Resolve caminho real (caso seja link simbólico)
REAL_DIR=$(realpath "$WALLPAPER_DIR" 2>/dev/null || echo "$WALLPAPER_DIR")

# Detecta se o destino do link mudou (tema novo)
LAST_TARGET=$(cat "$LINK_TARGET_FILE" 2>/dev/null || echo "")
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
    exit 0
fi

# Lê índice atual
CURRENT_INDEX=$(cat "$STATE_FILE" 2>/dev/null || echo "-1")

# Calcula próximo índice circular
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % TOTAL ))
NEXT_WALL="${WALLPAPERS[$NEXT_INDEX]}"

# Atualiza o estado
echo "$NEXT_INDEX" > "$STATE_FILE"

# Detecta monitor focado (com tolerância a erro)
FOCUSED_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name' 2>/dev/null || echo "")
if [ -z "$FOCUSED_MONITOR" ]; then
    echo "⚠ Nenhum monitor focado detectado, pulando..."
    exit 0
fi

# Aplica o wallpaper
hyprctl hyprpaper reload "$FOCUSED_MONITOR","$NEXT_WALL" 2>/dev/null || true

# Notificação opcional
# if command -v notify-send >/dev/null 2>&1; then
#     notify-send "Wallpaper trocado" "$(basename "$NEXT_WALL")"
# fi
