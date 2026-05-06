#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all
# Desativa aceleração de hardware (essencial para VPS sem GPU)
export LIBGL_ALWAYS_SOFTWARE=1
export MESA_LOADER_DRIVER_OVERRIDE=swrast

echo "[kelda] Ajustando permissões do volume..."
sudo chown -R kelda:kelda /home/kelda/.wine

echo "[kelda] Aguardando vídeo..."
until xdpyinfo -display :1 >/dev/null 2>&1; do sleep 1; done

openbox &
sleep 2

# Procura o executável do jogo instalado no volume
# (Ele busca em todo o drive_c caso o caminho mude)
GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -n "$GAME_EXE" ]; then
    echo "[kelda] Jogo localizado em: $GAME_EXE"
    echo "[kelda] Lançando em Desktop Virtual..."
    cd "$(dirname "$GAME_EXE")"
    
    # Roda o jogo dentro de um desktop virtual (Desktop Kelda)
    # Isso evita que o jogo tente mudar a resolução da VPS e fique preto
    exec wine explorer /desktop=Kelda,960x864 "$GAME_EXE"
else
    echo "[Erro] O jogo não foi encontrado no volume persistente."
    echo "[Erro] Certifique-se de que instalou no caminho padrão (C:\Program Files...)"
    # Se não achar, abre o explorador de arquivos para você localizar o .exe manualmente
    exec wine explorer /desktop=Debug,960x864 winefile
fi