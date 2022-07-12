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


def surface(n_vertices: int, n_edges: int, n_faces: int) -> int:
    return _ccgeom_.surface(n_vertices, n_edges, n_faces)
