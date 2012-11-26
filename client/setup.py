# -*- encoding: utf-8 -*-
from distutils.core import setup
import os, glob

def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

# Import package version. Relative path is searched
# before system python packages.
#from iivari import __version__
__version__ = "1.5.0"

setup(name="iivari-client",
      version=__version__,
      maintainer="github.com/lamikae",
      maintainer_email="mikael.lammentausta+github@gmail.com",
      url="https://github.com/lamikae/iivari/",
      license="GPL-2",
      description="Iivari digital signage viewer",
      # long_description=read("README.md"),
      packages=["iivari", "iivari/logger"],
      scripts=["bin/iivari-client",
               "bin/iivari-display_off",
               "bin/iivari-display_on",
               "bin/iivari-display_test_pattern"],
      data_files=[("/usr/share/iivari/assets", glob.glob("iivari/assets/*")),
                  ("/usr/share/applications", ["iivari-infotv.desktop"]),
                  ],
                  # no configuration is installed;
                  # iivari-express provides example configuration.
      )
