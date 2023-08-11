#!/bin/bash

source $MSHTOOLS/colours.sh
source $MSHTOOLS/out.sh

TEST=0

while test $# -gt 0; do
  case "$1" in
    -h|--help|-u|--usage)
      echo -e "Usage for "$colFunc"rename.sh"$colClear":"
      echo -e $colArg"-d <FOLDER>"$colClear" directory within which to rename files"
      echo -e $colArg"-m <MATCH>"$colClear" filenames must contain MATCH"
      echo -e $colArg"-i <INSTR>"$colClear" target string to replace"
      echo -e $colArg"-o <OUTSTR>"$colClear" string that will be put in INSTR's place"
      echo -e $colArg"-t"$colClear" perform a dry-run (don't rename files)"
      exit 1
      ;;
    -d|--directory)
      shift
      FOLDER=$1
      shift
      ;;
    -t|--test)
      shift
      TEST=1
      ;;
    -m|--match)
      shift
      MATCH=$1
      shift
      ;;
    -o|--out)
      shift
      OUT=$1
      shift
      ;;
    -i|--in)
      shift
      IN=$1
      shift
      ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      echo -e "See "$colFunc"rename"$colClear$colArg" -h "$colClear"for usage."
      exit 1
      ;;
  esac
done

if [[ -z "$IN" ]] ; then
	errorOut "You must specify an input pattern"
	exit 2
fi

if [[ -z "$OUT" ]] ; then
	warningOut "Null output pattern"
fi

if [[ -z "$FOLDER" ]] ; then
	warningOut "Using current PWD"
	FOLDER=""
else
	FOLDER=$FOLDER"/"
	if [[ ! -d "$FOLDER" ]] ; then
		errorOut "Not a Directory"
		exit 3
	fi
fi

function rename {
	FILE=$1
	if [[ "$FILE" == *"*"* ]] ; then
		return 0
	fi
	NEWNAME=`echo $FILE | sed "s/$IN/$OUT/"`
	if [ $TEST -eq 1 ] ; then
		echo mv -v $FILE $NEWNAME
	else
		mv -v $FILE $NEWNAME
	fi
}

for FILE in $FOLDER*$MATCH*$IN*; do
	rename $FILE
done

for FILE in $FOLDER*$IN*$MATCH; do
	rename $FILE
done

exit 0
