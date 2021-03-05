#!/bin/bash

source $MWSHPATH/out.sh

EMS=0
LG=0

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "Usage for "$colFunc"sq"$colClear":"
      echo -e $colArg"-ems <FILE>"$colClear" write EM information from Amber mdout to file"
      echo -e $colArg"-lg <FILE> <PATTERN> <N>"$colClear" parse the FILE using grep with PATTERN and output the Nth column"
      echo -e $colArg"-o <FILE>"$colClear" Specify an output"
      exit 1
      ;;
    -ems|--em-stats)
	  shift
	  INFILE=$1
	  EMS=1
	  shift
	  ;;
    -lg|--log-grep)
	  shift
	  INFILE=$1
	  shift
	  PATTERN=$1
	  shift
	  COLUMN=$1
	  shift
	  LG=1
	  ;;
    -o)
	  shift
	  OUTFILE=$1
	  shift
	  ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      echo -e "See "$colFunc"sq"$colClear$colArg" -h "$colClear"for usage."
      exit 2
      ;;
  esac
done

if [ $EMS -eq 1 ] ; then

	if [ -z $INFILE ] ; then
		errorOut "No input given"
		exit 1
	fi
	if [ -z $OUTFILE ] ; then
		warningOut "Using default output$colFile min_stats.dat"
		OUTFILE="min_stats.dat"
	fi

	grep NSTEP $INFILE | head -n1 > $OUTFILE
	grep  -A1 NSTEP $INFILE | grep -v NSTEP | grep -v "\-\-" | head --lines=-1 >> $OUTFILE

	headerOut "Wrote "$(cat $OUTFILE | grep -v NSTEP | wc -l)" entries to $colFile"$OUTFILE

	exit 0

fi

if [ $LG -eq 1 ] ; then

	if [ -z $INFILE ] ; then
		errorOut "No input given"
		exit 1
	fi
	if [ -z $OUTFILE ] ; then
		warningOut "Using default output$colFile "$PATTERN"_stats.dat"
		OUTFILE=$PATTERN"_stats.dat"
	fi

	AWKSTR="{print \$$COLUMN}"

	echo "# $PATTERN from $INFILE" > $OUTFILE

	grep "$PATTERN" $INFILE | awk "$AWKSTR" | head --lines=-1 >> $OUTFILE
	# grep  -A1 NSTEP $INFILE | grep -v NSTEP | grep -v "\-\-" >> $OUTFILE

	headerOut "Wrote "$(cat $OUTFILE | grep -v $PATTERN | wc -l)" entries to $colFile"$OUTFILE

	exit 0

fi
