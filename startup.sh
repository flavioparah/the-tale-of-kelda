#!/bin/bash
set -e

export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1

# MonoGame usa SDL2 — aponta para a lib nativa do sistema
export SDL_AUDIODRIVER=dummy
export WINEDLLOVERRIDES="mscoree,mshtml="

echo "[kelda] Inicializando Wine prefix..."
wineboot --init 2>/dev/null || true

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

echo "[kelda] Xvfb pronto."

# Gerenciador de janelas mínimo
openbox &
sleep 1

# O .exe e as DLLs estão em MonoBundle/ — precisa rodar de dentro dessa pasta
# para que as DLLs relativas sejam encontradas
cd /home/kelda/game/MonoBundle

echo "[kelda] Iniciando The Tale of Kelda via Wine..."
exec wine "The Tale of Kelda - Beta.exe"
