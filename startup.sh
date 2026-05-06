#!/bin/bash
export WINEPREFIX=/home/kelda/.wine
export WINEARCH=win32
export DISPLAY=:1
export WINEDEBUG=-all
export LIBGL_ALWAYS_SOFTWARE=1
export MESA_LOADER_DRIVER_OVERRIDE=swrast

echo "[SISTEMA] Iniciando hardware virtual..."
chown -R kelda:kelda /home/kelda/.wine 2>/dev/null

while ! xdpyinfo -display :1 >/dev/null 2>&1; do sleep 2; done

sudo -u kelda openbox &
sleep 2

# Instala o Mono silenciosamente se necessário
if [ ! -d "/home/kelda/.wine/drive_c/windows/Microsoft.NET" ]; then
    echo "[SISTEMA] Configurando ambiente .NET..."
    sudo -u kelda wine msiexec /i /usr/share/wine/mono/wine-mono-9.1.0-x86.msi /qn
    sleep 5
fi

echo "[SISTEMA] Executando The Tale of Kelda..."
cd "/home/kelda/.wine/drive_c/Program Files/The Tale of Kelda - Beta"

# O comando 'wine explorer /desktop' cria uma área de trabalho virtual 
# Isso impede que o jogo tente entrar em tela cheia e fique preto no navegador
sudo -u kelda wine explorer /desktop=Kelda,960x864 "The Tale of Kelda.exe" &

# Mantém o container vivo
while true; do
    sleep 100
done