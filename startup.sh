#!/bin/bash
set -e

export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

openbox &
sleep 2

GAME_EXE="/home/kelda/.wine/drive_c/Program Files/The Tale of Kelda - Beta/The Tale of Kelda.exe"

if [ ! -f "$GAME_EXE" ]; then
    echo "[kelda] Jogo não detectado. Iniciando instalação silenciosa..."
    # Roda o instalador e aguarda ele fechar
    wine "/home/kelda/game/Windows/TheTaleOfKelda.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    
    echo "[kelda] Aguardando conclusão da instalação..."
    while pgrep -f "TheTaleOfKelda.exe" > /dev/null; do sleep 2; done
    sleep 5
fi

echo "[kelda] Iniciando o jogo..."
cd "/home/kelda/.wine/drive_c/Program Files/The Tale of Kelda - Beta"
exec wine "The Tale of Kelda.exe"