import os
import sys
import shutil
import setuptools

from io import StringIO
from multiprocessing import Process, Queue

from setuptools.command.build_ext import build_ext
from setuptools.command.install_lib import install_lib


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


class TeeOut(StringIO):
    def write(self, s):
        StringIO.write(self, s)
        sys.__stdout__.write(s)


class TeeErr(StringIO):
    def write(self, s):
        StringIO.write(self, s)
        sys.__stderr__.write(s)


class ZigBuild(object):
    def run(self):
        queue = Queue()
        child = Process(target=self.spawn, args=(queue,))
        child.start()
        child.join()
        out = queue.get()
        err = queue.get()
        print(out)
        print(err)

    def spawn(self, queue):
        out = TeeOut()
        sys.stdout = out

        err = TeeErr()
        sys.stderr = err

        try:
            print(sys.argv)
            sys.argv.clear()
            sys.argv.append('')
            sys.argv.append('build')
            print(os.curdir)

            from ziglang import __main__
        finally:
            sys.stdout = sys.__stdout__
            sys.stderr = sys.__stderr__
            queue.put(out.getvalue())
            queue.put(err.getvalue())


if __name__ == '__main__':

    library = None

    with open("README.md", "r") as fh:
        long_description = fh.read()


    class CCGeomBuildExtension(build_ext):
        def run(self):
            ZigBuild().run()
            super(CCGeomBuildExtension, self).run()


    class CCGeomInstall(install_lib):
        def install(self):
            print(sys.argv)
            print(os.listdir())
            pth = os.path.join('zig-out', 'lib', flib)
            if not os.path.exists(pth):
                ZigBuild().run()
            print(os.listdir())
            print(os.listdir('zig-out'))
            print(os.listdir('zig-out/lib'))
            shutil.copy(pth, self.install_dir)
            super(CCGeomInstall, self).install()


    setuptools.setup(
        name="ccgeom",
        version=version,
        author="Mingli Yuan",
        author_email="mingli.yuan@gmail.com",
        description="ccgeom is a package providing facilities to explore computational conformal geometry",
        long_description=long_description,
        long_description_content_type="text/markdown",
        url="https://github.com/ccgeom/ccgeom",
        project_urls={
            'Documentation': 'https://github.com/ccgeom/ccgeom',
            'Source': 'https://github.com/ccgeom/ccgeom',
            'Tracker': 'https://github.com/ccgeom/ccgeom/issues',
        },
        classifiers=[
            "Programming Language :: Python :: 3",
            "License :: OSI Approved :: MIT License",
            "Operating System :: OS Independent",
        ],
        python_requires='>=3.8',
        install_requires=[
            'ziglang',
        ],
        test_suite='tests',
        tests_require=['pytest'],
        packages=setuptools.find_packages(),
        cmdclass={
            'build_ext': CCGeomBuildExtension,
            'install_lib': CCGeomInstall,
        }
    )
