FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720
ENV SCREEN_DEPTH=24
ENV VNC_PORT=5900
ENV NOVNC_PORT=8080

# Suporte i386 para Wine 32-bit
RUN dpkg --add-architecture i386

# Repositório oficial WineHQ
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    gnupg2 \
    wget \
    ca-certificates \
  && mkdir -p /etc/apt/keyrings \
  && wget -qO /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
  && echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ jammy main" \
     > /etc/apt/sources.list.d/winehq.list \
  && apt-get update

# Wine stable + dependências de display + SDL2 + OpenAL (MonoGame)
RUN apt-get install -y --install-recommends winehq-stable \
  && apt-get install -y --no-install-recommends \
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
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    mono-runtime \
    xdotool \
    curl \
    python3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Usuário não-root
RUN useradd -m -s /bin/bash kelda

# Copia o repositório inteiro mantendo estrutura original:
#   MonoBundle/The Tale of Kelda - Beta.exe
#   MonoBundle/*.dll
#   Resources/
COPY --chown=kelda:kelda . /home/kelda/game/

COPY --chown=kelda:kelda startup.sh /home/kelda/startup.sh
RUN chmod +x /home/kelda/startup.sh

COPY supervisord.conf /etc/supervisor/conf.d/kelda.conf

EXPOSE 8080

USER kelda
WORKDIR /home/kelda

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/kelda.conf"]
