# -*- coding: utf-8 -*-
"""
Copyright © 2011 Opinsys Oy
            2012 lamikae

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
"""
import os
import re
import sys
import signal
import urlparse
from optparse import OptionParser
from logging import getLogger
import PySide
from PySide import QtGui
import __builtin__
import iivari

def process_args():
    parser = OptionParser()
    parser.add_option(
        "-n", "--hostname", action="store", dest="hostname",
        help="client hostname for the server (overrides autodetect)")
    parser.add_option(
        "-s", "--size", action="store", dest="size",
        help="client screen resolution (overrides autodetect)")
    parser.add_option(
        "-r", "--repl", action="store_true", dest="use_repl",
        help="launch JavaScript REPL for debugging")
    parser.add_option(
        "-u", "--urlbase", action="store", dest="urlbase",
        help="base for url to fetch screen contents")
    parser.add_option(
        "-c", "--rcfile", action="store", dest="rcfile",
        help="custom iivarirc")

    return parser.parse_args()


def prepare_log_and_cache_paths():

    import iivari.settings as settings

    if 'LOG_FILE' in settings.__dict__:
        # setup log directory
        log_file = settings.LOG_FILE
        if log_file is not None:
            log_dir = os.path.dirname(log_file)
            if not os.path.exists(log_dir):
                os.makedirs(log_dir)
        __builtin__.LOG_FILE = log_file
    else:
        # when LOG_FILE is undefined, log to console
        __builtin__.LOG_FILE = None

    if 'CACHE_PATH' in settings.__dict__:
        # setup cache directory for offline resources
        cache_path = settings.CACHE_PATH
        if cache_path is not None:
            if not os.path.exists(cache_path):
                os.makedirs(cache_path)
        __builtin__.IIVARI_CACHE_PATH = cache_path
    else:
        __builtin__.IIVARI_CACHE_PATH = None


if __name__ == "__main__":
    """Iivari-client startup.

    Invoke from the command line:

        $ python -m iivari.kiosk [args]

    """
    logger = getLogger(__name__)

    # ensure that the application quits using CTRL-C
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    # parse command line parameters
    (opts, args) = process_args()

    # initialize Qt application
    app = PySide.QtGui.QApplication("")

    # process parameters
    # --hostname
    if opts.hostname is not None:
        hostname = opts.hostname
    else:
        import socket
        hostname = socket.gethostname()
    # --repl
    use_repl = opts.use_repl
    # --size
    if opts.size is not None:
        # resolution is given in string format widthxheight
        # (eg. "800x600")
        (width, height) = [int(d) for d in opts.size.split('x')]
    else:
        size = app.desktop().availableGeometry().size()
        width = size.width()
        height = size.height()
    if opts.rcfile is not None:
        __builtin__.IIVARIRC = opts.rcfile

    # Prints PySide and the Qt version used to compile PySide
    logger.info(' *\n * Initialising iivari-client %s\n * Python %s\n * PySide version %s\n * Qt version %s\n *' % (
        iivari.__version__,
        re.split(" ", sys.version)[0],
        PySide.__version__,
        PySide.QtCore.__version__))

    prepare_log_and_cache_paths()

    # format start url
    base = urlparse.urlsplit(opts.urlbase or iivari.settings.SERVER_BASE)
    resolution = "%dx%d" % (width, height)
    params = 'resolution=%s&hostname=%s' % (resolution, hostname)
    url = urlparse.urlunsplit(urlparse.SplitResult(base.scheme,
                                                   base.netloc,
                                                   base.path,
                                                   params,
                                                   ''))

    # create the main window
    from iivari.main import MainWindow
    window = MainWindow(
        url=url,
        hostname=hostname,
        use_repl=use_repl,
        )

    # set fullscreen mode and resize the WebView to proper resolution
    window.showFullScreen()
    window.webView.setGeometry(PySide.QtCore.QRect(0, 0, width, height))

    # show the window
    window.show()
    # raise it to the front
    window.raise_()

    # start application and quit on exit
    logger.debug("Launching Qt")
    sys.exit(app.exec_())

