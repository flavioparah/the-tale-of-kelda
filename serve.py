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

NOVNC_DIRS = ["/usr/share/novnc", "/opt/novnc", "/usr/local/share/novnc"]
NOVNC_DIR = next((d for d in NOVNC_DIRS if os.path.isdir(d)), None)
INTERNAL_NOVNC = "http://localhost:6080"

class KeldaHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def do_GET(self):
        raw_path = self.path
        path = raw_path.split("?")[0].rstrip("/") or "/"
        qs = raw_path.split("?", 1)[1] if "?" in raw_path else ""

        # Página principal customizada
        if path in ("/", "/index.html"):
            self._serve_file("/home/kelda/index.html", "text/html; charset=utf-8")
            return

        # Proxy tudo o mais para o noVNC interno
        target_url = INTERNAL_NOVNC + raw_path
        try:
            req = urllib.request.Request(target_url)
            with urllib.request.urlopen(req, timeout=5) as resp:
                data = resp.read()
                self.send_response(resp.status)
                for key, val in resp.headers.items():
                    if key.lower() not in ("transfer-encoding", "connection"):
                        self.send_header(key, val)
                self.end_headers()
                self.wfile.write(data)
        except Exception:
            # fallback: serve arquivo estático local se existir
            if NOVNC_DIR:
                local = os.path.join(NOVNC_DIR, path.lstrip("/"))
                if os.path.isfile(local):
                    self._serve_file(local, self._mime(local))
                    return
            self.send_error(502, f"noVNC proxy error for {path}")

    def _serve_file(self, filepath, mime):
        try:
            with open(filepath, "rb") as f:
                data = f.read()
            self.send_response(200)
            self.send_header("Content-Type", mime)
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        except FileNotFoundError:
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
with socketserver.TCPServer(("", 8080), KeldaHandler) as httpd:
    print(f"[serve] noVNC dir: {NOVNC_DIR}")
    print("[serve] Proxying noVNC from :6080")
    print("[serve] Listening on :8080")
    httpd.serve_forever()
