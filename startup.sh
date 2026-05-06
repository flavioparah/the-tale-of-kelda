#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all
export LIBGL_ALWAYS_SOFTWARE=1

chown -R kelda:kelda /home/kelda/.wine 2>/dev/null

while ! xdpyinfo -display :1 >/dev/null 2>&1; do sleep 2; done

sudo -u kelda openbox &
sleep 2

# Instalação silenciosa do .NET
if [ ! -d "/home/kelda/.wine/drive_c/windows/Microsoft.NET" ]; then
    echo "[SISTEMA] Instalando suporte .NET..."
    sudo -u kelda wine msiexec /i /usr/share/wine/mono/wine-mono-9.1.0-x86.msi /qn
    sleep 5
fi

echo "[SISTEMA] Abrindo o jogo..."
cd "/home/kelda/.wine/drive_c/Program Files/The Tale of Kelda - Beta"
sudo -u kelda wine "The Tale of Kelda.exe" &

while true; do sleep 100; done