#!/bin/bash

source $MSHTOOLS/out.sh

if [[ ! -z $MSHTOOLS_LOG_PATH ]] ; then
	EXTRA="--output=$MSHTOOLS_LOG_PATH/%j.log --error=$MSHTOOLS_LOG_PATH/%j.log"
else
	EXTRA=""
fi

for _ in once; do
	ALTHOST=$(nslookup `hostname` | grep "Name:" | awk '{print $2}')
	if [[ $ALTHOST == *scarf* ]] ; then
	  errorOut "SCARF not supported"
	  exit 1
	elif [[ $ALTHOST == uan01 ]] ; then
	  errorOut "SCARF not supported"
	  exit 1
	elif [[ $ALTHOST == ln0* ]] ; then
		break
	elif [[ $ALTHOST == *.eureka2.surrey.ac.uk ]] ; then
		break
	elif [[ $ALTHOST == *.swmgmt.eureka ]] ; then
		break
	elif [[ $ALTHOST == cs05r-sc-cloud-30.diamond.ac.uk ]] ; then
		break
	else
	  errorOut "Unrecognised cluster"
	  exit 2
	fi
	break
done

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "A pretty wrapper for sbatch"
      echo -e "sb.sh <FILE>"
      echo -e "Set the environment variable MSHTOOLS_LOG_PATH to specify a location for the logs"
      exit 1
      ;;
    *)
	  break
      ;;
  esac
done

echo sbatch $EXTRA $@
RESULT=$(sbatch $EXTRA $@)
EXIT=$?

if [[ "$RESULT" = "Submitted batch job"* ]] ; then
	$MSHTOOLS/sq.sh -u $(whoami) -j $(echo "$RESULT" | awk '{print $4}')
else
	errorOut "Problem submitting job:"
	echo "$RESULT"
	exit $EXIT
fi
