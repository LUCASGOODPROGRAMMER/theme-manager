#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/wallpaper_manager_loop.pid"
SCRIPT_FILE="$HOME/.config/hypr/scripts/next_wallpaper.sh"

# Verifica se o script de wallpaper existe
if [ ! -f "$SCRIPT_FILE" ]; then
  echo "Erro: O script de troca de wallpaper não foi encontrado em $SCRIPT_FILE"
  exit 1
fi

# Evita instâncias duplicadas
if [ -f "$STATE_FILE" ] && kill -0 "$(cat "$STATE_FILE")" 2>/dev/null; then
  echo "Instância do wallpaper manager já está em execução."
  exit 0
fi

# Cria o arquivo de estado com o PID do processo atual
echo $$ > "$STATE_FILE"

# Função de limpeza ao sair
cleanup() {
  echo "Finalizando o wallpaper manager..."
  rm -f "$STATE_FILE"
}

trap cleanup EXIT

# Loop de execução
while true; do
  # Executa o script de troca de wallpaper
  "$SCRIPT_FILE"
  
  # Atraso de 60 segundos antes da próxima execução
  sleep 60
done
