#!/bin/bash

# run as: source jd.sh [-v] JOBID

if [[ "${BASH_SOURCE[0]}" == "${0}" ]] ; then
		echo "Please source this script for it to work!"
		exit 2
fi

source $MWSHPATH/colours.sh
source $MWSHPATH/out.sh

if [ $# -eq 0 ] ; then 
  echo -e $colError"Wrong number of arguments provided."$colClear
  echo -e "For usage see: "$colFunc"jd.sh"$colClear$colArg" -h "$colClear
  return 1
fi

VERBOSE=0

while test $# -gt 0; do
  case "$1" in
	-h|--help)
		echo -e "Usage for "$colFunc"jd"$colClear":"
		echo -e $colFunc"jd"$colClear$colArg" [-v] <JOBID>"$colClear
		echo -e $colFunc"jd"$colClear" will change you to the directory from which a job was submitted"
		echo -e $colArg"-v"$colClear" verbose output "$colClear
		return 0
		;;
	-v|--verbose)
		VERBOSE=1
		shift
		;;
	-l|--last)
		JOBID=$(sq -nf --hist "2 weeks" | tail -n1 | awk '{print $1}')
		shift
		;;
	*)
		# put tests for integer/string here:
		JOBID=$1
		shift
		re='^[0-9]+$'
		if ! [[ $JOBID =~ $re ]] ; then
			errorOut "Jobid: "$JOBID "is not an integer!"
			return 1
		fi
		;;
		esac
done

# if verbose print the job info
if [ $VERBOSE -eq 1 ] ; then
	$MWSHPATH/sq.sh -j $JOBID
fi

# get the job's working directory
JOB_BUFFER=$(scontrol show job $JOBID 2>&1)
WORKDIR=$(echo "$JOB_BUFFER" | grep -oP "(?<=WorkDir=).*")

# change to the job's working directory
# echo $WORKDIR
cd $WORKDIR

return 0
