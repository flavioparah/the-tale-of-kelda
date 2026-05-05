#!/bin/bash
set -e

export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export SDL_AUDIODRIVER=dummy
export SDL_RENDER_SCALE_QUALITY=0
export WINEDLLOVERRIDES="mscoree,mshtml="
export MONO_PATH=/home/kelda/game/MonoBundle

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

# Tenta encontrar o .exe automaticamente
EXE=$(find /home/kelda/game/MonoBundle -name "*.exe" 2>/dev/null | head -1)

if [ -z "$EXE" ]; then
  echo "[kelda] ERRO: nenhum .exe encontrado em MonoBundle"
  echo "[kelda] Arquivos disponíveis:"
  find /home/kelda/game -name "*.exe" 2>/dev/null
  sleep infinity
fi

EXE_DIR=$(dirname "$EXE")
EXE_NAME=$(basename "$EXE")

echo "[kelda] Iniciando: $EXE_NAME"
cd "$EXE_DIR"
exec wine "$EXE_NAME"
