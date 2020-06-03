#!/bin/bash

# Currently broken on MaxBook Pro!
# Works on EUREKA

source $MWSHPATH/colours.sh
SHORT=0
SHOW_SURREY=1
SHOW_GITHUB=1
SEARCH=0

while test $# -gt 0; do
  case "$1" in
    -s|--short)
      shift
      SHORT=1
      ;;
    -ns|--no-surrey)
      shift
      SHOW_SURREY=0
      ;;
    -ng|--no-github)
      shift
      SHOW_GITHUB=0
      ;;
    -n|--name)
      SEARCH=1
      shift
      TAG=$1
      shift
      ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      exit 1
      ;;
  esac
done

ALL_GITS=$(find $HOME -iname ".git" 2> /dev/null | sort)

# echo -e "$ALL_GITS"
echo -e "$ALL_GITS" > __temp__

# while IFS= read -r LINE; do
#   echo "<A>""$LINE""</A>"
# done < "__temp__"

# for GIT in $ALL_GITS ; do
#   echo "_a_"$GIT"_a_"
#   echo "_b_""$GIT""_b_"
# done
# for GIT in "$ALL_GITS" ; do
#   echo "_c_"$GIT"_c_"
#   echo "_d_""$GIT""_d_"
# done

# exit

GH_USER=$(grep -oP "(?<=user=).*(?=;)" $MWSHPATH/.suppressed_github)
GH_EMAIL=$(grep -oP "(?<=email=).*(?=;)" $MWSHPATH/.suppressed_github)
GL_USERCODE=$(grep -oP "(?<=usercode=).*(?=;)" $MWSHPATH/.suppressed_gitlab)
GL_STAFFNAME=$(grep -oP "(?<=staffname=).*(?=;)" $MWSHPATH/.suppressed_gitlab)

while IFS= read -r GIT; do
# for GIT in $ALL_GITS ; do

  if [[ ! -d $GIT ]] ; then
    continue
  fi

  # grep -P "(?<=$GH_USER/).*(?=.git)" $GIT/config
  if [ $(cat "$GIT/config" | grep "github" | wc -l) -eq 1 ] ; then
    ## github repo
    # cat "$GIT/config"
    if [ $SHOW_GITHUB -eq 0 ] ; then continue ; fi
    if [ $(cat "$GIT/config" | grep $GH_USER | wc -l) -eq 1 ] ; then
      ## my repo
      REPO_NAME=$(cat "$GIT/config" | grep -oP "(?<=$GH_USER/).*(?=.git)")
      REPO_TYPE=1
    else
      ## not my repo
      REPO_TYPE=0
      continue
    fi

  elif [ $(cat "$GIT/config" | grep "gitlab" | wc -l) -eq 1 ] ; then
    ## gitlab repo
    if [ $SHOW_SURREY -eq 0 ] ; then continue ; fi
    if [ $(cat "$GIT/config" | grep $GL_STAFFNAME | wc -l) -eq 1 ] ; then
      ## my repo
      REPO_NAME=$(cat "$GIT/config" | grep -oP "(?<=$GL_USERCODE/).*(?=.git)")
      REPO_TYPE=2
    else
      ## not my repo
      REPO_TYPE=0
      continue
    fi
  fi

  if [ $SEARCH -eq 1 ] ; then 
    GREP=$(echo $REPO_NAME | grep "$TAG")
    if [ $? -eq 1 ] ; then continue ; fi
  fi

  LAST=$(pwd)
  cd "$GIT"/..
  GIT_STATUS=$(git status)
  NUM_MOD=$(echo $GIT_STATUS | grep -o "modified\|deleted" | wc -l)
  if [ $NUM_MOD -ne 0 ] ; then
    # there are modified files 
    STATUS=1
  else
    STATUS=0
  fi
             # WD_00013_P1A_HELICASE_DNA_ASE_GMX
  NAME_LINE='                                  '
  # NAME_LINE='----------------------------------'
  
  if [ $SHORT -eq 0 ] ; then echo -e -n "Repo: "; fi
  # echo -e -n $colFunc$REPO_NAME$colClear" "
  if [ $REPO_TYPE -eq 1 ] ; then echo -e -n "(github) " ; fi
  if [ $REPO_TYPE -eq 2 ] ; then echo -e -n "(gitlab) " ; fi
  printf "$colFunc%s$colClear %s" $REPO_NAME "${NAME_LINE:${#REPO_NAME}}"
  if [ $STATUS -eq 0 ] ; then echo -e -n $colSuccess"No Modifications"$colClear ; fi
  if [ $STATUS -eq 1 ] ; then echo -e -n $colBold$NUM_MOD" Modified Files"$colClear ; fi
  if [ $SHORT -eq 0 ] ; then echo -e -n " Local: "; fi
  if [ $SHORT -eq 0 ] ; then 
    HM="$HOME/"
    LOCAL_DIR=$(echo -e "$GIT" | grep -oP '(?).*(?=/.git)')
    LOCAL_DIR=$(echo "$LOCAL_DIR" | sed -e "s|^$HM||")
    echo -e -n $colFile"~/$LOCAL_DIR"$colClear
  fi

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
  
  cd "$LAST"

  echo -e $colClear

# done

done < "__temp__"

rm -f __temp__*