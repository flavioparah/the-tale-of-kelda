#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all 

echo "[kelda] Limpando ambiente..."
wineserver -k || true

echo "[kelda] Aguardando Xvfb..."
for i in $(seq 1 30); do
  xdpyinfo -display :1 >/dev/null 2>&1 && break
  sleep 1
done

openbox &
sleep 2

GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)

if [ -z "$GAME_EXE" ]; then
    echo "[kelda] Instalando dependências silenciosamente..."
    # Desativa instaladores de HTML/.NET que travam o boot
    export WINEDLLOVERRIDES="mscoree,mshtml="
    
    echo "[kelda] Iniciando instalador principal..."
    wine "/home/kelda/game/Windows/TheTaleOfKelda.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART &
    
    # --- TRUQUE PARA PULAR A JANELA DA IMAGEM ---
    echo "[kelda] Monitorando janelas de licença (OpenAL)..."
    for i in $(seq 1 20); do
        # Procura janelas com "OpenAL", "License" ou "Installer" e envia um "Enter"
        xdotool search --name "OpenAL" windowactivate key Return 2>/dev/null || true
        xdotool search --name "License" windowactivate key Return 2>/dev/null || true
        xdotool search --name "Installer" windowactivate key Return 2>/dev/null || true
        sleep 3
        # Se o instalador principal sumir, a gente para o loop
        pgrep -i "TheTaleOfKelda" > /dev/null || break
    done

    echo "[kelda] Finalizando instalação..."
    wineserver -w
    GAME_EXE=$(find /home/kelda/.wine/drive_c -name "The Tale of Kelda.exe" | head -n 1)
fi

if [ -n "$GAME_EXE" ]; then
    echo "[kelda] Jogo pronto! Abrindo..."
    cd "$(dirname "$GAME_EXE")"
    # Inicia direto no modo desktop virtual para evitar que o OpenAL tente abrir janelas de novo
    exec wine explorer /desktop=Kelda,960x864 "The Tale of Kelda.exe"
else
    echo "[kelda] Erro: Jogo não instalado."
    exit 1
fi