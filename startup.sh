#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all

echo "[kelda] Ajustando volume..."
sudo chown -R kelda:kelda /home/kelda/.wine

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

openbox &
sleep 2

# Procura o jogo
GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -z "$GAME_EXE" ]; then
    echo "[kelda] Abrindo instalador VISUALMENTE. Verifique o navegador agora!"
    # Abrindo sem flags silenciosas e dentro de um desktop virtual
    wine explorer /desktop=Instalador,960x864 "/home/kelda/game/Windows/TheTaleOfKelda.exe"
else
    echo "[kelda] Jogo já instalado. Iniciando..."
    cd "$(dirname "$GAME_EXE")"
    exec wine explorer /desktop=Kelda,960x864 "The Tale of Kelda.exe"
fi

# Mantém vivo se algo falhar
tail -f /dev/null