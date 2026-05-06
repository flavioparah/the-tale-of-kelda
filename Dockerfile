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

# Adicionado 'sudo' na lista de instalação
RUN apt-get update && apt-get install -y --no-install-recommends \
    wine wine32 wine64 xvfb x11vnc novnc websockify openbox \
    supervisor libsdl2-2.0-0 libsdl2-2.0-0:i386 libopenal1 \
    libopenal1:i386 libgl1-mesa-dri mono-runtime xdotool \
    python3 ca-certificates x11-utils sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash kelda

# Permite que o usuário kelda use sudo sem senha (necessário para o volume persistente)
RUN echo "kelda ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/kelda

COPY --chown=kelda:kelda . /home/kelda/game/
COPY --chown=kelda:kelda index.html /usr/share/novnc/index.html
COPY --chown=kelda:kelda startup.sh /home/kelda/startup.sh
COPY supervisord.conf /etc/supervisor/conf.d/kelda.conf

RUN chmod +x /home/kelda/startup.sh

# Garante a existência da pasta e permissões iniciais
RUN mkdir -p /home/kelda/.wine && chown -R kelda:kelda /home/kelda/.wine

EXPOSE 8080
USER kelda

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/kelda.conf"]