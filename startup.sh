#!/bin/bash

export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all # Desativa logs inúteis do wine para não travar o buffer
export SDL_AUDIODRIVER=dummy

echo "[kelda] Limpando processos antigos..."
wineserver -k || true

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

# Inicia o Openbox com as janelas maximizadas por padrão
openbox &
sleep 2

# Tenta localizar o jogo
GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -z "$GAME_EXE" ]; then
    echo "[kelda] Jogo não instalado. Iniciando instalador..."
    # Configura o wine para não pedir Gecko/Mono (evita travar o script)
    export WINEDLLOVERRIDES="mscoree,mshtml="
    
    wine "/home/kelda/game/Windows/TheTaleOfKelda.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    
    echo "[kelda] Aguardando instalador..."
    while pgrep -i "TheTaleOfKelda" > /dev/null; do sleep 2; done
    wineserver -w # Aguarda o servidor wine fechar graciosamente
    
    GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)
fi

if [ -n "$GAME_EXE" ]; then
    echo "[kelda] Jogo encontrado em: $GAME_EXE"
    GAME_DIR=$(dirname "$GAME_EXE")
    cd "$GAME_DIR"
    
    # Truque: Tira o foco de qualquer erro e foca no jogo
    echo "[kelda] Lançando jogo com wine explorer..."
    exec wine explorer /desktop=Kelda,960x864 "$GAME_EXE"
else
    echo "[kelda] Erro: Jogo não encontrado. Verifique os logs abaixo:"
    find /home/kelda/.wine/drive_c -maxdepth 4
    exit 1
fi