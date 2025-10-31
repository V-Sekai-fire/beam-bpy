"""
BeamServer: Erlang CNode server for Blender Python
Manages connections to Beam/Erlang and handles RPC messages
"""

import logging
import socket
import select
import threading
import time
from typing import Optional, Callable, Any, Dict
from queue import Queue
import struct

logger = logging.getLogger(__name__)


class BeamServer:
    """
    Erlang CNode server that connects Blender Python to Beam
    Handles RPC calls from Erlang to Python and vice versa
    """

    def __init__(
        self,
        node_name: str = "beam_bpy",
        cookie: str = "beam_bpy_cookie",
        host: str = "localhost",
        port: int = 0,  # 0 means let OS choose
    ):
        """
        Initialize the BeamServer CNode

        Args:
            node_name: Name of this CNode (e.g., "beam_bpy")
            cookie: Erlang cookie for authentication
            host: Host to bind to (default: localhost)
            port: Port to listen on (0 = auto-select)
        """
        self.node_name = node_name
        self.cookie = cookie
        self.host = host
        self.port = port

        self.listen_fd: Optional[socket.socket] = None
        self.client_fd: Optional[socket.socket] = None
        self.client_address: Optional[tuple] = None

        self.is_running = False
        self.server_thread: Optional[threading.Thread] = None
        self._lock = threading.Lock()

        # RPC handlers registry
        self.handlers: Dict[str, Callable[[Any], Any]] = {}

        # Message queue for handling async messages
        self.message_queue: Queue = Queue()

    def register_handler(self, function_name: str, handler: Callable[[Any], Any]) -> None:
        """Register an RPC handler function"""
        with self._lock:
            self.handlers[function_name] = handler
            logger.debug(f"Registered RPC handler: {function_name}")

    def init(self) -> bool:
        """Initialize and start the Erlang CNode server"""
        try:
            logger.info(f"Initializing Erlang CNode: {self.node_name}")

            # Create listening socket
            self.listen_fd = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.listen_fd.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.listen_fd.bind((self.host, self.port))
            self.listen_fd.listen(1)

            # Get assigned port
            _, assigned_port = self.listen_fd.getsockname()
            self.port = assigned_port

            logger.info(
                f"Erlang CNode initialized: {self.node_name} on {self.host}:{self.port}"
            )
            logger.info(f"Cookie: {self.cookie}")

            return True

        except Exception as e:
            logger.error(f"Failed to initialize Erlang CNode: {e}")
            self.finish()
            return False

    def start(self) -> bool:
        """Start the server in a background thread"""
        if self.is_running:
            logger.warning("Server is already running")
            return False

        if self.listen_fd is None:
            if not self.init():
                return False

        self.is_running = True
        self.server_thread = threading.Thread(target=self._run_loop, daemon=False)
        self.server_thread.start()

        logger.info("Beam server started")
        return True

    def stop(self) -> None:
        """Stop the server"""
        self.is_running = False
        if self.server_thread:
            self.server_thread.join(timeout=5.0)
        self.finish()
        logger.info("Beam server stopped")

    def finish(self) -> None:
        """Clean up resources"""
        if self.client_fd:
            try:
                self.client_fd.close()
            except Exception:
                pass
            self.client_fd = None

        if self.listen_fd:
            try:
                self.listen_fd.close()
            except Exception:
                pass
            self.listen_fd = None

    def _run_loop(self) -> None:
        """Main event loop for the server"""
        logger.debug("Beam server loop started")

        while self.is_running:
            try:
                # Handle new connections
                if self.client_fd is None and self.listen_fd:
                    readable, _, _ = select.select([self.listen_fd], [], [], 0.5)
                    if readable:
                        try:
                            conn, addr = self.listen_fd.accept()
                            self.client_fd = conn
                            self.client_address = addr
                            logger.info(f"Accepted connection from {addr}")
                        except Exception as e:
                            logger.error(f"Error accepting connection: {e}")

                # Handle messages from existing connection
                if self.client_fd:
                    readable, _, _ = select.select([self.client_fd], [], [], 0.5)
                    if readable:
                        try:
                            self._handle_client_message()
                        except Exception as e:
                            logger.error(f"Error handling client message: {e}")
                            if self.client_fd:
                                self.client_fd.close()
                                self.client_fd = None

            except Exception as e:
                logger.error(f"Error in server loop: {e}")
                time.sleep(0.1)

        logger.debug("Beam server loop ended")

    def _handle_client_message(self) -> None:
        """Handle incoming message from Erlang client"""
        if not self.client_fd:
            return

        try:
            # Read message header (format: 4-byte length + data)
            header = self.client_fd.recv(4)
            if not header or len(header) < 4:
                logger.warning("Client disconnected")
                self.client_fd.close()
                self.client_fd = None
                return

            msg_len = struct.unpack(">I", header)[0]
            if msg_len > 1000000:  # Safety check: max 1MB messages
                logger.error(f"Message too large: {msg_len}")
                return

            # Read message body
            data = b""
            while len(data) < msg_len:
                chunk = self.client_fd.recv(msg_len - len(data))
                if not chunk:
                    logger.warning("Client disconnected while reading message")
                    self.client_fd.close()
                    self.client_fd = None
                    return
                data += chunk

            # Process message
            self._process_rpc_message(data)

        except Exception as e:
            logger.error(f"Error reading message: {e}")

    def _process_rpc_message(self, data: bytes) -> None:
        """Process an incoming RPC message"""
        try:
            # Parse message (simplified format: "{function_name, [args...]}")
            msg_str = data.decode("utf-8")
            logger.debug(f"Received message: {msg_str}")

            # Call appropriate handler
            # Format: "function_name(arg1, arg2, ...)"
            if "(" in msg_str and ")" in msg_str:
                func_name = msg_str[: msg_str.index("(")].strip()
                args_str = msg_str[msg_str.index("(") + 1 : msg_str.rindex(")")].strip()

                with self._lock:
                    if func_name in self.handlers:
                        handler = self.handlers[func_name]
                        # Parse arguments (simplified - just pass the raw args string)
                        result = handler(args_str)
                        self._send_response(result)
                    else:
                        logger.error(f"Unknown RPC function: {func_name}")
                        self._send_error(f"Unknown function: {func_name}")
            else:
                logger.error(f"Invalid message format: {msg_str}")
                self._send_error("Invalid message format")

        except Exception as e:
            logger.error(f"Error processing RPC message: {e}")
            self._send_error(str(e))

    def _send_response(self, result: Any) -> None:
        """Send response back to Erlang"""
        try:
            if not self.client_fd:
                return

            response = str(result).encode("utf-8")
            header = struct.pack(">I", len(response))
            self.client_fd.sendall(header + response)

        except Exception as e:
            logger.error(f"Error sending response: {e}")

    def _send_error(self, error_msg: str) -> None:
        """Send error response back to Erlang"""
        try:
            if not self.client_fd:
                return

            error = f"{{error, '{error_msg}'}}".encode("utf-8")
            header = struct.pack(">I", len(error))
            self.client_fd.sendall(header + error)

        except Exception as e:
            logger.error(f"Error sending error response: {e}")

    def is_initialized(self) -> bool:
        """Check if server is initialized"""
        return self.listen_fd is not None

    def is_connected(self) -> bool:
        """Check if client is connected"""
        return self.client_fd is not None

    def get_address(self) -> str:
        """Get server address"""
        return f"{self.node_name}@{self.host}:{self.port}"


# Singleton instance
_singleton: Optional[BeamServer] = None
_singleton_lock = threading.Lock()


def get_beam_server() -> BeamServer:
    """Get or create the singleton BeamServer instance"""
    global _singleton
    if _singleton is None:
        with _singleton_lock:
            if _singleton is None:
                _singleton = BeamServer()
    return _singleton
