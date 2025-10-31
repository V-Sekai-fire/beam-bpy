"""
Beam-BPy: Blender Python Erlang CNode interface for Beam
Connects Blender Python (bpy) to Beam as an Erlang CNode for RPC communication
"""

from .beam_server import BeamServer
from .erlang_variant import ErlangVariantEncoder, ErlangVariantDecoder

__version__ = "0.1.0"
__all__ = [
    "BeamServer",
    "ErlangVariantEncoder",
    "ErlangVariantDecoder",
]
