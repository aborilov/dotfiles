from libqtile.manager import Key, Click, Drag, Screen, Group
from libqtile.command import lazy
from libqtile import layout, bar, widget, hook


modkey = "mod4"
keys = [
    Key([modkey], "k", lazy.layout.down()),
    Key([modkey], "j", lazy.layout.up()),
    Key([modkey], "h", lazy.layout.grow()),
    Key([modkey], "l", lazy.layout.shrink()),
    Key([modkey], "n", lazy.layout.normalize()),
    Key([modkey], "m", lazy.layout.maximize()),
    Key([modkey], "q", lazy.shutdown()),
    Key([modkey], "e", lazy.spawn("pcmanfm")),
    Key([modkey], "b", lazy.spawn("uzbl-tabbed")),
    Key([modkey], "x", lazy.spawn("xtrlock")),
    Key([modkey], "w", lazy.window.kill()),
    Key([modkey], "Left", lazy.prevgroup()),
    Key([modkey], "Right", lazy.nextgroup()),
    Key([modkey], "t", lazy.window.disable_floating()),
    Key([modkey], "Return", lazy.spawn("gnome-terminal")),
    Key([modkey], "p",
        lazy.spawn(
            "exec dmenu_run "
            "-fn 'Consolas:size=13' -nb '#000000' -nf '#ffffff' -b")),
    Key([modkey], "space", lazy.nextlayout()),
    Key([modkey, "shift"], "k", lazy.layout.shuffle_down()),
    Key([modkey, "shift"], "j", lazy.layout.shuffle_up()),
    Key(
        [modkey, "shift"], "space",
        lazy.layout.flip()
    ),
    Key(
        [modkey, "shift"], "Return",
        lazy.layout.toggle_split()
    ),
    Key([modkey, "control"], "r", lazy.restart()),
    Key([modkey, "shift"], "t", lazy.window.enable_floating()),
]

mouse = [
    Drag(
        [modkey], "Button1", lazy.window.set_position_floating(),
        start=lazy.window.get_position()),
    Drag(
        [modkey], "Button3", lazy.window.set_size_floating(),
        start=lazy.window.get_size()),
    Click([modkey], "Button2", lazy.window.bring_to_front())
]

border = dict(
    border_normal='#808080',
    border_width=2,)

groups = [
    Group("1"),
    Group("2"),
    Group("3"),
    Group("4"),
    Group("5"),
    Group("6"),
    Group("7"),
    Group("8"),
]
for i in groups:
    keys.append(
        Key([modkey], i.name, lazy.group[i.name].toscreen())
    )
    keys.append(
        Key([modkey, "shift"], i.name, lazy.window.togroup(i.name))
    )

layouts = [
    layout.MonadTall(),
    layout.TreeTab()
]

floating_layout = layout.Floating(**border)

screens = [
    Screen(
        top=bar.Bar([widget.GroupBox(
            borderwidth=2, font='Consolas', fontsize=13,
            padding=1, margin_x=1, margin_y=1),
            widget.Sep(),
            widget.WindowName(
                font='Consolas', fontsize=13, margin_x=6),
            widget.Sep(),
            widget.Battery(
                font='Consolas', fontsize=13, margin_x=6,
                energy_now_file="charge_now",
                energy_full_file="charge_full",
                power_now_file="current_now"),
            widget.Sep(),
            widget.Systray(),
            widget.kblayout(font='Consolas', fontsize=13, padding=6),
            widget.Sep(),
            widget.Clock(
                '%H:%M:%S %d.%m.%Y',
                font='Consolas', fontsize=13, padding=6), ], 24,),
    ),
]


@hook.subscribe.client_new
def dialogs(window):
    if (window.window.get_wm_type() == 'dialog'
            or window.window.get_wm_transient_for()):
        window.floating = True

main = None
follow_mouse_focus = True
cursor_warp = False
floating_layout = layout.Floating()
mouse = ()
