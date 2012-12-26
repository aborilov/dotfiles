from libqtile.manager import Key, Click, Drag, Screen, Group
from libqtile.command import lazy
from libqtile import layout, bar, widget, hook


modkey = "mod4"
keys = [
    Key([modkey], "k", lazy.layout.down()),
    Key([modkey, "shift"], "n", lazy.to_next_screen()),
    Key([modkey], "j", lazy.layout.up()),
    Key([modkey], "h", lazy.layout.grow()),
    Key([modkey], "l", lazy.layout.shrink()),
    Key([modkey], "n", lazy.layout.normalize()),
    Key([modkey], "m", lazy.layout.maximize()),
    Key([modkey, "shift"], "q", lazy.shutdown()),
    Key([modkey], "e", lazy.spawn("pcmanfm")),
    Key([modkey], "b", lazy.spawn("chromium")),
    Key([modkey], "x", lazy.spawn("xscreensaver-command --lock")),
    Key([modkey], "s", lazy.spawn("sublime_text")),
    Key([modkey], "w", lazy.window.kill()),
    Key([modkey], "Left", lazy.prevgroup()),
    Key([modkey], "Right", lazy.nextgroup()),
    Key([modkey], "t", lazy.window.disable_floating()),
    Key([modkey], "Return", lazy.spawn("urxvt -pe tabbed")),
    Key([modkey], "F10", lazy.spawn("import -window root ~/screenshot.png")),
    Key(
        [], "XF86AudioRaiseVolume",
        lazy.spawn("amixer -c 0 -q set Master 2dB+")
    ),
    Key(
        [], "XF86AudioLowerVolume",
        lazy.spawn("amixer -c 0 -q set Master 2dB-")
    ),
    Key(
        [], "XF86AudioMute",
        lazy.spawn("amixer -c 0 -q set Master toggle")
    ),
    # Key([modkey], "p",
    #     lazy.spawn(
    #         "exec dmenu_run "
    #         "-fn 'Consolas:size=13' -nb '#000000' -nf '#ffffff' -b")),
    Key([modkey], "space", lazy.nextlayout()),
    Key([modkey, "shift"], "k", lazy.layout.shuffle_down()),
    Key([modkey, "shift"], "j", lazy.layout.shuffle_up()),
    Key([modkey], "p", lazy.spawncmd()),
    Key([modkey], "y", lazy.layout.toggle_split()),
    Key(
        [modkey, "shift"], "space",
        lazy.layout.flip()
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
    border_focus = '#ffffff',
    border_width=2,
    border_normal="#222222",)

groups = [
    Group("Browser"),
    Group("Jabber"),
    Group("Develope"),
    Group("Terminals"),
    Group("FileManager"),
    Group("6"),
    Group("7"),
    Group("8"),
]

for index, grp in enumerate(groups):

    keys.extend([

        # switch to group
        Key([modkey], str(index + 1), lazy.group[grp.name].toscreen(0)),
        Key([modkey, "control"], str(index + 1), lazy.group[grp.name].toscreen(1)),

        # send to group
        Key([modkey, "shift"], str(index + 1), lazy.window.togroup(grp.name)),

    ])

layouts = [
    layout.MonadTall(**border),
    layout.TreeTab(),
    layout.Stack(stacks=1)
]

floating_layout = layout.Floating(**border)

# global font options
widget_defaults = dict(
    font = 'Consolas',
    fontsize = 13,
    padding = 1,
    borderwidth=2,
    margin_x=1,
    margin_y=1
)

screens = [
    Screen(
        top=bar.Bar([widget.GroupBox(urgent_alert_method='text', **widget_defaults),
            widget.WindowName(**widget_defaults),
            widget.Prompt(),
            widget.Systray(),
            #widget.kblayout(font='Consolas', fontsize=13, padding=6),
            widget.Notify(**widget_defaults),
            widget.Volume(**widget_defaults),
            widget.Sep(),
            widget.Clock('%H:%M:%S %d.%m.%Y',**widget_defaults),
            widget.Sep(),
            widget.Pacman(**widget_defaults),
            widget.Sep(),
            widget.Battery(energy_now_file = "charge_now",
                                energy_full_file = "charge_full",
                                power_now_file = "current_now",
                                update_delay = 5,
                                charge_char = '>',
                                discharge_char = '<',**widget_defaults)
            ],
            24,)),
    Screen()]


@hook.subscribe.client_new
def grouper(window, windows={
        'chromium': 'Browser',
        'sublime_text': 'Develope',
        'urxvt': ['Jabber', 'Terminals'],
        'pcmanfm': 'FileManager'}):

    """
    This function relies on the contentious feature of default arguments
    where upon function definition if the argument is a mutable datatype,
    then you are able to mutate the data held within that object.

    Current usage:

    {window_name: group_name}

    or for grouping windows to different groups you will need to have a
    list under the window-key with the order that you're starting the
    apps in.

    See the 'runner()' function for an example of using this method.

    Here:

    {window_name: [group_name1, group_name2]}

    Window name can be found via window.window.get_wm_class()
    """
    try:
        windowtype = window.window.get_wm_class()[0]

        # if the window is in our map
        if windowtype in windows.keys():

            # opening terminal applications gives
            # the window title the same name, this
            # means that we need to treat these apps
            # differently

            if windowtype != 'urxvt':
                window.togroup(windows[windowtype])
                windows.pop(windowtype)

                # if it's not on our special list,
                # we send it to the group and pop
                # that entry out the map
            else:
                try:
                    window.togroup(windows[windowtype][0])
                    windows[windowtype].pop(0)
                except IndexError:
                    pass
    except:
        pass

floating_layout = layout.Floating(

    auto_float_types=[
        'utility',

        'notification',
        'toolbar',

        'splash',
        'dialog',

    ],
    float_rules=[
        {'wmclass': 'sun-awt-X11-XDialogPeer'}, #vue

        {'wmclass': 'sun-awt-X11-XWindowPeer'}, #vue

    ],
)

@hook.subscribe.client_new
def dialogs(window):
    if (window.window.get_wm_type() == 'dialog'
            or window.window.get_wm_transient_for()):
        window.floating = True

@hook.subscribe.client_new
def vue_tools(window):
    if window.window.get_wm_class() == ('sun-awt-X11-XDialogPeer', 'java-lang-Thread'):
        window.floating = True

main = None
follow_mouse_focus = True
cursor_warp = False
floating_layout = layout.Floating()
mouse = ()


#@hook.subscribe.startup
#def runner():
#    import subprocess
#    subprocess.Popen(['./startup.sh'])
