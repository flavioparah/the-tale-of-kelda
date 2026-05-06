#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all
export LIBGL_ALWAYS_SOFTWARE=1 

echo "[kelda] Corrigindo permissões do volume persistente..."
# O sudo aqui é vital para o usuário 'kelda' assumir o volume criado pelo Coolify/Docker
sudo chown -R kelda:kelda /home/kelda/.wine

echo "[kelda] Aguardando Xvfb iniciar..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

# Inicia o gerenciador de janelas
openbox &
sleep 2

# Busca pelo executável do jogo instalado
GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -z "$GAME_EXE" ]; then
    echo "[kelda] Jogo não encontrado. Iniciando instalador..."
    # Roda o instalador em background
    wine "/home/kelda/game/Windows/TheTaleOfKelda.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART &
    
    echo "[kelda] Monitorando janelas e forçando 'Enter'..."
    for i in {1..90}; do
        # Envia Enter para fechar a janela do OpenAL e outras que travam o processo
        xdotool key --delay 500 Return 2>/dev/null
        
        # Verifica se o jogo foi criado na pasta de destino
        GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)
        if [ -n "$GAME_EXE" ]; then
            echo "[kelda] Instalação detectada com sucesso!"
            break
        fi
        sleep 2
    done
    wineserver -w
fi

if [ -n "$GAME_EXE" ]; then
    echo "[kelda] Lançando o jogo: $GAME_EXE"
    cd "$(dirname "$GAME_EXE")"
    # Abre o jogo dentro de um desktop virtual para garantir visibilidade no Canvas
    wine explorer /desktop=Kelda,960x864 "$GAME_EXE" &
else
    echo "[kelda] AVISO: O jogo não foi instalado corretamente."
fi

# Mantém o script (e o processo kelda no supervisor) vivo para sempre
echo "[kelda] Sistema operacional pronto. Mantendo container ativo..."
tail -f /dev/null