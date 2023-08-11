#!/bin/bash

source $MSHTOOLS/out.sh

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
      exit 1
      ;;
    *)
	  break
      ;;
  esac
done

RESULT=$(sbatch $@)
EXIT=$?

if [[ "$RESULT" = "Submitted batch job"* ]] ; then
	$MSHTOOLS/sq.sh -j $(echo "$RESULT" | awk '{print $4}')
else
	errorOut "Problem submitting job:"
	echo "$RESULT"
	exit $EXIT
fi
