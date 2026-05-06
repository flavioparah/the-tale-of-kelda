FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV WINEPREFIX=/home/kelda/.wine
ENV WINEARCH=win32

RUN dpkg --add-architecture i386

# Instala dependências e o wget para baixar o suporte .NET
RUN apt-get update && apt-get install -y --no-install-recommends \
    wine wine32 wine64 xvfb x11vnc novnc websockify openbox \
    supervisor sudo wget x11-utils ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Baixa o Wine Mono (necessário para rodar jogos .NET/C#)
RUN mkdir -p /usr/share/wine/mono && \
    wget https://dl.winehq.org/wine/wine-mono/9.1.0/wine-mono-9.1.0-x86.msi -O /usr/share/wine/mono/wine-mono-9.1.0-x86.msi

RUN useradd -m -s /bin/bash kelda
RUN echo "kelda ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/kelda

# Copia os arquivos do projeto
COPY --chown=kelda:kelda . /home/kelda/game/
COPY --chown=kelda:kelda startup.sh /home/kelda/startup.sh
COPY supervisord.conf /etc/supervisor/conf.d/kelda.conf

# Ajuste do noVNC para evitar a "Lista de diretórios"
RUN cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html

RUN chmod +x /home/kelda/startup.sh
RUN mkdir -p /home/kelda/.wine && chown -R kelda:kelda /home/kelda/.wine

EXPOSE 8080

USER root

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/kelda.conf"]