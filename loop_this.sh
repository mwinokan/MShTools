#!/bin/bash

while :
do
  clear
  $@
  echo -e "\nPress [CTRL+C] to stop.."
  sleep 1.0
done
