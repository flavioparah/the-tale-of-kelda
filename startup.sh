#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all
export LIBGL_ALWAYS_SOFTWARE=1 

echo "[kelda] Assumindo controle do volume persistente..."
sudo chown -R kelda:kelda /home/kelda/.wine

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

openbox &
sleep 2

# Procura se o jogo já está no C: do Wine
GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -z "$GAME_EXE" ]; then
    echo "[kelda] Jogo não instalado. Iniciando instalação silenciosa..."
    wine "/home/kelda/game/Windows/TheTaleOfKelda.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART &
    
    echo "[kelda] Robô de cliques ativado (2 minutos de vigília)..."
    for i in {1..60}; do
        # Aperta Enter para pular telas de driver/licença
        xdotool key --delay 500 Return 2>/dev/null
        
        # Tenta achar o executável novamente
        GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)
        if [ -n "$GAME_EXE" ]; then
            echo "[kelda] Sucesso! Jogo encontrado em: $GAME_EXE"
            break
        fi
        sleep 2
    done
    wineserver -w
fi

if [ -n "$GAME_EXE" ]; then
    echo "[kelda] Abrindo o jogo no Desktop Virtual..."
    cd "$(dirname "$GAME_EXE")"
    # Abre o jogo e o & libera o script para seguir até o final
    wine explorer /desktop=Kelda,960x864 "$GAME_EXE" &
else
    echo "[kelda] O instalador não terminou a tempo. Verifique o Canvas."
fi

# ESSENCIAL: Mantém o processo do Supervisor ativo
echo "[kelda] Container estabilizado. Logs ativos..."
tail -f /dev/null