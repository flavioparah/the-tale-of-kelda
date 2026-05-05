#!/bin/bash
set -e

export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export SDL_AUDIODRIVER=dummy
export SDL_RENDER_SCALE_QUALITY=0
export WINEDLLOVERRIDES="mscoree,mshtml="

echo "[kelda] Inicializando Wine prefix..."
wineboot --init 2>/dev/null || true

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 40); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

echo "[kelda] Display pronto."
openbox &
sleep 1

EXE="/home/kelda/game/Windows/TheTaleOfKelda.exe"

if [ ! -f "$EXE" ]; then
  echo "[kelda] ERRO: .exe não encontrado em $EXE"
  find /home/kelda/game -name "*.exe" 2>/dev/null
  sleep infinity
fi

echo "[kelda] Iniciando via Wine: TheTaleOfKelda.exe"
cd /home/kelda/game/Windows
exec wine "$EXE"
