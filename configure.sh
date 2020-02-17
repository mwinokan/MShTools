#!/bin/bash

while test $# -gt 0; do
  case "$1" in
    --configure-github)
      echo "# Suppressed Information Do Not Distribute" > .suppressed_github
      shift
      echo "author="$1";" >> .suppressed_github
      echo "user="$2";" >> .suppressed_github
      echo "email="$3";" >> .suppressed_github
      exit 0
      ;;
    --configure-gitlab)
      echo "# Suppressed Information Do Not Distribute" > .suppressed_gitlab
      shift
      echo "author="$1";" >> .suppressed_gitlab
      echo "surrey_usercode="$2";" >> .suppressed_gitlab
      echo "surrey_staffname="$3";" >> .suppressed_gitlab
      echo "surrey_useremail="$2"@surrey.ac.uk;" >> .suppressed_gitlab
      echo "surrey_staffemail="$3"@surrey.ac.uk;" >> .suppressed_gitlab
      echo "token="$6";" >> .suppressed_gitlab
      exit 0
      ;;
    *)
      break
      ;;
  esac
done