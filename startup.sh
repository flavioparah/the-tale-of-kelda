#!/bin/bash
set -e

# Configurações de ambiente
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export SDL_AUDIODRIVER=dummy
export SDL_RENDER_SCALE_QUALITY=0

echo "[kelda] Aguardando Xvfb no display :1..."
for i in $(seq 1 40); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 0.5
done

echo "[kelda] Iniciando Openbox..."
openbox &
sleep 1

# Caminho onde o instalador colocou o jogo
GAME_PATH="/home/kelda/.wine/drive_c/Program Files/The Tale of Kelda - Beta"
EXE_NAME="The Tale of Kelda.exe"

if [ -d "$GAME_PATH" ]; then
    echo "[kelda] Iniciando o jogo direto da pasta instalada..."
    cd "$GAME_PATH"
    exec wine "$EXE_NAME"
else
    echo "[kelda] ERRO: Pasta do jogo não encontrada em $GAME_PATH"
    exit 1
fi