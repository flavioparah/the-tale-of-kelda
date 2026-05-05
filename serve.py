#!/usr/bin/env python3
"""
Servidor web minimalista que serve:
  /          -> index.html (layout customizado Game Boy)
  /vnc.html  -> proxy para noVNC interno (porta 6080)
  /*         -> arquivos estáticos do noVNC
"""
import http.server
import urllib.request
import urllib.error
import os
import socketserver

NOVNC_PORT = 6080
STATIC_DIR = "/home/kelda"
NOVNC_DIR  = "/usr/share/novnc"

class KeldaHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass  # silencia logs verbosos

    def do_GET(self):
        path = self.path.split("?")[0]

        # Raiz → nosso index.html customizado
        if path in ("/", "/index.html"):
            self._serve_file(os.path.join(STATIC_DIR, "index.html"), "text/html")
            return

        # Tudo que o noVNC precisa (vnc.html, core/, vendor/, etc.)
        novnc_path = os.path.join(NOVNC_DIR, path.lstrip("/"))
        if os.path.isfile(novnc_path):
            mime = self._mime(novnc_path)
            self._serve_file(novnc_path, mime)
            return

        self.send_error(404)

    def _serve_file(self, filepath, mime):
        try:
            with open(filepath, "rb") as f:
                data = f.read()
            self.send_response(200)
            self.send_header("Content-Type", mime)
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        except Exception:
            self.send_error(500)

    def _mime(self, path):
        ext = path.rsplit(".", 1)[-1].lower()
        return {
            "html": "text/html",
            "js":   "application/javascript",
            "css":  "text/css",
            "png":  "image/png",
            "ico":  "image/x-icon",
            "wasm": "application/wasm",
        }.get(ext, "application/octet-stream")

with socketserver.TCPServer(("", 8080), KeldaHandler) as httpd:
    httpd.serve_forever()
