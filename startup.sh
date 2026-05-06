#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all 

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

openbox &
sleep 2

GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -z "$GAME_EXE" ]; then
    echo "[kelda] Iniciando instalador..."
    wine "/home/kelda/game/Windows/TheTaleOfKelda.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART &
    
    echo "[kelda] Robô de cliques ativado..."
    # Esse loop vai apertar "Enter" em qualquer janela que aparecer por 2 minutos
    # Isso resolve a tela da sua imagem e a do OpenAL
    for i in {1..60}; do
        # Envia Enter para a janela ativa (que geralmente é o instalador pedindo 'Next')
        xdotool key --delay 500 Return
        sleep 2
        # Se o executável aparecer, a instalação acabou
        GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)
        [ -n "$GAME_EXE" ] && break
    done

    wineserver -w
fi

echo "[kelda] Abrindo o jogo..."
cd "$(dirname "$GAME_EXE")"
exec wine explorer /desktop=Kelda,960x864 "The Tale of Kelda.exe"