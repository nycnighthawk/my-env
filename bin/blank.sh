#!/bin/bash
uname -a | grep -qi darwin
if [ "$?" == "0" ]
then
    pmset displaysleepnow
else
    xset dpms force off
fi
