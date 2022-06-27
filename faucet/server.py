from http.server import SimpleHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
from socketserver import TCPServer
import traceback
import sys

from file_cache import FileCache
from bitcoin import Bitcoin


class Server(TCPServer):
    def __init__(
        self,
        server_address,
        server_port,
        rpc_destination,
        rpc_user,
        rpc_password,
    ):
        TCPServer.allow_reuse_address = True
        super().__init__((server_address, server_port), Server.MyHttpRequestHandler)
        self.file_cache = FileCache()
        self.bitcoin = Bitcoin(rpc_destination, rpc_user, rpc_password)

    def run(self):
        self.serve_forever()

    class MyHttpRequestHandler(SimpleHTTPRequestHandler):
        def return_html_page(self, data):
            self.send_response(200)
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Content-type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(data)

        def return_error_page(self, error_code, message):
            self.send_response(error_code)
            self.send_header("Content-type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(bytes(message, "utf8"))

        def return_redirect(self, location):
            self.send_response(301)
            self.send_header("Location", location)
            self.end_headers()

        def return_index_page(self):
            self.return_html_page(self.server.file_cache.get_file("index.html"))

        def do_POST(self):
            try:
                request = urlparse(self.path)
                site = request.path
                content_length = int(self.headers['Content-Length'])
                content = self.rfile.read(content_length)

                if site == "/send_to_address":
                    parameters = parse_qs(content)
                    amount = float(parameters[b"amount"][0])
                    address = parameters[b"address"][0]
                    self.server.bitcoin.send(address, amount)
                    self.return_redirect("/")
                else:
                    self.return_error_page(404, "Not found")
            except Exception as exception:
                exc_type, exc_value, exc_tb = sys.exc_info()
                message = "<br>".join(
                    traceback.format_exception(exc_type, exc_value, exc_tb)
                )
                self.return_error_page(500, message)

        def do_GET(self):
            try:
                request = urlparse(self.path)
                site = request.path
                parameters = parse_qs(request.query)

                if site == "/":
                    self.return_index_page()
                elif site == "/generate_block":
                    self.server.bitcoin.generate_blocks()
                    self.return_index_page()
                elif site == "/generate_block_if_needed":
                    self.server.bitcoin.generate_block_if_needed()
                    self.return_index_page()
                elif site == "/wasabi_wallet_backend":
                    log = open("/root/.walletwasabi/backend/Logs.txt", "rb").read()
                    self.return_html_page(log)
                elif site == "/wasabi_wallet_middleware":
                    log = open("/root/.walletwasabi/wabisabiclientlibrary/Logs.txt", "rb").read()
                    self.return_html_page(log)
                else:
                    self.return_error_page(404, "Not found")
            except Exception as exception:
                exc_type, exc_value, exc_tb = sys.exc_info()
                message = "<br>".join(
                    traceback.format_exception(exc_type, exc_value, exc_tb)
                )
                self.return_error_page(500, message)
