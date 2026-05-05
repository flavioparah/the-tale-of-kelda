#!/bin/bash
set -e

export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export SDL_AUDIODRIVER=dummy
export SDL_RENDER_SCALE_QUALITY=0
export WINEDLLOVERRIDES="mscoree,mshtml="
export MONO_PATH=/home/kelda/game/MacOS/MonoBundle

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

# Caminho correto conforme estrutura do repositório:
# MacOS/MonoBundle/The Tale of Kelda - Beta.exe
EXE_DIR="/home/kelda/game/MacOS/MonoBundle"
EXE_NAME="The Tale of Kelda - Beta.exe"

if [ ! -f "$EXE_DIR/$EXE_NAME" ]; then
  echo "[kelda] ERRO: .exe não encontrado em $EXE_DIR/$EXE_NAME"
  echo "[kelda] Conteúdo de /home/kelda/game:"
  find /home/kelda/game -name "*.exe" 2>/dev/null
  sleep infinity
fi

echo "[kelda] Iniciando: $EXE_NAME"
cd "$EXE_DIR"
exec wine "$EXE_NAME"
