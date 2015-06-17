from libqtile.config import Key, Group
from libqtile.manager import Drag, Click, Screen
from libqtile.command import lazy
from libqtile import layout, bar, widget
from libqtile import hook


mod = "mod4"
alt = "mod1"

keys = [
    Key([mod], "Home", lazy.spawn("mpc toggle")),
    Key([mod], "End", lazy.spawn("mpc stop")),
    Key([mod], "Page_Down", lazy.spawn("mpc next")),
    Key([mod], "Delete", lazy.spawn("mpc prev")),
    Key(
        [mod], "m",
        lazy.spawn(
            """
            mpc playlist | dmenu -l 10  |\
            xargs -I '{}' sh -c "mpc playlist \
            | grep -rne '{}' | awk -F: '{print \$1}'" \
            | xargs -I '{}' sh -c "test -n '{}' && mpc play '{}'"
            """)
    ),
    # Switch between windows in current stack pane
    Key(
        [mod], "w",
        lazy.window.kill()
    ),
    Key(
        [alt], "grave",
        lazy.window.bring_to_front()
    ),
    Key(
        [alt], "Tab",
        lazy.group.next_window()),
    # this is usefull when floating windows get buried
    Key(
        [mod], "Left",
        lazy.group.prevgroup()
    ),
    Key(
        [mod], "Right",
        lazy.group.nextgroup()
    ),
    Key(
        [mod], "h",
        lazy.layout.previous()
    ),
    Key(
        [mod], "l",
        lazy.layout.next()
    ),
    Key(
        [mod], "j",
        lazy.layout.down()
    ),
    Key(
        [mod], "k",
        lazy.layout.up()
    ),
    Key(
        [mod], "f",
        lazy.window.toggle_floating()
    ),
    Key(
        [mod, "shift"], "space",
        # lazy.layout.rotate(),
        lazy.layout.flip(),              # xmonad-tall
        ),
    Key(
        [mod, "shift"], "k",
        lazy.layout.shuffle_up(),         # Stack, xmonad-tall
        ),
    Key(
        [mod, "shift"], "j",
        lazy.layout.shuffle_down(),       # Stack, xmonad-tall
        ),
    Key(
        [mod, "control"], "l",
        lazy.layout.add(),                # Stack
        lazy.layout.increase_ratio(),     # Tile
        lazy.layout.maximize(),           # xmonad-tall
        ),
    Key(
        [mod, "control"], "h",
        lazy.layout.delete(),             # Stack
        lazy.layout.decrease_ratio(),     # Tile
        lazy.layout.normalize(),          # xmonad-tall
        ),
    Key(
        [mod, "control"], "k",
        lazy.layout.shrink(),             # xmonad-tall
        lazy.layout.decrease_nmaster(),   # Tile
        ),
    Key(
        [mod, "control"], "j",
        lazy.layout.grow(),               # xmonad-tall
        lazy.layout.increase_nmaster(),   # Tile
        ),
    Key(
        [mod], "n",
        lazy.spawn("firefox")
        ),
    Key(
        [mod], "d",
        lazy.spawn("gvim")
        ),
    Key(
        [mod], "o",
        lazy.spawn("pcmanfm")
        ),
    Key(
        [mod], "u",
        lazy.spawn("uzbl-tabbed")
        ),
    Key(
        [mod], "c",
        lazy.spawn("notify-send _")
        ),
    Key(
        [mod], "b",
        lazy.hide_show_bar()
        ),
    # Key([mod], "Return", lazy.spawn("urxvt -e screen -x -R")),
    # Key([mod], "Return", lazy.spawn("sh -c \"tmux ls -F '#{session_name}' | \
                                    # dmenu -l 7\" ")),
    Key([mod], "Return", lazy.spawn("""bash -c \"tmux ls -F '#{session_name}' | \
                                    dmenu -l 7 | xargs -I{} bash -c \
                                    \\\"if [ '{}' == 'new' ]; \
                                    then urxvtcd -e tmux ;\
                                    else urxvtcd -e tmux attach -t {};fi\\\"\"""")),
    # Key([mod], "Return", lazy.spawn("urxvt")),
    # Key([mod], "Return", lazy.spawn("/tmp/1.sh")),
    # Key([mod], "Return", lazy.spawn("screen -ls | head -n -2 | tail -n +2 | dmenu -l 5 | awk '{print \$1}' | awk -F. '{print \$2}' | xargs urxvt -e screen -R -x")),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"], "Return",
        lazy.layout.toggle_split()
    ),

    # Toggle between different layouts as defined below
    Key([mod], "Tab",    lazy.nextlayout()),

    Key(
        [mod, "control"],  "r",
        lazy.restart()
    ),
    Key([mod, "control"], "q", lazy.shutdown()),
    Key(
        [mod], "space",
        lazy.spawn(
            "dmenu_run -fn 'Terminus:size=8' -nb '#000000' -nf '#fefefe'")
    ),
    Key(
        [mod], "equal",
        lazy.spawn("amixer -c 0 -q set Master 2dB+")
    ),
    Key(
        [mod], "minus",
        lazy.spawn("amixer -c 0 -q set Master 2dB-")
    ),
]


mouse = [
    Drag(
        [mod], "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position()
    ),
    Drag(
        [mod], "Button3",
        lazy.window.set_size_floating(),
        start=lazy.window.get_size()
    ),
    Click(
        [mod], "Button2",
        lazy.window.bring_to_front()
    ),
]

groups = [Group(str(i)) for i in (1, 2, 3, 4, 5, 6, 7, 8, 9, 0)]
for i in groups:
    keys.append(Key([mod], i.name, lazy.group[i.name].toscreen()))
    keys.append(
        Key(
            [mod, "shift"], i.name, lazy.window.togroup(i.name),
            lazy.group[i.name].toscreen()))

border = dict(
    border_normal='#808080',
    border_width=1,
)

dgroups_key_binder = None
dgroups_app_rules = []

layouts = [
    layout.Max(),
    layout.MonadTall(**border),
    layout.Matrix(**border)
    # layout.Stack(num_stacks=1, **border)
]

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(margin_y=1,
                                margin_x=1,
                                borderwidth=1,
                                padding=1,),
                widget.WindowName(foreground="a0a0a0",),
                widget.Notify(),
                widget.Systray(),
                # widget.CurrentLayout(),
                widget.KeyboardLayout(configured_keyboards=["us", "ru"]),
                widget.Volume(foreground="70ff70",),
                widget.BatteryIcon(),
                widget.BitcoinTicker(currency="rub", format="{buy}"),
                widget.Clock(foreground="a0a0a0",
                             fmt="%H:%M %d.%m.%Y",),
            ],
            18,
        ),
    ),
]


def main(self):
    pass


@hook.subscribe.client_new
def dialogs(window):
    if (window.window.get_wm_type() == 'dialog'
            or window.window.get_wm_transient_for()):
        window.floating = True


@hook.subscribe.client_new
def vue_tools(window):
    if((window.window.get_wm_class() == (
        'sun-awt-X11-XWindowPeer', 'tufts-vue-VUE')
            and window.window.get_wm_hints()['window_group'] != 0)
            or (window.window.get_wm_class() == (
                'sun-awt-X11-XDialogPeer', 'tufts-vue-VUE'))):
        window.floating = True


@hook.subscribe.client_new
def idle_dialogues(window):
    if((window.window.get_name() == 'Search Dialog') or
      (window.window.get_name() == 'Module') or
      (window.window.get_name() == 'Goto') or
      (window.window.get_name() == 'IDLE Preferences')):
        window.floating = True


@hook.subscribe.client_new
def libreoffice_dialogues(window):
    if ((window.window.get_wm_class() == (
        'VCLSalFrame', 'libreoffice-calc')) or
            (window.window.get_wm_class() == (
                'VCLSalFrame', 'LibreOffice 3.4'))):
        window.floating = True


import subprocess
import re


def is_running(process):
    s = subprocess.Popen(["ps", "axw"], stdout=subprocess.PIPE)
    for x in s.stdout:
        if re.search(process, x):
            return True
    return False


def execute_once(process):
    if not is_running(process):
        return subprocess.Popen(process.split())


@hook.subscribe.startup
def startup():
    execute_once("nm-applet")
    execute_once("synergy")
    execute_once("xmodmap ~/.xmodmap")
    execute_once("feh --bg-fill /home/pavel/Pictures/arch.png")
    execute_once('setxkbmap -option ctrl:nocaps ')
    execute_once(
        'setxkbmap -layout us,ru -option grp:alt_shift_toggle,grp_led:scroll')


# main = None
# follow_mouse_focus = False
# bring_front_click = False
# cursor_warp = False
# floating_layout = layout.Floating()
# mouse = ()
# auto_fullscreen = True
# widget_defaults = {}
