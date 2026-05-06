#!/bin/bash
# Removido o set -e para evitar que o script morra se um comando simples falhar
# set -e 

export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export SDL_AUDIODRIVER=dummy

echo "[kelda] Aguardando Xvfb no display :1..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

# Inicia o gerenciador de janelas
openbox &
sleep 2

GAME_DIR="/home/kelda/.wine/drive_c/Program Files/The Tale of Kelda - Beta"
GAME_EXE="$GAME_DIR/The Tale of Kelda.exe"

if [ ! -f "$GAME_EXE" ]; then
    echo "[kelda] Jogo não detectado. Iniciando instalador..."
    # Rodando sem o /VERYSILENT por um momento pode ajudar a ver se há erro, 
    # mas manteremos para automação. Adicionei o wineboot.
    wine wineboot --init
    wine "/home/kelda/game/Windows/TheTaleOfKelda.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    
    echo "[kelda] Aguardando processos do instalador finalizarem..."
    # Espera o processo sumir
    while pgrep -i "TheTaleOfKelda" > /dev/null; do sleep 2; done
    
    echo "[kelda] Limpando processos remanescentes do Wine..."
    wineserver -k
    sleep 5
fi

# Verificação extra de segurança
if [ -f "$GAME_EXE" ]; then
    echo "[kelda] Jogo encontrado! Forçando início..."
    cd "$GAME_DIR"
    # Usamos o 'wine start' que costuma lidar melhor com caminhos com espaço e foco de janela
    exec wine start /wait /max "The Tale of Kelda.exe"
else
    echo "[kelda] ERRO CRÍTICO: O arquivo não foi encontrado em: $GAME_EXE"
    # Lista o que tem na pasta para debug nos logs do Coolify
    ls -R "/home/kelda/.wine/drive_c/Program Files/"
    exit 1
fi