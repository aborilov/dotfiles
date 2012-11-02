import sys
import os
import subprocess
os.environ['GI_TYPELIB_PATH'] =\
    'libxklavier:' + os.environ.get('GI_TYPELIB_PATH', '')

#del sys.modules['gobject']
from gi.repository import Xkl, Gdk, GdkX11


class kb():

    def __init__(self):
        pass

    def curkb(self):
        display = GdkX11.x11_get_default_xdisplay()
        self.engine = Xkl.Engine.get_instance(display)
        t = subprocess.check_output(["xset", "-q"])
        num = int(t.splitlines()[1].split()[9][4])
        groups = self.engine.get_groups_names()
        if (len(groups) > num):
            return str(groups[int(num)])[:2]
        else:
            return "Err"

k = kb()
print k.curkb()
