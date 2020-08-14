#!/bin/bash
# 
# Provide a summary of all the GitHub & GitLab repositories in your home directory
# 
# Part of: MShTools
# https://github.com/mwinokan/MShTools

# Libraries
source $MWSHPATH/colours.sh
source $MWSHPATH/out.sh

# Defaults:
SHORT=0
SHOW_SURREY=1
SHOW_GITHUB=1
SEARCH=0

# Parse arguments:
while test $# -gt 0; do
  case "$1" in
    -u|-h|--usage|--help)
      echo -e $colBold"Usage for "$colFunc""allgits.sh$colClear":"
      echo -e $colArg"-u -h --usage --help"$colClear" Display this usage screen"
      echo -e $colArg"-s --short          "$colClear" Briefer output"
      echo -e $colArg"-ns --no-surrey     "$colClear" Don't show Surrey GitLab repos"
      echo -e $colArg"-ng --no-github     "$colClear" Don't show github repos"
      echo -e $colArg"-n --name           "$colClear" Search for repos containing tag"
      exit 0
      ;;
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
      echo -e "Usage: $colFunc""allgits.sh$colClear $colArg--help"
      exit 1
      ;;
  esac
done

if [[ ! -e $MWSHPATH/.suppressed_github || ! -e $MWSHPATH/.suppressed_gitlab ]] ; then
  errorOut "Could not locate $MWSHPATH/.suppressed_git??b"
  errorOut "Remember to setup MShTools using $colFunc""configure.sh"
  exit 1
fi

# Get the suppressed user info
GH_USER=$(grep -oP "(?<=user=).*(?=;)" $MWSHPATH/.suppressed_github)
GH_EMAIL=$(grep -oP "(?<=email=).*(?=;)" $MWSHPATH/.suppressed_github)
GL_USERCODE=$(grep -oP "(?<=usercode=).*(?=;)" $MWSHPATH/.suppressed_gitlab)
GL_STAFFNAME=$(grep -oP "(?<=staffname=).*(?=;)" $MWSHPATH/.suppressed_gitlab)

# Find all the .git folders in home directory:
ALL_GITS=$(find $HOME -iname ".git" 2> /dev/null | sort)

# Write the list of all the .git paths to temporary file
echo -e "$ALL_GITS" > __temp__

# Loop through all .git paths
while IFS= read -r GIT; do

  # echo -e $colBold $GIT $colClear

  # If its not a directory, skip
  if [[ ! -d $GIT ]] ; then continue ; fi

  if [ $(cat "$GIT/config" | grep "github" | wc -l) -gt 0 ] ; then
    ## github repo

    if [ $SHOW_GITHUB -eq 0 ] ; then continue ; fi

    # echo -e $colBold $GIT $colClear

    if [ $(cat "$GIT/config" | grep $GH_USER | wc -l) -gt 0 ] ; then
      ## my repo

      # echo -e $colBold"X"$GH_USER"X"$colClear
      # sublime $GIT/config
      
      # REPO_NAME=$(cat "$GIT/config" | grep -oP "(?<=$GH_USER/).*(?=.git)")
      REPO_NAME=$(cat "$GIT/config" | grep -oP "(?<=https://github.com/$GH_USER/).*")
      REPO_TYPE=1
    else
      ## not my repo
      
      REPO_TYPE=0
      continue
    fi

  elif [ $(cat "$GIT/config" | grep "gitlab" | wc -l) -gt 0 ] ; then
    ## gitlab repo

    if [ $SHOW_SURREY -eq 0 ] ; then continue ; fi

    # sublime $GIT/config
    if [ $(cat "$GIT/config" | grep $GL_STAFFNAME | wc -l) -gt 0 ] ; then
      ## my repo

      REPO_NAME=$(cat "$GIT/config" | grep -oP "(?<=$GL_USERCODE/).*(?=.git)")
      REPO_TYPE=2
    elif [ $(cat "$GIT/config" | grep $GH_USER | wc -l) -gt 0 ] ; then
      ## my repo

      REPO_NAME=$(cat "$GIT/config" | grep -oP "(?<=$GH_USER/).*(?=.git)")
      REPO_TYPE=2
    else
      ## not my repo

      REPO_TYPE=0
      continue
    fi
  fi

  # If searching skip non-matches
  if [ $SEARCH -eq 1 ] ; then 
    GREP=$(echo $REPO_NAME | grep "$TAG")
    if [ $? -eq 1 ] ; then continue ; fi
  fi

  LAST=$(pwd) # store current path
  cd "$GIT"/.. # go to repo root directory

  # get the git status output:
  GIT_STATUS=$(git status) 

  # Get the number of modified files:
  NUM_MOD=$(echo $GIT_STATUS | grep -o "modified\|deleted" | wc -l | xargs)
  
  if [ $NUM_MOD -ne 0 ] ; then
    # there are modified files 
    STATUS=1
  else
    # there are no modified files 
    STATUS=0
  fi

  # Blank repo name line:
  NAME_LINE='                                  '
  
  # Write console output
  if [ $SHORT -eq 0 ] ; then echo -e -n "Repo: "; fi
  if [ $REPO_TYPE -eq 1 ] ; then echo -e -n "(github) " ; fi
  if [ $REPO_TYPE -eq 2 ] ; then echo -e -n "(gitlab) " ; fi
  printf "$colFunc%s$colClear%s" $REPO_NAME "${NAME_LINE:${#REPO_NAME}}"
  if [ $STATUS -eq 0 ] ; then echo -e -n $colSuccess"No Modifications"$colClear ; fi
  if [ $STATUS -eq 1 ] ; then echo -e -n $colBold$NUM_MOD" Modified Files"$colClear ; fi
  if [ $SHORT -eq 0 ] ; then echo -e -n " Local: "; fi
  if [ $SHORT -eq 0 ] ; then 
    HM="$HOME/"
    LOCAL_DIR=$(echo -e "$GIT" | grep -oP '(?).*(?=/.git)')
    LOCAL_DIR=$(echo "$LOCAL_DIR" | sed -e "s|^$HM||")
    echo -e -n $colFile"~/$LOCAL_DIR"$colClear
  else
    HM="$HOME/"
    LOCAL_DIR=$(echo -e "$GIT" | grep -oP '(?).*(?=/.git)')
    LOCAL_DIR=$(echo "$LOCAL_DIR" | sed -e "s|^$HM||")
    if [[ $LOCAL_DIR == "WD_"* ]] ; then

      IFS='_' # hyphen (-) is set as delimiter
      read -ra ADDR <<< "$LOCAL_DIR" # str is read into an array as tokens separated by IFS
      IFS=' ' # space is set as delimiter

      WD_NUM="${ADDR[1]}"
      WD_NUM=$(echo $WD_NUM | sed 's/^0*//')

      echo -e -n $colFile" \$(wd $WD_NUM)"$colClear
    fi
  fi

  # If its a github repo we can find out more:
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
  
  # Go back to previous directory:
  cd "$LAST"

  # Blank line
  echo -e $colClear

done < "__temp__"

# remove temporary file
rm -f __temp__*
