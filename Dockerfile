FROM scottyhardy/docker-wine:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV SCREEN_WIDTH=960
ENV SCREEN_HEIGHT=864
ENV SCREEN_DEPTH=24
ENV VNC_PORT=5900
ENV NOVNC_PORT=8080

# Wine já vem na imagem base — instala apenas o que falta
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    python3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Usuário não-root
RUN useradd -m -s /bin/bash kelda 2>/dev/null || true

# Copia o repositório inteiro mantendo estrutura:
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
