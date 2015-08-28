#!/usr/bin/env python2
import os
CHAR = "V "
cmd = 'nmcli -f name,devices con status|tail -n+2'
active_devices = os.popen(cmd).read().split('\n')
name_dev = {}
for name_device in active_devices:
    if name_device:
        name, device = name_device.split()
        name_dev[name] = device
all_cons = os.popen('nmcli -f name con list|tail -n+2').read().split()
active_cons = os.popen('nmcli -f name con status|tail -n+2').read().split()
selected_list = [CHAR + con if con in active_cons else con for con in all_cons]
con = os.popen("echo \"" + "\n".join(selected_list) + "\" | dmenu -l 3").read()
if con.startswith(CHAR):
    name = con.split()[1]
    os.popen("nmcli con down id {}".format(name))
    device = name_dev[name]
    os.popen("nmcli dev disconnect iface {}".format(device))
else:
    name = con
    os.popen("nmcli con up id {}".format(name))
