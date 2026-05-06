#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all
export LIBGL_ALWAYS_SOFTWARE=1 

# 1. Garante que o usuário kelda manda na pasta do volume
sudo chown -R kelda:kelda /home/kelda/.wine

# 2. Aguarda o servidor de vídeo (Xvfb)
until xdpyinfo -display :1 >/dev/null 2>&1; do sleep 1; done

openbox &
sleep 2

# 3. Verifica se o jogo JÁ ESTÁ instalado no volume persistente
GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -z "$GAME_EXE" ]; then
    echo "[Sistema] Primeira execução: Instalando o jogo na VPS..."
    # Instala de forma totalmente silenciosa
    wine "/home/kelda/game/Windows/TheTaleOfKelda.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    
    # Aguarda o Wine terminar de gravar os arquivos no disco
    wineserver -w
    
    # Procura o executável novamente após a instalação
    GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)
fi

# 4. Inicia o jogo diretamente
if [ -n "$GAME_EXE" ]; then
    echo "[Sistema] Jogo pronto! Iniciando para o usuário..."
    cd "$(dirname "$GAME_EXE")"
    # O comando 'exec' faz o container focar apenas no jogo
    exec wine explorer /desktop=Kelda,960x864 "$GAME_EXE"
else
    echo "[Erro] Falha crítica na instalação automática."
    tail -f /dev/null
fi