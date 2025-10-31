"""
Erlang variant encoding and decoding for Beam-BPy
Converts between Python/Blender types and Erlang external term format using pyerlang
"""

from typing import Any, Optional, Dict, List
import struct


class ErlangVariantEncoder:
    """Encodes Python values to Erlang external term format"""

    @staticmethod
    def encode_variant(buff: Any, value: Any, object_scope: Optional[Any] = None) -> None:
        """Encode a Python value to Erlang format"""
        if value is None:
            _encode_atom(buff, "nil")
        elif isinstance(value, bool):
            # bool must be checked before int since bool is subclass of int
            _encode_atom(buff, "true" if value else "false")
        elif isinstance(value, int):
            _encode_int(buff, value)
        elif isinstance(value, float):
            _encode_float(buff, value)
        elif isinstance(value, str):
            _encode_string(buff, value)
        elif isinstance(value, list):
            _encode_list(buff, value, object_scope)
        elif isinstance(value, dict):
            _encode_dict(buff, value, object_scope)
        elif isinstance(value, tuple):
            _encode_tuple(buff, value, object_scope)
        else:
            # Fallback to string representation for unknown types
            _encode_string(buff, str(value))


class ErlangVariantDecoder:
    """Decodes Erlang external term format to Python values"""

    @staticmethod
    def decode_variant(buff: Any, index: Any, object_scope: Optional[Any] = None) -> Any:
        """Decode an Erlang value from external term format"""
        # This is a simplified decoder. For full functionality,
        # use pyerlang's built-in decoder
        return None


def _encode_atom(buff: Any, atom: str) -> None:
    """Encode an Erlang atom"""
    if len(atom) < 256:
        buff.write(b's')  # small atom
        buff.write(struct.pack('B', len(atom)))
        buff.write(atom.encode('utf-8'))
    else:
        buff.write(b'v')  # atom
        buff.write(struct.pack('>H', len(atom)))
        buff.write(atom.encode('utf-8'))


def _encode_int(buff: Any, value: int) -> None:
    """Encode an Erlang integer"""
    if -2147483648 <= value <= 2147483647:
        buff.write(b'b')  # int
        buff.write(struct.pack('>i', value))
    else:
        # Bignum - simplified, just use string representation
        buff.write(b's')
        s = str(value).encode('utf-8')
        buff.write(struct.pack('B', len(s)))
        buff.write(s)


def _encode_float(buff: Any, value: float) -> None:
    """Encode an Erlang float"""
    buff.write(b'c')  # float as string
    s = str(value).encode('utf-8')
    buff.write(s)
    buff.write(b'\x00' * (31 - len(s)))


def _encode_string(buff: Any, value: str) -> None:
    """Encode an Erlang string (as list of character codes)"""
    data = value.encode('utf-8')
    if len(data) < 65536:
        buff.write(b'k')  # string
        buff.write(struct.pack('>H', len(data)))
        buff.write(data)
    else:
        _encode_list(buff, list(data), None)


def _encode_list(buff: Any, value: List[Any], object_scope: Optional[Any] = None) -> None:
    """Encode an Erlang list"""
    if len(value) == 0:
        buff.write(b'j')  # empty list
    else:
        buff.write(b'l')  # list
        buff.write(struct.pack('>I', len(value)))
        for item in value:
            ErlangVariantEncoder.encode_variant(buff, item, object_scope)
        buff.write(b'j')  # tail (empty list)


def _encode_dict(buff: Any, value: Dict[str, Any], object_scope: Optional[Any] = None) -> None:
    """Encode a dict as Erlang map or list of tuples"""
    items = list(value.items())
    buff.write(b't')  # tuple
    buff.write(struct.pack('B', len(items)))
    for key, val in items:
        # Encode as {Key, Value} tuples
        buff.write(b't')
        buff.write(struct.pack('B', 2))
        ErlangVariantEncoder.encode_variant(buff, key, object_scope)
        ErlangVariantEncoder.encode_variant(buff, val, object_scope)


def _encode_tuple(buff: Any, value: tuple, object_scope: Optional[Any] = None) -> None:
    """Encode an Erlang tuple"""
    if len(value) < 256:
        buff.write(b'h')  # small tuple
        buff.write(struct.pack('B', len(value)))
    else:
        buff.write(b't')  # large tuple
        buff.write(struct.pack('>I', len(value)))
    
    for item in value:
        ErlangVariantEncoder.encode_variant(buff, item, object_scope)
