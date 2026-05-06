#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all
export LIBGL_ALWAYS_SOFTWARE=1

echo "[SISTEMA] Iniciando e corrigindo permissões..."
chown -R kelda:kelda /home/kelda/.wine 2>/dev/null

# Aguarda o servidor gráfico ficar pronto
while ! xdpyinfo -display :1 >/dev/null 2>&1; do
    sleep 2
done

# Inicia o gerenciador de janelas
sudo -u kelda openbox &
sleep 2

# Instala o Mono (suporte .NET) se ele ainda não estiver no volume persistente
if [ ! -d "/home/kelda/.wine/drive_c/windows/Microsoft.NET" ]; then
    echo "[SISTEMA] Instalando Wine Mono (pode levar 1 minuto)..."
    sudo -u kelda wine msiexec /i /usr/share/wine/mono/wine-mono-9.1.0-x86.msi /qn
fi

echo "[SISTEMA] Abrindo o jogo..."
# Caminho confirmado pelo seu teste manual no terminal
cd "/home/kelda/.wine/drive_c/Program Files/The Tale of Kelda - Beta"
sudo -u kelda wine "The Tale of Kelda.exe" &

# Mantém o container rodando infinitamente
while true; do
    sleep 100
done