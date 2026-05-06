#!/bin/bash

export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all
export LIBGL_ALWAYS_SOFTWARE=1
export MESA_LOADER_DRIVER_OVERRIDE=swrast

echo "[SISTEMA] Corrigindo permissões e aguardando vídeo..."
chown -R kelda:kelda /home/kelda/.wine 2>/dev/null

while ! xdpyinfo -display :1 >/dev/null 2>&1; do
    sleep 2
done

# Inicia o gerenciador de janelas para o jogo poder abrir janelas
sudo -u kelda openbox &
sleep 2

# Tenta localizar o jogo já instalado
GAME_PATH=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -n "$GAME_PATH" ]; then
    echo "[SISTEMA] Jogo encontrado em: $GAME_PATH"
    cd "$(dirname "$GAME_PATH")"
    # O modo desktop evita que o jogo tente mudar a resolução da tela e falhe
    sudo -u kelda wine explorer /desktop=Kelda,960x864 "$GAME_PATH" &
else
    echo "[SISTEMA] Jogo não instalado. Iniciando instalador..."
    sudo -u kelda wine explorer /desktop=Setup,960x864 "/home/kelda/game/Windows/TheTaleOfKelda.exe" &
fi

# Mantém o script rodando para o Supervisor não dar erro FATAL
while true; do
    sleep 100
done