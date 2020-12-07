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
      echo "token="$4";" >> .suppressed_gitlab
      exit 0
      ;;
    --configure-extern)
      echo "# Suppressed Information Do Not Distribute" > .suppressed_gitlab
      shift
      echo "user="$1";" >> .suppressed_extern
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

echo "MShTools Setup"
echo "--------------"

echo

echo "This setup is required for many of the scripts in this repository."
echo "Please run configure with all the necessary credentials."

echo

echo "configure.sh --configure-github <author_name> <user> <email>"
echo "configure.sh --configure-gitlab <author_name> <surey_usercode> <surrey_staffname> <gitlab_token>"
echo "configure.sh --configure-extern <username>"
