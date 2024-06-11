#!/bin/bash

source $MSHTOOLS/colours.sh

LOOP=0
# DIR=0
# NO_ERRORS=0
EXTENSION=.log

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "Usage for "$colFunc"results.sh"$colClear":"
      echo -e $colFunc"wd"$colClear$colArg" [-l] [-o <FILE>]"$colClear
      echo -e $colArg"-l"$colClear" auto-refreshing output"
      # echo -e $colArg"-o <FILE>"$colClear" open files in sublime"
      # echo -e $colArg"-op2g "$colClear" open pdb2gmx log in sublime"
      exit 5
      ;;
    -l)
      LOOP=1
      shift
      ;;
    # -d)
    #   DIR=1
    #   shift
    #   ;;
    # -o|--open)
    #   shift
    #   OPEN_FILES=$OPEN_FILES" $1"
    #   shift
    #   ;;
    # -ne|--no-errors)
    #   shift
    #   NO_ERRORS=1
    #   ;;
    *)
      break
      ;;
  esac
done

USERCODE=$(whoami)

if [ $# -eq 0 ]
then 
  # JOB_NUM=$(cat last_job)
  # echo -e $colError"No job number!"$colClear
  # exit 1
  LAST=1
else
  LAST=0
  JOB_NUM=$1
fi

FILE_PATTERN=$JOB_NUM

if [[ ! -z $MSHTOOLS_LOG_PATH ]] ; then
  FILE_PATTERN=$MSHTOOLS_LOG_PATH/$FILE_PATTERN
fi

if [ $LAST -eq 1 ] ; then
  if [[ -z $MSHTOOLS_LOG_PATH ]] ; then
    echo "Must pass a JOBID or set MSHTOOLS_LOG_PATH"
    exit 2
  fi
  LOG_FILE=$(ls -ltr $MSHTOOLS_LOG_PATH/*$EXTENSION | tail -n1 | awk '{print $9}')
  # echo $LOG_FILE
  SED_STR=s/$EXTENSION//
  # echo basename $LOG_FILE' | 'sed $SED_STR
  JOB_NUM=$(basename $LOG_FILE | sed $SED_STR)
else
  LOG_FILE=$FILE_PATTERN$EXTENSION
fi

# echo $JOB_NUM

JOB_NUM=$(basename $JOB_NUM)
JOB_NUM=${JOB_NUM:0:6}

sq.sh -u $USERCODE -j $JOB_NUM

ALTHOST=$(nslookup `hostname` | grep "Name:" | awk '{print $2}')

while :
do
  if [ $LOOP -eq 1 ] ; then 
    clear 
  fi
    if [ $(squeue -l -u $USERCODE | grep $JOB_NUM | wc -l ) -ne 0 ] ; then
      echo -e $colBold"SLURM Queue"$colClear":"
      sq.sh -u $USERCODE | grep $JOB_NUM
    fi

  # O_FILE=$FILE_PATTERN*.o
  # E_FILE=$FILE_PATTERN*.e
  
  LOG_LINES=$(wc -l $LOG_FILE | awk '{ print $1 }')
  
  # O_LINES=$(wc -l $O_FILE | awk '{ print $1 }')
  # E_LINES=$(wc -l $E_FILE | awk '{ print $1 }')



  echo -e "\n"$colSuccess"Log file: "$LOG_FILE" [ "$LOG_FILE" lines ]"$colClear
  # cat -n $O_FILE
  cat -n $LOG_FILE

  # if [ $NO_ERRORS = 0 ] ; then
    # echo -e "\n"$colError"Error file: "$E_FILE" [ "$E_LINES" lines ]"$colClear
  # cat -n $E_FILE
  # fi

  if [ $LOOP -eq 0 ] ; then break ; fi
  
  echo -e "\nPress [CTRL+C] to stop.."
  sleep 1
done

# if [ ! -z $OPEN_FILES ] ; then
#   for FILE in $OPEN_FILES ; do
#     sublime $JOB_NUM/$FILE
#   done
# fi