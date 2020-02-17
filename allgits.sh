#!/bin/bash

# Currently broken on MaxBook Pro!
# Works on EUREKA

source $MWSHPATH/colours.sh

ALL_GITS=$(find $HOME -name ".git" | sort)

GH_USER=$(grep -oP "(?<=user=).*(?=;)" $MWSHPATH/.suppressed_github)
GH_EMAIL=$(grep -oP "(?<=email=).*(?=;)" $MWSHPATH/.suppressed_github)
GL_USERCODE=$(grep -oP "(?<=usercode=).*(?=;)" $MWSHPATH/.suppressed_gitlab)
GL_STAFFNAME=$(grep -oP "(?<=staffname=).*(?=;)" $MWSHPATH/.suppressed_gitlab)

for GIT in $ALL_GITS ; do

  REPO_NAME=$(cat $GIT/config | grep -oP "(?<=/).*(?=.git)")
  if [ $(cat $GIT/config | grep "github" | wc -l) -eq 1 ] ; then
    ## github repo
    if [ $(cat $GIT/config | grep $GH_USER | wc -l) -eq 1 ] ; then
      ## my repo
      REPO_TYPE=1
    else
      ## not my repo
      REPO_TYPE=0
      continue
    fi

  elif [ $(cat $GIT/config | grep "gitlab" | wc -l) -eq 1 ] ; then
    ## gitlab repo
    if [ $(cat $GIT/config | grep $GL_STAFFNAME | wc -l) -eq 1 ] ; then
      ## my repo
      REPO_NAME=$(cat $GIT/config | grep -oP "(?<=$USERCODE/).*(?=.git)")
      REPO_TYPE=2
    else
      ## not my repo
      REPO_TYPE=0
      continue
    fi
  fi

  LAST=$(pwd)
  cd $GIT/..
  GIT_STATUS=$(git status)
  NUM_MOD=$(echo $GIT_STATUS | grep -o "modified" | wc -l)
  if [ $NUM_MOD -ne 0 ] ; then
    # there are modified files 
    STATUS=1
  else
    STATUS=0
  fi

  NAME_LINE='                                           '
  # NAME_LINE='-------------------------------------------'
  
  echo -e -n "Repo: "
  # echo -e -n $colFunc$REPO_NAME$colClear" "
  if [ $REPO_TYPE -eq 1 ] ; then echo -e -n "(github) " ; fi
  if [ $REPO_TYPE -eq 2 ] ; then echo -e -n "(gitlab) " ; fi
  printf "$colFunc%s$colClear %s" $REPO_NAME "${NAME_LINE:${#REPO_NAME}}"
  if [ $STATUS -eq 0 ] ; then echo -e -n $colSuccess"No Modifications"$colClear ; fi
  if [ $STATUS -eq 1 ] ; then echo -e -n $colBold$NUM_MOD" Modified Files"$colClear ; fi
  echo -e -n " Local: "
  echo -e -n $colFile$GIT$colClear

  if [ $REPO_TYPE -eq 1 ] ; then

    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @{0})
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @{0} "$UPSTREAM")
    
    if [ $LOCAL = $REMOTE ]; then
        echo -ne $colSuccess" Up-to-date"$colClear
    elif [ $LOCAL = $BASE ]; then
        echo -ne $colBold" Need to pull"$colClear
    elif [ $REMOTE = $BASE ]; then
        echo -ne $colBold" Need to push"$colClear
    else
        echo -ne $colError" Diverged"$colClear
    fi
  fi
  
  cd $LAST

  echo -e $colClear

done
