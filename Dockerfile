FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV SCREEN_WIDTH=960
ENV SCREEN_HEIGHT=864
ENV SCREEN_DEPTH=24
ENV VNC_PORT=5900

# i386 para Wine 32-bit
RUN dpkg --add-architecture i386

# Instala tudo em um único RUN para maximizar cache
# Usa timeout e retry para lidar com lentidão de rede
RUN apt-get update -o Acquire::Retries=5 \
  && apt-get install -y --no-install-recommends \
    # Wine via pacote simples (sem repo externo — evita lentidão)
    wine \
    wine32 \
    wine64 \
    # Display virtual
    xvfb \
    x11vnc \
    # noVNC
    novnc \
    websockify \
    # WM mínimo
    openbox \
    # Orquestrador
    supervisor \
    # MonoGame deps
    libsdl2-2.0-0 \
    libsdl2-2.0-0:i386 \
    libopenal1 \
    libopenal1:i386 \
    libgl1-mesa-dri \
    # Mono runtime
    mono-runtime \
    # Utils
    xdotool \
    python3 \
    ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Usuário que vai rodar tudo
RUN useradd -m -s /bin/bash kelda

# Copia o repositório inteiro
# Estrutura esperada no repo:
#   MacOS/MonoBundle/The Tale of Kelda - Beta.exe
#   MacOS/MonoBundle/*.dll
#   Recursos/Content/...
COPY --chown=kelda:kelda . /home/kelda/game/

COPY --chown=kelda:kelda startup.sh   /home/kelda/startup.sh
COPY --chown=kelda:kelda serve.py     /home/kelda/serve.py
COPY --chown=kelda:kelda index.html   /home/kelda/index.html
COPY supervisord.conf /etc/supervisor/conf.d/kelda.conf

RUN chmod +x /home/kelda/startup.sh

EXPOSE 8080

USER kelda
WORKDIR /home/kelda

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/kelda.conf"]
