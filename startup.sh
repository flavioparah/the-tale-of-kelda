#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all
# Força o Wine a usar renderização por software se a GPU da VPS falhar
export LIBGL_ALWAYS_SOFTWARE=1 

echo "[kelda] Aguardando sistema de vídeo..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

openbox &
sleep 2

# Verifica se o jogo já existe no volume persistente
GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -z "$GAME_EXE" ]; then
    echo "[kelda] Volume vazio. Iniciando instalação limpa..."
    # Roda o instalador principal
    wine "/home/kelda/game/Windows/TheTaleOfKelda.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART &
    
    echo "[kelda] Robô de cliques ativado (aguardando janelas)..."
    # Loop de 3 minutos para garantir que passamos por todas as telas pretas/azuis
    for i in {1..90}; do
        # Envia Enter para fechar diálogos escondidos ou telas de licença
        xdotool key --delay 500 Return 2>/dev/null
        
        # Tenta achar o executável a cada ciclo
        GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)
        if [ -n "$GAME_EXE" ]; then
            echo "[kelda] Jogo instalado com sucesso!"
            break
        fi
        sleep 2
    done
    wineserver -w
fi

if [ -n "$GAME_EXE" ]; then
    echo "[kelda] Lançando jogo no Desktop Virtual..."
    cd "$(dirname "$GAME_EXE")"
    # O comando abaixo cria a janela que você verá no canvas
    exec wine explorer /desktop=Kelda,960x864 "$GAME_EXE"
else
    echo "[kelda] Erro crítico: O instalador falhou ou o volume está travado."
    exit 1
fi