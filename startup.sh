#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all
export LIBGL_ALWAYS_SOFTWARE=1 

echo "[kelda] Corrigindo permissões do volume..."
# Isso garante que o usuário kelda seja dono da pasta de destino
sudo chown -R kelda:kelda /home/kelda/.wine

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

openbox &
sleep 2

GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -z "$GAME_EXE" ]; then
    echo "[kelda] Iniciando instalação..."
    wine "/home/kelda/game/Windows/TheTaleOfKelda.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART &
    
    # Robô de cliques persistente
    for i in {1..60}; do
        xdotool key --delay 500 Return 2>/dev/null
        GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)
        [ -n "$GAME_EXE" ] && break
        sleep 2
    done
fi

if [ -n "$GAME_EXE" ]; then
    echo "[kelda] Abrindo jogo..."
    cd "$(dirname "$GAME_EXE")"
    wine explorer /desktop=Kelda,960x864 "$GAME_EXE" &
else
    echo "[kelda] Falha na instalação, mas manterei o processo ativo para debug..."
fi

# --- O PULO DO GATO ---
# Isso impede que o script feche e o Supervisor entre em FATAL
echo "[kelda] Script em execução infinita para manter o container vivo."
tail -f /dev/null