#!/usr/bin/env python3
"""
Servidor na porta 8080 que:
  GET /          -> index.html customizado
  GET /static/*  -> arquivos estáticos do noVNC (core/, vendor/, etc.)
  GET /vnc.html  -> página do noVNC
  WebSocket /*   -> proxy para o websockify/noVNC na porta 6080
"""
import http.server
import os
import socketserver
import urllib.request
import socket
import select

NOVNC_DIRS = ["/usr/share/novnc", "/opt/novnc", "/usr/local/share/novnc"]
NOVNC_DIR = next((d for d in NOVNC_DIRS if os.path.isdir(d)), None)
INTERNAL_NOVNC_HOST = "localhost"
INTERNAL_NOVNC_PORT = 6080

class KeldaHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def do_GET(self):
        # Se for uma requisição de Upgrade (WebSocket), fazemos o tunelamento TCP
        if self.headers.get('Upgrade', '').lower() == 'websocket':
            self._proxy_websocket()
            return

        raw_path = self.path
        path = raw_path.split("?")[0].rstrip("/") or "/"
        
        # Página principal customizada
        if path in ("/", "/index.html"):
            self._serve_file("/home/kelda/index.html", "text/html; charset=utf-8")
            return

        # Proxy HTTP para o noVNC interno
        target_url = f"http://{INTERNAL_NOVNC_HOST}:{INTERNAL_NOVNC_PORT}{raw_path}"
        try:
            req = urllib.request.Request(target_url)
            # Copia cabeçalhos relevantes da requisição original
            for key, val in self.headers.items():
                if key.lower() not in ("host", "connection", "upgrade"):
                    req.add_header(key, val)
            
            with urllib.request.urlopen(req, timeout=5) as resp:
                self.send_response(resp.status)
                for key, val in resp.headers.items():
                    if key.lower() not in ("transfer-encoding", "connection"):
                        self.send_header(key, val)
                self.end_headers()
                self.wfile.write(resp.read())
        except Exception:
            # fallback: serve arquivo estático local se existir
            if NOVNC_DIR:
                local = os.path.join(NOVNC_DIR, path.lstrip("/"))
                if os.path.isfile(local):
                    self._serve_file(local, self._mime(local))
                    return
            self.send_error(502, f"noVNC proxy error for {path}")

    def _proxy_websocket(self):
        """Tunelamento TCP simples para WebSockets"""
        try:
            # Conecta ao websockify interno
            remote_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            remote_sock.connect((INTERNAL_NOVNC_HOST, INTERNAL_NOVNC_PORT))
            
            # Envia a requisição inicial de handshake para o backend
            # Reconstruímos a requisição mínima necessária
            handshake = f"GET {self.path} HTTP/1.1\r\n"
            for key, val in self.headers.items():
                handshake += f"{key}: {val}\r\n"
            handshake += "\r\n"
            remote_sock.sendall(handshake.encode())

            # Informa ao cliente que o tunelamento começou (não enviamos 101 aqui, 
            # pois o backend enviará o 101 através do túnel)
            
            # Loop de transferência bidirecional
            self._tunnel(self.connection, remote_sock)
        except Exception as e:
            print(f"[serve] WebSocket proxy error: {e}")
            self.send_error(502)

    def _tunnel(self, client_sock, remote_sock):
        client_sock.setblocking(0)
        remote_sock.setblocking(0)
        sockets = [client_sock, remote_sock]
        
        try:
            while True:
                readable, _, errorable = select.select(sockets, [], sockets, 60)
                if errorable:
                    break
                for s in readable:
                    data = s.recv(8192)
                    if not data:
                        return
                    target = remote_sock if s is client_sock else client_sock
                    target.sendall(data)
        except Exception:
            pass
        finally:
            remote_sock.close()

    def _serve_file(self, filepath, mime):
        try:
            if not os.path.exists(filepath):
                # Se o arquivo não existe no caminho absoluto, tenta relativo ao repo
                alt_path = os.path.join(os.getcwd(), os.path.basename(filepath))
                if os.path.exists(alt_path):
                    filepath = alt_path
            
            with open(filepath, "rb") as f:
                data = f.read()
            self.send_response(200)
            self.send_header("Content-Type", mime)
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        except Exception:
            self.send_error(404)

    def _mime(self, path):
        ext = path.rsplit(".", 1)[-1].lower()
        return {
            "html": "text/html; charset=utf-8",
            "js":   "application/javascript",
            "css":  "text/css",
            "png":  "image/png",
            "ico":  "image/x-icon",
            "wasm": "application/wasm",
        }.get(ext, "application/octet-stream")

socketserver.TCPServer.allow_reuse_address = True
# Usar ThreadingMixIn para permitir múltiplas conexões (necessário para o túnel WebSocket não travar o servidor)
class ThreadedHTTPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    pass

with ThreadedHTTPServer(("", 8080), KeldaHandler) as httpd:
    print(f"[serve] noVNC dir: {NOVNC_DIR}")
    print(f"[serve] Proxying noVNC from {INTERNAL_NOVNC_HOST}:{INTERNAL_NOVNC_PORT}")
    print("[serve] Listening on :8080")
    httpd.serve_forever()
