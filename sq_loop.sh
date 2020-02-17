#!/bin/bash

USERCODE=$(grep -oP "(?<=usercode=).*(?=;)" $MWSHPATH/.suppressed_gitlab)

while :
do
  clear
  squeue -l -u $USERCODE
  echo "Press [CTRL+C] to stop.."
  sleep 0.5
done
