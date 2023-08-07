#!/bin/bash


USERCODE=$(grep -oP "(?<=usercode=).*(?=;)" $MSHTOOLS/.suppressed_gitlab)

# This will require SSH keys to have been set up between EUREKA and access.
scp $@ $USERCODE@access.eps.surrey.ac.uk:fromEureka/.
