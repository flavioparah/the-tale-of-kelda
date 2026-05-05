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

RUN useradd -m -s /bin/bash kelda 2>/dev/null || true

# Copia repositório (MonoBundle/ + Resources/)
COPY --chown=kelda:kelda . /home/kelda/game/

# Scripts e configurações
COPY --chown=kelda:kelda startup.sh  /home/kelda/startup.sh
COPY --chown=kelda:kelda serve.py    /home/kelda/serve.py
COPY --chown=kelda:kelda index.html  /home/kelda/index.html
COPY supervisord.conf /etc/supervisor/conf.d/kelda.conf

RUN chmod +x /home/kelda/startup.sh /home/kelda/serve.py

EXPOSE 8080

USER kelda
WORKDIR /home/kelda

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/kelda.conf"]
