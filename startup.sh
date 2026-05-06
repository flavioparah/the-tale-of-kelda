#!/bin/bash
set -e

export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export SDL_AUDIODRIVER=dummy
export SDL_RENDER_SCALE_QUALITY=0

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 40); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

echo "[kelda] Display pronto."
openbox &
sleep 1

# Caminho do jogo após instalação pelo Wine
GAME="/home/kelda/.wine/drive_c/Program Files/The Tale of Kelda - Beta/The Tale of Kelda.exe"

# Se o jogo ainda não foi instalado, roda o instalador primeiro
if [ ! -f "$GAME" ]; then
  echo "[kelda] Jogo não instalado — rodando instalador silenciosamente..."
  wine /home/kelda/game/Windows/TheTaleOfKelda.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
  sleep 10
fi

echo "[kelda] Iniciando The Tale of Kelda..."
cd "/home/kelda/.wine/drive_c/Program Files/The Tale of Kelda - Beta"
exec wine "The Tale of Kelda.exe"
