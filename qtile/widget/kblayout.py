from .. import hook, bar, manager
import base
import subprocess
from kb import kb


class kblayout(base._TextBox):
    """
        A simple but flexible text-based kblayout.
    """
    defaults = manager.Defaults(
        ("font", "Arial", "kblayout font"),
        ("fontsize", None, "kblayout pixel size. Calculated if None."),
        ("padding", None, "kblayout padding. Calculated if None."),
        ("background", "000000", "Background colour"),
        ("foreground", "ffffff", "Foreground colour")
    )

    def __init__(self, width=bar.CALCULATED, **config):
        base._TextBox.__init__(self, "ru", width, **config)

    def _configure(self, qtile, bar):
        base._TextBox._configure(self, qtile, bar)
        self.timeout_add(1, self.update)

    def update(self):
        k = kb()
        l = k.curkb()
        if self.text != l:
            self.text = l
            self.bar.draw()
        return True
