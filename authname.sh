#!/bin/bash

NUM_ENTRIES=5
BIB_LESS=0
# FILE=master.bib
FILE=$(ls -lt *.bib | head -n1 | awk '{print $9}')

source $MWSHPATH/colours.sh

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "Usage for "$colFunc"authname.sh"$colClear":"
      echo -e $colArg"-n <N>"$colClear" process last N entries of bib file"
      echo -e $colArg"-b|--bib-less"$colClear" do not output bibNames"
      echo -e $colArg"-f <FILE>"$colClear" use <FILE> instead of most recent of *.bib"
      exit 5
      ;;
    -n)
      shift
      NUM_ENTRIES=$1
      shift
      ;;
    -b|--bib-less)
      shift
      BIB_LESS=1
      ;;
    -f|--file)
      shift
      FILE=$1
      shift
      ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      echo -e "See "$colFunc"authname.sh"$colClear$colArg" -h "$colClear"for usage."
      exit 4
      ;;
  esac
done

mkdir -p .authname

grep "@" $FILE | tail -n $NUM_ENTRIES | grep -oP "(?<={).*(?=,)" > .authname/bibnames
grep "author" $FILE | tail -n $NUM_ENTRIES | grep -oP "(?<={).*(?=})" > .authname/authlists

while read BIB_NAME; do

  BIB_NAMES="$BIB_NAMES $BIB_NAME"

done < .authname/bibnames

function parseAuthList {
  INPUT=$@

  # INPUT="Banerjee, Ruma and Dybala-Defratyka, Agnieszka and Paneth, Piotr Dude"

  INPUT="and $INPUT and"

  LAST_NAMES=$(echo "$INPUT" | grep -oP "(?<=and).*?(?=,)")

  FIRST_NAMES=$(echo "$INPUT" | grep -oP "(?<=,).*?(?=and)")
  INITIALS=$(echo -e "$FIRST_NAMES" | sed -e 's/$/ /' -e 's/\([^ ]\)[^ ]* /\1/g' -e 's/^ *//')

  COUNTER=1
  AUTH_LIST=""

  for LAST in $LAST_NAMES; do
    INITS=$(echo $INITIALS | awk -v field="$COUNTER" '{print $field}')
    echo "$INITS $LAST"
    AUTH_LIST=$AUTH_LIST"$INITS $LAST, "
    let COUNTER=COUNTER+1
  done

  AUTH_LIST=$(echo $AUTH_LIST | grep -oP ".*(?=,)")
  echo $AUTH_LIST 
}

COUNTER=1

while read AUTH_LIST; do

  if [ $BIB_LESS -ne 1 ] ; then
    echo -ne "\033[1m"$(echo $BIB_NAMES | awk -v field="$COUNTER" '{print $field}')"\033[0m "
  fi
  echo -e $(parseAuthList "$AUTH_LIST")
  let COUNTER=COUNTER+1

done < .authname/authlists