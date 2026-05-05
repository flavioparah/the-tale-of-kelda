#!/bin/bash
set -e

export DISPLAY=:1
export SDL_AUDIODRIVER=dummy
export SDL_RENDER_SCALE_QUALITY=0
# Aponta o Mono para as DLLs do jogo
export MONO_PATH=/home/kelda/game/MonoBundle

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 40); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

echo "[kelda] Display pronto."
openbox &
sleep 1

# Encontra o .exe automaticamente
EXE=$(find /home/kelda/game/MonoBundle -name "*.exe" 2>/dev/null | head -1)

if [ -z "$EXE" ]; then
  echo "[kelda] ERRO: nenhum .exe encontrado"
  find /home/kelda/game -name "*.exe" 2>/dev/null
  sleep infinity
fi

EXE_DIR=$(dirname "$EXE")
EXE_NAME=$(basename "$EXE")

echo "[kelda] Iniciando com Mono: $EXE_NAME"
cd "$EXE_DIR"

# Roda com mono nativo do Linux (não Wine)
# LD_LIBRARY_PATH garante que o SDL2 e OpenAL nativos sejam encontrados
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
exec mono "$EXE_NAME"
