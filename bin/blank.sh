#!/bin/bash
uname -a | grep -qi darwin
if [ "$?" == "0" ]
then
    pmset displaysleepnow
else
    $(echo ${WAYLAND_DISPLAY} | grep -q wayland)
    if [ "$?" == "0" ]
    then
        dbus-send --session --dest=org.gnome.ScreenSaver --type=method_call \
              /org/gnome/ScreenSaver org.gnome.ScreenSaver.SetActive boolean:true
    else
        xset dpms force off
    fi
fi
