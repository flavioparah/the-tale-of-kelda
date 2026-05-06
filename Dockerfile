FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV SCREEN_WIDTH=960
ENV SCREEN_HEIGHT=864
ENV SCREEN_DEPTH=24
ENV VNC_PORT=5900
ENV WINEPREFIX=/home/kelda/.wine
ENV WINEARCH=win32

RUN dpkg --add-architecture i386

RUN apt-get update -o Acquire::Retries=5 \
  && apt-get install -y --no-install-recommends \
    wine \
    wine32 \
    wine64 \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    openbox \
    supervisor \
    libsdl2-2.0-0 \
    libsdl2-2.0-0:i386 \
    libopenal1 \
    libopenal1:i386 \
    libgl1-mesa-dri \
    mono-runtime \
    xdotool \
    python3 \
    ca-certificates \
    x11-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash kelda

# Copia os arquivos do jogo e scripts
COPY --chown=kelda:kelda . /home/kelda/game/
COPY --chown=kelda:kelda index.html /usr/share/novnc/index.html
COPY --chown=kelda:kelda startup.sh /home/kelda/startup.sh
COPY supervisord.conf /etc/supervisor/conf.d/kelda.conf

RUN chmod +x /home/kelda/startup.sh

# --- INSTALAÇÃO PRÉVIA DO JOGO ---
USER kelda
WORKDIR /home/kelda

# Inicializa o Wine e instala o jogo durante o build
RUN Xvfb :99 -screen 0 1024x768x16 & \
    sleep 2 && \
    DISPLAY=:99 wine /home/kelda/game/Windows/TheTaleOfKelda.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART && \
    echo "Aguardando instalador finalizar..." && \
    while pgrep -f "TheTaleOfKelda.exe" > /dev/null; do sleep 2; done && \
    sleep 5

# Limpeza: remove o instalador para economizar espaço na imagem
RUN rm /home/kelda/game/Windows/TheTaleOfKelda.exe

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/kelda.conf"]