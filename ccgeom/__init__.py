import ctypes
import site
import sys
import os


_ccgeom_ = None
version = '0.0.0'

if sys.platform == 'win32':
    ext = 'dll'
    flib = 'libccgeom.%s.%s' % (version, ext)
elif sys.platform == 'darwin':
    ext = 'dylib'
    flib = 'libccgeom.%s.%s' % (version, ext)
else:
    ext = 'so'
    flib = 'libccgeom.%s.%s' % (ext, version)

pkgs = site.getsitepackages()
for pkg in pkgs:
    pth = os.path.join(pkg, flib)
    if os.path.exists(pth):
        _ccgeom_ = ctypes.CDLL(pth)
        break
if not _ccgeom_:
    pth = os.path.join('zig-out', 'lib', flib)
    print(pth)
    if os.path.exists(pth):
        _ccgeom_ = ctypes.CDLL(pth)
    else:
        raise Exception('can not locate %s' % flib)


_ccgeom_.begin.argtypes = []
_ccgeom_.begin.restype = ctypes.c_uint

_ccgeom_.commit.argtypes = []
_ccgeom_.commit.restype = ctypes.c_uint

_ccgeom_.rollback.argtypes = []
_ccgeom_.rollback.restype = ctypes.c_uint

_ccgeom_.build_surface.argtypes = [ctypes.c_uint, ctypes.c_uint, ctypes.c_uint]
_ccgeom_.build_surface.restype = ctypes.c_uint

_ccgeom_.build_vertice.argtypes = [ctypes.c_double, ctypes.c_double, ctypes.c_double]
_ccgeom_.build_vertice.restype = ctypes.c_uint

_ccgeom_.build_edge.argtypes = [ctypes.c_uint, ctypes.c_uint]
_ccgeom_.build_edge.restype = ctypes.c_uint

_ccgeom_.build_halfedge.argtypes = [ctypes.c_uint, ctypes.c_uint, ctypes.c_uint, ctypes.c_uint]
_ccgeom_.build_halfedge.restype = ctypes.c_uint


def begin() -> int:
    return _ccgeom_.begin()


def commit() -> int:
    return _ccgeom_.commit()


def rollback() -> int:
    return _ccgeom_.rollback()


def build_surface(n_vertices: int, n_edges: int, n_faces: int) -> int:
    return _ccgeom_.build_surface(n_vertices, n_edges, n_faces)


def build_vertice(x: float, y: float, z: float) -> int:
    return _ccgeom_.build_vertice(x, y, z)


def build_edge(source: int, target: int) -> int:
    return _ccgeom_.build_edge(source, target)


def build_halfedge(source: int, target: int, prevhe: int, nexthe: int) -> int:
    return _ccgeom_.build_halfedge(source, target, prevhe, nexthe)


def build_face3(vert1: int, vert2: int, vert3: int) -> int:
    return _ccgeom_.build_face3(vert1, vert2, vert3)

