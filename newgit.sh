#!/bin/bash

# source necessary files
source $MWSHPATH/colours.sh
source $MWSHPATH/directory_exists.sh

# check number of arguments
if [ $# -eq 0 ]
then 
  echo -e $colError"Wrong number of arguments provided."$colClear
  echo -e "See "$colFunc"newgit"$colClear$colArg" -h "$colClear"for usage."
  exit 1
fi

# variable initialisation
FORCE=0
ALL=0
SURREY=0

# check for flags

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "Usage for "$colFunc"newgit"$colClear":"
      echo -e $colArg"-n"$colClear" name of new github repository"
      echo -e $colArg"-d"$colClear" description new github repository [required for github]"
      echo -e $colArg"-m"$colClear" first commit message"
      echo -e $colArg"-a"$colClear" add all files to first commit"
      echo -e $colArg"-f"$colClear" force initialisation"
      echo -e $colArg"-s|--surrey"$colClear" use Surrey/GitLab instead of GitHub."
      exit 5
      ;;
    -n)
      shift
      if test $# -gt 0; then
        REPO_NAME=$1
      else
        echo -e $colError"No name specified."
        exit 2
      fi
      shift
      ;;
    -d)
      shift
      if test $# -gt 0; then
        DESCRIPTION=$1
      else
        echo -e $colError"No description specified."
        exit 3
      fi
      shift
      ;;
    -f)
      FORCE=1
      shift
      ;;
    -a)
      ALL=1
      shift
      ;;
    -s|--surrey)
      SURREY=1
      USEREMAIL=$(grep -oP "(?<=useremail=).*(?=;)" $MWSHPATH/.suppressed_gitlab)
      echo -e $colWarning"Using $USEREMAIL GitLab credentials."$colClear
      shift
      ;;
    -m)
      shift
      if test $# -gt 0; then
        COMMIT_MSG=$1
      else
        echo -e $colError"No COMMIT_MSG specified."
        exit 3
      fi
      shift
      ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      echo -e "See "$colFunc"newgit"$colClear$colArg" -h "$colClear"for usage."
      exit 4
      ;;
  esac
done

DIR_NAME=${PWD##*/}

if [[ -z "$REPO_NAME" ]] ; then
  echo -e $colWarning"No "$colArg"REPO_NAME"$colWarning" given, defaulting to directory name: "$colFile"$DIR_NAME"$colClear
  REPO_NAME=$DIR_NAME
fi

if [ $SURREY -eq 0 ] && [[ -z "$DESCRIPTION" ]] ; then
  echo -e $colError"Description required for github."$colClear
  exit 6
fi

if [[ -z "$COMMIT_MSG" ]] ; then
  COMMIT_MSG="\"First commit.\""
fi

directoryExistsQuiet .git
if [ $? -eq 1 ] ; then
  if [ $FORCE -ne 1 ] ; then
    echo -e $colError"Error: "$colFile".git/ "$colError"already exists. Use "$colArg"-f"$colError" to ignore."$colClear
    exit 5
  # else
    # rm -r .git
  fi
fi

if [ $SURREY -eq 0 ] ; then

  # initialise git & create github repository:
  echo -e $colBold"Initialising and creating GitHub repository..."$colClear
  git init
  hub create -p -d "$DESCRIPTION" $REPO_NAME

  fileExistsQuiet README.md
  if [ $? -eq 0 ] || [ $FORCE -eq 1 ] ; then
    # create README.md
    echo -e $colBold"Creating "$colFile"README.md"$colClear
    echo -e "# $REPO_NAME\n" > README.md
    echo -e "$DESCRIPTION\n" >> README.md
    echo -e "Initialised at $(pwd) on $(whoami)@$(hostname)\n" >> README.md
    echo -e "</newgit.sh>" >> README.md
  else
    # utilise existing README.md
    mv README.md oldREADME.md
    echo -e "# $REPO_NAME\n" > README.md
    echo -e "$DESCRIPTION\n" >> README.md
    echo -e "$(cat oldREADME.md)" >> README.md
    echo -e "\n""Initialised at $(pwd) on $(whoami)@$(hostname)\n" >> README.md
    echo -e "</newgit.sh>\n" >> README.md
  fi

  # add to commit:
  git add README.md
  if [ $ALL -eq 1 ] ; then
    git add -A
  fi

  # commit and push
  git commit -m "$COMMIT_MSG"
  git push -u origin master

else

  # initialise git & configure authorship:
  echo -e $colBold"Initialising and configuring authorship..."$colClear
  AUTH=$(grep -oP "(?<=author=).*(?=;)" $MWSHPATH/.suppressed_gitlab)
  if [ $? -ne 0 ] ; then 
    echo -e $colError"grep error"$colClear
  fi
  EMAIL=$(grep -oP "(?<=staffemail=).*(?=;)" $MWSHPATH/.suppressed_gitlab)
  if [ $? -ne 0 ] ; then 
    echo -e $colError"grep error"$colClear
  fi
  echo -e "$colArg$AUTH$colClear"
  echo -e "$colArg$EMAIL$colClear"

  git init
  git config user.name $AUTH
  git config user.email $EMAIL

  fileExistsQuiet README.md
  if [ $? -eq 0 ] || [ $FORCE -eq 1 ] ; then
    # create README.md
    echo -e $colBold"Creating "$colFile"README.md"$colClear
    echo -e "# $REPO_NAME\n" > README.md
    echo -e "$DESCRIPTION\n" >> README.md
    echo -e "Initialised at $(pwd) on $(whoami)@$(hostname)\n" >> README.md
    echo -e "</newgit.sh>" >> README.md
  else
    # utilise existing README.md
    mv README.md oldREADME.md
    echo -e "# $REPO_NAME\n" > README.md
    echo -e "$DESCRIPTION\n" >> README.md
    echo -e "$(cat oldREADME.md)" >> README.md
    echo -e "\n""Initialised at $(pwd) on $(whoami)@$(hostname)\n" >> README.md
    echo -e "</newgit.sh>\n" >> README.md
  fi

  # add to commit:
  echo -e $colBold"Adding to commit..."$colClear
  git add README.md
  if [ $ALL -eq 1 ] ; then
    git add -A
  fi
  
  # commit
  echo -e $colBold"Committing..."$colClear
  git commit -m "$COMMIT_MSG"

  # push to GitLab (created new project)
  echo -e $colBold"Pushing to GitLab..."$colClear
  TOKEN=$(grep -oP "(?<=token=).*(?=;)" $MWSHPATH/.suppressed_gitlab)
  USERCODE=$(grep -oP "(?<=usercode=).*(?=;)" $MWSHPATH/.suppressed_gitlab)
  git push --set-upstream https://oauth2:$TOKEN@gitlab.eps.surrey.ac.uk/$USERCODE/$REPO_NAME.git master # HTTPS

fi
