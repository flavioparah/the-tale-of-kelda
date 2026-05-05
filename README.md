# The Tale of Kelda — Wine + noVNC no Coolify

Roda `The Tale of Kelda - Beta.exe` (MonoGame) via Wine + Mono
em um container Docker, acessível pelo browser via noVNC.

## Stack

```
Wine + Mono (roda o .exe MonoGame)
  └─ Xvfb (display virtual)
       └─ x11vnc (captura o display)
            └─ noVNC (serve via WebSocket no browser)
                  └─ Coolify (HTTPS, porta 8080)
```

## Estrutura do repositório

```
/                              ← raiz do git
├── Dockerfile
├── docker-compose.yml
├── supervisord.conf
├── startup.sh
├── Info.plist
├── MacOS/
├── MonoBundle/                ← .exe e DLLs ficam aqui
│   ├── The Tale of Kelda - Beta.exe
│   ├── MonoGame.Framework.dll
│   ├── OpenTK.dll
│   ├── LibSXNA.dll
│   ├── Tao.Sdl.dll
│   └── ...
└── Resources/                 ← assets do jogo
```

> O Dockerfile usa `COPY . /home/kelda/game/` — copia tudo da raiz,
> mantendo a estrutura exata acima.

## Deploy no Coolify

1. Commite Dockerfile, docker-compose.yml, supervisord.conf e startup.sh na raiz do repo
2. No Coolify: Application → Dockerfile → aponte para o repo
3. Porta exposta: `8080`
4. Configure domínio → HTTPS → Deploy

## Acesse o jogo

```
https://seu-dominio.com/vnc.html?autoconnect=true&resize=scale
```

Aguarde ~60s na primeira inicialização (Wine cria o prefix).

## Teste local

```bash
docker compose up --build
# http://localhost:8080/vnc.html?autoconnect=true&resize=scale
```

## Troubleshooting

**Tela preta** — aguarde 60s, é o Wine inicializando.

**Erro de DLL/Mono** — rode dentro do container para ver o erro exato:
```bash
docker exec -it <container> bash
cd /home/kelda/game/MonoBundle
wine "The Tale of Kelda - Beta.exe"
```

**SDL não encontrado** — já instalado como `libsdl2-2.0-0:i386` no Dockerfile.
