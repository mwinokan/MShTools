#!/bin/bash

########### COLOURS

source $MWSHPATH/colours.sh
colBold="\033[1m"
colHead="\033[1;4m"
colClear="\033[0m"

########### NON-GROMACS

function finishUp {
  if [ $1 -eq 0 ] ; then 
    echo -e $colSuccess"Exiting $1"$colClear
  else 
    echo -e $colError"Exiting $1"$colClear 
  fi
  if [[ -z ${SLURM_JOBID} ]] ; then
    if [[ $- == *i* ]] ; then
      return $1
    else
      exit $1
    fi
  else
    rm \#*
    mkdir ${SLURM_SUBMIT_DIR}/${SLURM_JOBID}
    cp -r * ${SLURM_SUBMIT_DIR}/${SLURM_JOBID}/
    mv ${SLURM_SUBMIT_DIR}/${SLURM_JOBID}.? ${SLURM_SUBMIT_DIR}/${SLURM_JOBID}/
    exit $1
  fi
}

function gmxRet {
  GMX_RET=$1; echo -ne "Done, exit code: "
  if [ $GMX_RET -eq 0 ] ; then 
    echo -e $colSuccess"$GMX_RET "$colClear$(/usr/bin/date)
  else 
    echo -e $colError"$GMX_RET "$colClear$(/usr/bin/date)
  fi
  
  if [ $GMX_RET -ne 0 ] ; then finishUp $THIS_SECTION; fi
}

function removeWater {
  echo -e $colBold"Removing water from PDB."$colClear
  grep -v HOH $1 > $2
}

# breakCheck $thisSection $START_AFTER $STOP_AFTER
function breakCheck {
  THIS_SECTION=$1
  # if this state is less than $START_AFTER
  if [ $1 -lt $2 ] ; then 
    # echo "Not started. Omitting $1."
    return 1
  fi
  # if this state is greater than $STOP_AFTER
  if [ $1 -gt $3 ] ; then 
    # echo "Program finished."
    finishUp 0 
  fi
  # echo "Running $1."
  return 0
}

# fancyOut <HEADER>
ECHO_STR=" >>> "
function fancyOut {
  echo -e $colBold$ECHO_STR$1" [ "$(/usr/bin/date)" ] "$colClear
}

########### GROMACS

function gmx_max {
  COMMAND=$1
  shift
  LOGNUM=$1
  shift
  echo -ne $colBold"Running $COMMAND $LOGNUM... "
  case "$COMMAND" in
    genion)
      if [[ -z $GENION_GROUP ]] ; then 
        echo -e $colClear
        gmx_mpi $COMMAND $@
        echo -ne $colBold
      else 
        echo $GENION_GROUP | gmx_mpi $COMMAND $@ > _$COMMAND$LOGNUM.log 2>&1
      fi
      ;;
    energy|trjconv|gyrate)
      VARIABLE=$1
      shift
      echo "$VARIABLE 0" | gmx_mpi $COMMAND $@ > _$COMMAND$LOGNUM.log 2>&1
      ;;
    rms)
      VARIABLE=$1
      shift
      echo "$VARIABLE $VARIABLE" | gmx_mpi $COMMAND $@ > _$COMMAND$LOGNUM.log 2>&1
      ;;
    *)
      gmx_mpi $COMMAND $@ > _$COMMAND$LOGNUM.log 2>&1
      ;;
  esac
  gmxRet $?
  return 0
}

########### ANALYSIS

function totalCharge {
  QTOT=$(grep qtot $1 | tail -n1 | grep -oP '(?<=qtot).*')
  echo -e "Total charge = $QTOT"
}

function minimStats {
  COMMAND=$1
  LOGNUM=$2
  tail -n7 _$COMMAND$LOGNUM.log | head -n4
}

function xvg2png {
  LOGNUM=$1
  shift
  GPSTRING=""
    while test $# -gt 0; do
      case "$1" in
        -f|-f1|--filename|--filename1)
          shift
          PLOTFILE=$1
          GPSTRING=$GPSTRING"filename='$1';"
          shift
          ;;
        -f2|--filename2)
          shift
          GPSTRING=$GPSTRING"filename2='$1';"
          shift
          ;;
        -o|--output)
          shift
          GPSTRING=$GPSTRING"output='$1';"
          shift
          ;;
        -t1|--title1)
          shift
          GPSTRING=$GPSTRING"title1='$1';"
          shift
          ;;
        -t2|--title2)
          shift
          GPSTRING=$GPSTRING"title2='$1';"
          shift
          ;;
        -dp|--doubleplot)
          shift
          GPSTRING=$GPSTRING"doubleplot=1;"
          ;;
        -xl|--xlabel)
          shift
          GPSTRING=$GPSTRING"xlab='$1';"
          shift
          ;;
        -yl|--ylabel)
          shift
          GPSTRING=$GPSTRING"ylab='$1';"
          shift
          ;;
        -xt|--xtics)
          shift
          GPSTRING=$GPSTRING"xtic=$1;"
          shift
          ;;
        -yt|--ytics)
          shift
          GPSTRING=$GPSTRING"ytic=$1;"
          shift
          ;;
        -xs|--xscientific)
          shift
          GPSTRING=$GPSTRING"xsci=1;"
          ;;
        -ys|--yscientific)
          shift
          GPSTRING=$GPSTRING"ysci=1;"
          ;;
        -ra|--running-average)
          shift
          GPSTRING=$GPSTRING"runavg=1;"
          ;;
        -xmin)
          shift
          GPSTRING=$GPSTRING"xmin=$1;"
          shift
          ;;
        -xmax)
          shift
          GPSTRING=$GPSTRING"xmax=$1;"
          shift
          ;;
        -ymin)
          shift
          GPSTRING=$GPSTRING"ymin=$1;"
          shift
          ;;
        -ymax)
          shift
          GPSTRING=$GPSTRING"ymax=$1;"
          shift
          ;;
        -cf|--constfit)
          shift
          GPSTRING=$GPSTRING"constfit=1;"
          ;;
        -fmin|--fitmin)
          shift
          GPSTRING=$GPSTRING"fitmin=$1;"
          shift
          ;;
        -fmax|--fitmax)
          shift
          GPSTRING=$GPSTRING"fitmax=$1;"
          shift
          ;;
        *)
          echo -e $colError"Unrecognised flag: "$colArg$1$colClear
          shift
          finishUp 2
          ;;
      esac
    done
  echo -ne $colBold"Plotting $PLOTFILE... "
  gnuplot -e "$GPSTRING" $MWGPTPATH/xvg2png.gp > _gp$LOGNUM.log 2>&1
  gmxRet $?
}