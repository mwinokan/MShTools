#!/bin/bash

# RUNDIR=2CX_umb2_75w_PM6_new
# RUNDIR=2CX_umb_75w_PM6_new_2
# RUNDIR=2CX_umb_75w_PM6_old_2
# RUNDIR=2CX_umb3_75w_PM6_new
# RUNDIR=2CX_umb2_75w_PM6_old2
# RUNDIR=2CX_umb3_75w_PM6_old2

EXTEND=0
FORCE_DOUBLE=200
OUTKEY="wham2d"

# Parse arguments:
while test $# -gt 0; do
  case "$1" in
    -u|-h|--usage|--help)
      echo -e $colBold"Usage for "$colFunc""run_wham.sh$colClear":"
      echo -e $colArg"-u -h --usage --help"$colClear" Display this usage screen"
      echo -e $colArg"-d --directory      "$colClear" Directory"
      echo -e $colArg"-b --bins           "$colClear" Number of bins"
      exit 0
      ;;
    -d|--directory)
      shift
      RUNDIR=$1
      shift
      ;;
    -b|--bins)
      shift
      BINS=$1
      shift
      ;;
    -f|--force-double)
      shift
      FORCE_DOUBLE=$1
      shift
      ;;
    -a1|--add1)
      shift
      EXTEND=1
      ;;
    -a2|--add2)
      shift
      EXTEND=2
      ;;
    -o|--outkey)
      shift
      OUTKEY=$1
      shift
      ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      echo -e "Usage: $colFunc""run_wham.sh$colClear $colArg--help"
      exit 1
      ;;
  esac
done

# BINS="75"

# FORCE_DOUBLE=200
TOL="0.0001"
TEMP=300

source $MWSHPATH/out.sh

if [[ -z "$RUNDIR" ]] ; then
  errorOut "No directory specified"
  exit 2
fi

if [[ -z "$BINS" ]] ; then
  errorOut "No bins specified"
  exit 3
fi

varOut "RUNDIR" $RUNDIR
varOut "BINS" $RUNDIR

### WHAM-2D

FIRST=1

echo "" > $RUNDIR/"$OUTKEY"_meta.dat

for folder in $RUNDIR/window_??; do
	# echo $folder
	file=$(ls $folder/*rco)
	
	COORDS=$(grep -oP '(?<=r2=).*(?=,)' $folder/*RST | head -n2)

	COORD_X=$(echo $COORDS | awk '{print $1}')
	COORD_Y=$(echo $COORDS | awk '{print $2}')

	if [ $FIRST -eq 1 ] ; then
		START_X=$COORD_X
		START_Y=$COORD_Y
		FIRST=0
	fi

	END_X=$COORD_X
	END_Y=$COORD_Y

	echo $file $COORD_X $COORD_Y $FORCE_DOUBLE $FORCE_DOUBLE >> $RUNDIR/"$OUTKEY"_meta.dat

done

if [ $EXTEND -eq 1 ] ; then
  START_X=-1.5
  START_Y=-1.5
  END_X=1.5
  END_Y=1.5
elif [ $EXTEND -eq 2 ] ; then
  START_X=-2.0
  START_Y=-2.0
  END_X=2.0
  END_Y=2.0
fi

# $WHAM_HOME/wham-2d/wham-2d Px=0 $START_X $END_X $BINS Py=0 $START_Y $END_Y $BINS $TOL $TEMP 0 $RUNDIR/"$OUTKEY"_meta.dat $RUNDIR/"$OUTKEY"_result_mask.dat 1 > $RUNDIR/"$OUTKEY"_mask.log
$WHAM_HOME/wham-2d/wham-2d Px=0 $START_X $END_X $BINS Py=0 $START_Y $END_Y $BINS $TOL $TEMP 0 $RUNDIR/"$OUTKEY"_meta.dat $RUNDIR/"$OUTKEY"_result.dat 0 > $RUNDIR/"$OUTKEY".log

#Number of windows = 66

WINDOWS=$(grep -oP '(?<=Number of windows = ).*' $RUNDIR/"$OUTKEY".log)

echo "#WINDOWS="$WINDOWS

let 'WINDOWS_PLUS1 = WINDOWS + 1'

tail -n"$WINDOWS_PLUS1" $RUNDIR/"$OUTKEY".log | grep -v "Wall" | sed 's/# //' > $RUNDIR/"$OUTKEY"_slice.dat
