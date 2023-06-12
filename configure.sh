#!/bin/bash

function auto_configure {

  # configure github:

  echo "What is your full name?"
  read FULL_NAME

  echo "Do you want to set-up github credentials? (Y/N)"
  read CHOICE

  case $CHOICE in
    [yY][eE][sS]|[yY])
      echo "Enter your Github username:"
      read GITHUB_USER

      echo "Enter your Github email:"
      read GITHUB_EMAIL

      configure_github $FULL_NAME $GITHUB_USER $GITHUB_EMAIL
      ;;
  esac

  # if in an SSH session
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then

    HOSTNAME=$(hostname -f)
    echo "hostname="$HOSTNAME

    # if on a surrey cluster
    if [[ $HOSTNAME == *"surrey"* ]] || [[ $HOSTNAME == *"eureka"* ]]; then

      echo "Detected a Surrey HPC, if this is wrong exit this process with Ctrl-C!!!"

      USER_CODE=$(whoami)
      echo "Guessed surreycode from whoami as: "$USER_CODE
      
      echo "Do you have a staff email? e.g. m.winokan@surrey.ac.uk (Y/N)"
      read CHOICE

      CODE_EMAIL=$USER_CODE@surrey.ac.uk

      case $CHOICE in
        [yY][eE][sS]|[yY])
          echo "Enter your staff email:"
          read STAFF_EMAIL
          ;;
        *)
          STAFF_EMAIL=$CODE_EMAIL
          ;;
      esac

      echo "Do you have a Gitlab access token? (Y/N)"
      read CHOICE

      case $CHOICE in
        [yY][eE][sS]|[yY])
          echo "Enter your access token:"
          read ACCESS_TOKEN
          ;;
        *)
          ACCESS_TOKEN="XXX"
          ;;
      esac

      echo $ACCESS_TOKEN

      echo $FULL_NAME $USER_CODE $CODE_EMAIL $STAFF_EMAIL $ACCESS_TOKEN

      configure_gitlab "$FULL_NAME" "$USER_CODE" "$CODE_EMAIL" "$STAFF_EMAIL" "$ACCESS_TOKEN"

    else

      echo "Did not detect a Surrey HPC."

      echo "Guessed username from whoami as: "$USER_CODE
      USER_CODE=$(whoami)

      configure_extern $USER_CODE

    fi

  fi

}

function configure_github {

  # Store suppressed information
  echo "# Suppressed Information Do Not Distribute" > .suppressed_github
  echo "author="$1";" >> .suppressed_github
  echo "user="$2";" >> .suppressed_github
  echo "email="$3";" >> .suppressed_github
  
  # Run setups
  git config --global user.name "$1"
  git config --global user.email "$3"

}


function configure_gitlab {

  echo "# Suppressed Information Do Not Distribute" > .suppressed_gitlab
  echo "author="$1";" >> .suppressed_gitlab
  echo "surrey_usercode="$2";" >> .suppressed_gitlab
  echo "surrey_staffname="$3";" >> .suppressed_gitlab
  echo "surrey_useremail="$2";" >> .suppressed_gitlab
  echo "surrey_staffemail="$3";" >> .suppressed_gitlab
  echo "token="$4";" >> .suppressed_gitlab

}

function configure_extern {

  echo "# Suppressed Information Do Not Distribute" > .suppressed_gitlab
  echo "user="$1";" >> .suppressed_extern

}

while test $# -gt 0; do
  case "$1" in
    --configure-github)
      shift
      configure_github $1 $2 $3
      exit 0
      ;;
    --configure-gitlab)
      shift
      configure_gitlab $1 $2 $3 $4
      exit 0
      ;;
    --configure-extern)
      shift
      configure_extern $1
      exit 0
      ;;
    --auto)
      # run auto-configuration
      auto_configure
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
echo
echo "The easiest way to run this script is to run the command as follows:"
echo 
echo "configure.sh --auto"
echo

echo "If automatic setup fails, you can try setting the relevant details manually:"
echo

echo "configure.sh --configure-github <author_name> <user> <email>"
echo "configure.sh --configure-gitlab <author_name> <surey_email> <surrey_staff_email> <gitlab_token>"
echo "configure.sh --configure-extern <username>"
echo
echo "If problems persist try asking Max."
