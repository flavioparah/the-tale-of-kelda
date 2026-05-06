#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all 

# Garante que o diretório existe e tem permissão
mkdir -p /home/kelda/.wine

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

openbox &
sleep 2

# Procura o executável
GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -z "$GAME_EXE" ]; then
    echo "[kelda] Jogo não instalado. Iniciando instalador..."
    # Rodando SEM /VERYSILENT para você poder interagir pelo VNC se necessário
    wine "/home/kelda/game/Windows/TheTaleOfKelda.exe" &
    
    echo "[kelda] Iniciando batedor de Enter automático..."
    # Loop para fechar janelas chatas como a do OpenAL (Captura de Tela 2026-05-05 às 22.32.00.png)
    (
        for i in {1..100}; do
            # Tenta focar e dar Enter em qualquer janela de Installer ou OpenAL
            xdotool search --name "OpenAL" windowactivate key Return 2>/dev/null
            xdotool search --name "Installer" windowactivate key Return 2>/dev/null
            xdotool search --name "Select Setup Language" windowactivate key Return 2>/dev/null
            sleep 2
        done
    ) &

    echo "[kelda] Aguardando conclusão da instalação (verifique o VNC)..."
    while pgrep -i "TheTaleOfKelda" > /dev/null; do sleep 5; done
    wineserver -w
    
    GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)
fi

if [ -n "$GAME_EXE" ]; then
    echo "[kelda] Jogo encontrado! Abrindo em Desktop Virtual..."
    cd "$(dirname "$GAME_EXE")"
    # O desktop virtual ajuda a evitar que o jogo minimize ou suma
    exec wine explorer /desktop=Kelda,960x864 "The Tale of Kelda.exe"
else
    echo "[kelda] Erro: Jogo não instalado. Tente rodar o instalador manualmente pelo terminal do VNC se possível."
    exit 1
fi