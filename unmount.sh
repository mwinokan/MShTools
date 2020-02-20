#!/bin/bash

source $MWSHPATH/colours.sh
source $MWSHPATH/out.sh

headerOut "Mounted Volumes:"
ls /Volumes | grep -v Macintosh | grep -v TimeMachine | grep -v BOOTCAMP

headerOut "\n""Unmounting...\n"
osascript -e 'tell application "Finder" to eject (every disk whose ejectable is true)'

MOUNT_NUM=$(ls /Volumes | grep -v Macintosh | grep -v TimeMachine | grep -v BOOTCAMP | wc -l)
returnOut "Number of mounted volumes: " $MOUNT_NUM
