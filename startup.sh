#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all

chown -R kelda:kelda /home/kelda/.wine

while ! xdpyinfo -display :1 >/dev/null 2>&1; do sleep 2; done
sudo -u kelda openbox &

# Instala o Mono que baixamos no Dockerfile de forma silenciosa
if [ ! -d "/home/kelda/.wine/drive_c/windows/Microsoft.NET" ]; then
    echo "[SISTEMA] Instalando suporte .NET (Wine Mono)..."
    sudo -u kelda wine msiexec /i /usr/share/wine/mono/wine-mono-9.1.0-x86.msi /qn
fi

echo "[SISTEMA] Iniciando o jogo..."
cd "/home/kelda/.wine/drive_c/Program Files/The Tale of Kelda - Beta"
sudo -u kelda wine "The Tale of Kelda.exe" &

while true; do sleep 100; done