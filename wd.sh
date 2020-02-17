#!/bin/bash

source $MWSHPATH/colours.sh
source $MWSHPATH/directory_exists.sh

# check for arguments:

if [ $# -eq 0 ] || [ $# -gt 2 ]
then 
  echo -e $colError"Wrong number of arguments provided."$colClear
  echo -e "For usage see: "$colFunc$0$colClear$colArg" -h "$colClear
  return 1
fi

RETURN_PATH=0
RETURN_DIR=0

# new argument switch

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "Usage for "$colFunc"wd"$colClear":"
      echo -e $colFunc"wd"$colClear$colArg" [-d|-p] <WD_NUM>/<WD_TAG>"$colClear
      echo -e $colFunc"wd"$colClear" allows you to change to a working directory with pattern "$colFile"WD_<NUMBER>_<TAGS>"$colClear
      echo -e " by giving its number or list all directories with a given tag"
      echo -e $colArg"-d"$colClear" return the name of the directory instead of running "$colFunc"cd$colClear"
      echo -e $colArg"-p"$colClear" return path to directory instead of running "$colFunc"cd$colClear"
      echo -e $colArg"-l"$colClear" change to directory with the largest number"
      return 5
      ;;
    -d)
      RETURN_DIR=1
      shift
      ;;
    -p)
      RETURN_PATH=1
      shift
      ;;
    -l)
      cd $(ls -d ~/WD_* | tail -n 1)
      return 0
      ;;
    -a)
      LAST=$(pwd)
      cd
      ls -d WD_*
      cd $LAST
      return 0
      ;;
    *)
      break
      ;;
  esac
done

# check if argument is an integer:

re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then

  # If a string is given then list all folders containing the tag

  # cd $HOME

  STR=$(echo "$1" | awk '{print toupper($0)}')

  PWD_LAST=$(pwd)
  
  cd $HOME

  LS_RESULT=$(ls -d WD_**$STR* 2>/dev/null)

  cd $PWD_LAST

  if [ $? -ne 0 ] ; then

    echo -e $colWarning$"No working directories found containing "$colClear"'"$colArg$STR$colClear"'"
    return 2

  fi

  echo -e $colResult"$LS_RESULT"$colClear

  return 0

else

  # if a working directory number is given attempt to change into that folder:

  WD_NUM=$(printf "%05d\n" $1)

  # Check if the directory exists
  directoryExistsQuiet ~/WD_$WD_NUM*
  DIR_EX_RET=$?

  PWD_LAST=$(pwd)
  cd $HOME
  WD_DIR=$(ls -d WD_$WD_NUM*)
  cd $PWD_LAST

  if [ $DIR_EX_RET -eq 1 ] ; then

    if [ $RETURN_PATH -eq 1 ] ; then

      echo $HOME/$WD_DIR

      return 0
      
    elif [ $RETURN_DIR -eq 1 ] ; then

      echo $WD_DIR

      return 0

    else
    
      cd $HOME/$WD_DIR

      echo -e "Changed into directory: "$colFile$WD_DIR$colClear

      return 0

    fi

  else

    echo -e $colError"No directory "$colFile"~/WD_"$WD_NUM"*"$colError" found."$colClear
    return 3

  fi

fi

echo -e $colWarning"Failed switch, no result."$colClear