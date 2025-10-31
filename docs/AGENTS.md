# AGENTS.md

This file provides guidance to AI agents and LLMs when working with beam-bpy.

## Project Overview

beam-bpy is a generic Erlang CNode connector for Python that enables Erlang/Elixir systems to communicate with Python applications through RPC calls. It follows the architecture pattern from Godot's BeamServer implementation.

### Core Concept

- **Python Backend**: Runs as Erlang CNode server with socket-based communication
- **Elixir/Erlang Frontend**: Any Elixir code can call handlers registered on beam-bpy
- **Generic Design**: No specialized handlers built-in - applications register handlers at runtime
- **Language-Agnostic**: Python backend, Elixir/Erlang frontend with standard RPC protocol

## Project Structure

```
beam-bpy/
├── README.md                   # Complete documentation
├── AGENTS.md                   # This file
├── pyproject.toml              # UV-managed project config
├── beam_bpy/
│   ├── __init__.py            # Package exports
│   ├── beam_server.py         # Generic CNode server implementation
│   └── erlang_variant.py      # Erlang type encoding/decoding
├── test_*.exs                 # Elixir QA test suites
└── tests/
    └── __init__.py            # Python test package
```

## Development Commands

```bash
# Project setup
cd <project-root>
uv pip install -e .            # Install project with dependencies
uv pip install -e ".[dev]"     # Install with dev dependencies

# Testing
elixir test_simple.exs         # Run 8 handler validation tests
elixir test_integration.exs    # Run ExUnit integration tests
elixir test_client.exs         # Run connectivity test

# Running the server
uv run python examples/basic_server.py  # Start beam-bpy server
```

## Architecture

### Components

1. **BeamServer** (`beam_bpy/beam_server.py`)
   - Main Erlang CNode server
   - Socket-based TCP communication
   - Non-blocking event loop using select() multiplexing
   - Dynamic handler registry for RPC dispatch
   - Thread-safe operations with mutex locks

2. **ErlangVariant** (`beam_bpy/erlang_variant.py`)
   - Type encoding/decoding between Python and Erlang
   - Supports: atoms, integers, floats, strings, lists, tuples, dicts

3. **Handler Registry**
   - Applications register handlers dynamically
   - Format: `server.register_handler(name, function)`
   - Handlers called via RPC from Erlang/Elixir

## Design Principles

- **Generic**: No Blender-specific or other specialized handlers built-in
- **Extensible**: Applications provide handlers at runtime
- **Language-Agnostic**: Python backend, Elixir/Erlang frontend
- **Portable**: Pure Python, no C++ dependencies
- **Thread-Safe**: Mutex-protected state and handler access

## Testing Approach

### Elixir QA Tests

- **test_simple.exs**: 8 handler validation tests - all passing ✓
- **test_integration.exs**: ExUnit integration test suite
- **test_client.exs**: Connectivity validator

## References

- [Godot BeamServer](https://github.com/godotengine/godot/blob/master/servers/beam_server.cpp)
- [Erlang Distribution Protocol](http://erlang.org/doc/apps/erts/erl_ext_dist.html)
- [Elixir Node Communication](https://elixir-lang.org/docs/stable/elixir/Node.html)
