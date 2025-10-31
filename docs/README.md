# Beam-BPy

Blender Python (bpy) Erlang CNode interface for connecting to Beam/OTP systems.

This project implements an Erlang CNode (C-Node) in pure Python, allowing any Erlang/Elixir system to communicate with Python applications through RPC calls. It follows the architecture pattern from the Godot BeamServer implementation.

## Architecture

### Components

- **BeamServer**: Main CNode server that listens for Erlang connections and handles RPC messages
- **ErlangVariantEncoder/Decoder**: Encodes/decodes data between Python and Erlang external term format
- **Message Handler Registry**: Routes RPC calls to registered handler functions (language-agnostic)

### How It Works

1. **Initialization**: BeamServer initializes as an Erlang CNode with configurable node name and cookie
2. **Connection**: Waits for incoming connections from Beam/Erlang/Elixir nodes
3. **Message Processing**: Receives RPC messages in a threaded non-blocking event loop
4. **Handler Dispatch**: Routes messages to dynamically registered handler functions
5. **Response**: Sends results back to Erlang/Elixir clients

## Installation

### Requirements

- Python 3.11+
- Blender 4.5.2 with bpy (optional - beam_bpy can work with any Python)
- UV package manager

### Setup

```bash
cd <project-root>

# Install with UV
uv pip install -e .

# Or install dev dependencies
uv pip install -e ".[dev]"
```

## Usage

### Generic RPC Handler API

beam_bpy is **language-agnostic** - it provides a generic handler registry that works with any client:

- **Python**: Register handlers by calling `server.register_handler(name, function)`
- **Elixir/Erlang**: Call any registered handler using Erlang distribution protocol
- **Extensible**: Applications register their own handlers at runtime

### Python Server Example

```python
import logging
from beam_bpy import BeamServer

# Setup logging
logging.basicConfig(level=logging.INFO)

# Create server instance
server = BeamServer(
    node_name="beam_bpy",
    cookie="beam_bpy_cookie",
    host="localhost",
    port=0  # Auto-select port
)

# Register custom handlers (any Python function)
def handle_ping(args: str) -> str:
    return "pong"

def handle_custom_operation(args: str) -> dict:
    return {"status": "processed", "data": args}

server.register_handler("ping", handle_ping)
server.register_handler("my_operation", handle_custom_operation)

# Start server
if server.start():
    print(f"Server started at {server.get_address()}")
    # Handlers now available to Elixir/Erlang clients via RPC
else:
    print("Failed to start server")
```

### Elixir Client Example

Any Elixir/Erlang code can call handlers registered on the beam_bpy server:

```elixir
# Connect to beam_bpy CNode
{:ok, _} = Node.start(:"elixir_app@127.0.0.1")
Node.set_cookie(:beam_bpy_cookie)
Node.connect(:"beam_bpy@127.0.0.1")

# Call any registered handler via Erlang RPC
# Handlers are identified by name, args are passed through
result = :rpc.call(:"beam_bpy@127.0.0.1", MyModule, :call_handler, ["ping", []])

# Or use standard Erlang distributed calls
response = :rpc.call(:"beam_bpy@127.0.0.1", BeamServer, :handle_rpc, ["my_operation", ["arg1", "arg2"]])
```

### With Blender

```python
import bpy
from beam_bpy import BeamServer

server = BeamServer()

# Register Blender-specific handlers
def create_object(args: str) -> dict:
    bpy.ops.mesh.primitive_cube_add()
    return {"status": "created"}

def list_objects(args: str) -> list:
    return [obj.name for obj in bpy.data.objects]

server.register_handler("create_object", create_object)
server.register_handler("list_objects", list_objects)

server.start()
# Now Elixir code can call these Blender operations via RPC
```

## Configuration

### Environment Variables

- `BPY_BEAM_NODE`: Override node name (default: `beam_bpy`)
- `BPY_BEAM_COOKIE`: Override cookie (default: `beam_bpy_cookie`)
- `BPY_BEAM_HOST`: Override host (default: `localhost`)
- `BPY_BEAM_PORT`: Override port (default: `0` - auto-select)

## Project Structure

```
beam-bpy/
├── pyproject.toml              # Project configuration
├── README.md                   # Documentation
├── AGENTS.md                   # AI agent guidance
├── beam_bpy/
│   ├── __init__.py            # Package exports
│   ├── beam_server.py         # Generic CNode server
│   └── erlang_variant.py      # Type encoding/decoding
├── test_client.exs            # Elixir connectivity test
├── test_integration.exs       # Elixir integration tests
├── test_simple.exs            # Handler tests
└── tests/
    └── __init__.py            # Python test package
```

## Testing

### Python Tests

```bash
cd <project-root>
uv run pytest tests/
```

### Elixir Tests

```bash
cd <project-root>

# Terminal 1: Start beam_bpy server
uv run python examples/basic_server.py

# Terminal 2: Run Elixir QA tests
elixir test_simple.exs      # Handler validation tests
elixir test_integration.exs # Integration tests
elixir test_client.exs      # Connectivity test
```

## Architecture (Godot BeamServer Approach)

beam_bpy follows the CNode architecture from Godot's BeamServer:

1. **Socket-based Communication**: Raw TCP sockets for Erlang connectivity
2. **Non-blocking Event Loop**: Select-based multiplexing for concurrent clients
3. **Handler Registry**: Dynamic function name → handler mapping
4. **Type Encoding**: Custom Erlang-compatible type encoding/decoding
5. **Thread Safety**: Mutex-protected state and handler access

### Key Design Principles

- **Generic**: No specialized handlers built-in (Blender-specific or otherwise)
- **Extensible**: Applications register their own handlers at runtime
- **Language-agnostic**: Python registers, Elixir/Erlang calls via standard RPC
- **Portable**: Pure Python implementation (no C++ dependencies)

## License

MIT License

## References

- [Godot BeamServer Implementation](https://github.com/godotengine/godot/blob/master/servers/beam_server.cpp)
- [Erlang Distribution Protocol](http://erlang.org/doc/apps/erts/erl_ext_dist.html)
- [Blender Python API](https://docs.blender.org/api/current/)
- [Elixir Node Communication](https://elixir-lang.org/docs/stable/elixir/Node.html)
