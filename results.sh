#!/bin/bash

source $MWSHPATH/colours.sh

LOOP=0
DIR=0
NO_ERRORS=0

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "Usage for "$colFunc"results.sh"$colClear":"
      echo -e $colFunc"wd"$colClear$colArg" [-l] [-o <FILE>]"$colClear
      echo -e $colArg"-l"$colClear" auto-refreshing output"
      echo -e $colArg"-o <FILE>"$colClear" open files in sublime"
      echo -e $colArg"-op2g "$colClear" open pdb2gmx log in sublime"
      exit 5
      ;;
    -l)
      LOOP=1
      shift
      ;;
    -d)
      DIR=1
      shift
      ;;
    -o|--open)
      shift
      OPEN_FILES=$OPEN_FILES" $1"
      shift
      ;;
    -ne|--no-errors)
      shift
      NO_ERRORS=1
      ;;
    -op2g|--open-pdb2gmx)
      shift
      OPEN_FILES=$OPEN_FILES" gromacs.pdb2gmx.log"
      ;;
    *)
      break
      ;;
  esac
done

if [ $# -eq 0 ]
then 
  # JOB_NUM=$(cat last_job)
  echo -e $colError"No job number!"$colClear
  exit 1
else
  JOB_NUM=$1
fi

sq.sh -j $JOB_NUM

FILE_PATTERN=$JOB_NUM

JOB_NUM=$(basename $JOB_NUM)
JOB_NUM=${JOB_NUM:0:6}

if [[ $(hostname) == *scarf* ]] ; then
  USERCODE=$(grep -oP "(?<=user=).*(?=;)" $MWSHPATH/.suppressed_extern)
else
  USERCODE=$(grep -oP "(?<=usercode=).*(?=;)" $MWSHPATH/.suppressed_gitlab)
fi

while :
do
  if [ $LOOP -eq 1 ] ; then 
    clear 
  fi
    # JOBNUM=$(tail -1 run_log 2>/dev/null | grep -oP '.*?(?=:)' | head -1 2>/dev/null)
    if [ $(squeue -l -u $USERCODE | grep $JOB_NUM | wc -l ) -ne 0 ] ; then
      # LOG_ENTRY=$(tail -1 run_log 2>/dev/null)
      # if [ $? -eq 0 ] ; then echo -e "\n"$colBold"Log entry"$colClear": "$colArg$LOG_ENTRY$colClear ; fi
      # if [ $DIR -eq 1 ] ; then
      #   echo -e $colBold"\nFiles in "$colFile""$JOB_NUM$colClear":"
      #   ls --color=auto -xX $JOB_NUM
      # fi
      echo -e $colBold"SLURM Queue"$colClear":"
      # squeue -l -u $USERCODE
      sq.sh | grep $JOB_NUM
      # echo -e $colBold"\nFiles in "$colFile""\$PSCRATCH/$JOB_NUM$colClear":"
      # ls --color=auto -xX $PSCRATCH/$JOB_NUM
    fi
  # else
  #   LOG_ENTRY=$(tail -1 run_log 2>/dev/null)
  #   if [ $? -eq 0 ] ; then echo -e "\n"$colBold"Log entry"$colClear": "$colArg$LOG_ENTRY$colClear ; fi
  #   echo -e $colBold"\nFiles in "$colFile""$JOB_NUM$colClear":"
  #   ls --color=auto -xX $JOB_NUM
  # fi

  # sq.sh | grep $JOB_NUM

  O_FILE=$FILE_PATTERN*.o
  E_FILE=$FILE_PATTERN*.e
  
  # CAT_TEST=$(cat $JOB_NUM.o 2>/dev/null)
  # if [ $? -eq 0 ] ; then
  #   O_FILE=$JOB_NUM.o
  # else
  #   O_FILE=$JOB_NUM/$JOB_NUM.o
  # fi

  # CAT_TEST=$(cat $JOB_NUM.e 2>/dev/null)
  # if [ $? -eq 0 ] ; then
  #   E_FILE=$JOB_NUM.e
  # else
  #   E_FILE=$JOB_NUM/$JOB_NUM.e
  # fi

  O_LINES=$(wc -l $O_FILE | awk '{ print $1 }')
  E_LINES=$(wc -l $E_FILE | awk '{ print $1 }')

  echo -e "\n"$colSuccess"Output file: "$O_FILE" [ "$O_LINES" lines ]"$colClear
  cat -n $O_FILE

  if [ $NO_ERRORS = 0 ] ; then
    echo -e "\n"$colError"Error file: "$E_FILE" [ "$E_LINES" lines ]"$colClear
    cat -n $E_FILE
  fi

  if [ $LOOP -eq 0 ] ; then break ; fi
  
  echo -e "\nPress [CTRL+C] to stop.."
  sleep 1
done

if [ ! -z $OPEN_FILES ] ; then
  for FILE in $OPEN_FILES ; do
    sublime $JOB_NUM/$FILE
  done
fi