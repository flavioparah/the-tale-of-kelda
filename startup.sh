#!/bin/bash

# Variáveis de ambiente para o Wine rodar sem placa de vídeo
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all
export LIBGL_ALWAYS_SOFTWARE=1
export MESA_LOADER_DRIVER_OVERRIDE=swrast

echo "[SISTEMA] Iniciando boot do container..."

# Ajusta o volume persistente para pertencer ao usuário kelda
chown -R kelda:kelda /home/kelda/.wine 2>/dev/null

# Aguarda o servidor gráfico Xvfb estar pronto
echo "[SISTEMA] Aguardando Xvfb..."
while ! xdpyinfo -display :1 >/dev/null 2>&1; do
    sleep 2
done

# Inicia o gerenciador de janelas em background
sudo -u kelda openbox &

echo "[SISTEMA] Procurando instalação do jogo..."
# Busca o .exe dentro do volume persistente
GAME_PATH=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -n "$GAME_PATH" ]; then
    echo "[SISTEMA] Jogo detectado! Abrindo agora..."
    cd "$(dirname "$GAME_PATH")"
    # Executa o jogo como usuário kelda dentro de um desktop virtual
    sudo -u kelda wine explorer /desktop=Kelda,960x864 "$GAME_PATH" &
else
    echo "[SISTEMA] Jogo não instalado. Abrindo instalador para o usuário..."
    # Se não encontrar o jogo, abre o instalador automaticamente
    sudo -u kelda wine explorer /desktop=Setup,960x864 "/home/kelda/game/Windows/TheTaleOfKelda.exe" &
fi

# BLOQUEIO DE SEGURANÇA: Impede que o container morra (evita status FATAL)
echo "[SISTEMA] Container ativo e estável."
while true; do
    sleep 100
done