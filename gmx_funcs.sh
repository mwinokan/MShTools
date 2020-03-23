#!/bin/bash

########### COLOURS

source $MWSHPATH/colours.sh
source $MWSHPATH/out.sh
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
        GMX_RET=$?
        echo -ne $colBold
      else 
        echo $GENION_GROUP | gmx_mpi $COMMAND $@ > _$COMMAND$LOGNUM.log 2>&1
        GMX_RET=$?
      fi
      ;;
    gyrate)
      VARIABLE=$1
      shift
      echo "$VARIABLE 0" | gmx_mpi $COMMAND $@ > _$COMMAND$LOGNUM.log 2>&1
      GMX_RET=$?
      ;;
    energy|trjconv)
      if [[ "$1" == "-inter" ]] ; then 
        shift
        gmx_mpi $COMMAND $@
        GMX_RET=$?
      else
        VARIABLE=$1
        shift
        echo "$VARIABLE 0" | gmx_mpi $COMMAND $@ > _$COMMAND$LOGNUM.log 2>&1
        GMX_RET=$?
      fi
      ;;
    rms)
      VARIABLE=$1
      shift
      echo "$VARIABLE $VARIABLE" | gmx_mpi $COMMAND $@ > _$COMMAND$LOGNUM.log 2>&1
      GMX_RET=$?
      ;;
    pdb2gmx)
      while test $# -gt 0; do
        case "$1" in
          -2ter)
            shift
            TER1=$1
            shift
            TER2=$1
            shift
            echo "$TER1 $TER2" | gmx_mpi pdb2gmx $@ -ter > _$COMMAND$LOGNUM.log 2>&1
            GMX_RET=$?
            break
            ;;
          -nter)
            shift
            TERS="$1"
            shift
            echo """$TERS""" | gmx_mpi pdb2gmx $@ -ter > _$COMMAND$LOGNUM.log 2>&1
            GMX_RET=$?
            break
            ;;
          -inter)
            shift
            gmx_mpi pdb2gmx $@ -ter
            GMX_RET=$?
            break
            ;;
          *)
            gmx_mpi pdb2gmx $@ > _$COMMAND$LOGNUM.log 2>&1
            GMX_RET=$?
            break
            ;;
        esac
      done
      ;;
    *)
      gmx_mpi $COMMAND $@ > _$COMMAND$LOGNUM.log 2>&1
      GMX_RET=$?
      ;;
  esac
  gmxRet $GMX_RET
  return 0
}

########### ANALYSIS

function totalCharge {
  QTOT=$(grep qtot $1 | tail -n1 | grep -oP '(?<=qtot).*')
  echo -e  $colFile$2$colClear$colVarName" Total charge $colClear="$colResult"$QTOT"$colClear
}

function numAtomsInResidue {
  nA=$(grep $1 $2 | wc -l)
  return $nA
}

function groupStats {
  nSys=$(grep "Group" $1 | grep " $2)" | grep -oP "(?<=has ).*(?= elements)")
  varOut $2 $nSys atoms
}

function genionSummary {
  nRep=$(grep "solute molecules in topology file" _genion*.log | sed "s/Replacing/Replaced/")
  echo $nRep
  # echo "Replaced "$nRep" with " $(grep -P "(?= by ).*(?=ions.)" _genion*.log)

#   Processing topology
# Replacing 46 solute molecules in topology file (topol.top)  by 46 NA and 0 CL ions.
}

function numAtomsInDNA {
  numAtomsInResidue "DG" $1; nG=$?
  numAtomsInResidue "DC" $1; nC=$?
  numAtomsInResidue "DT" $1; nT=$?
  numAtomsInResidue "DA" $1; nA=$?
  let "nTot = $nG + $nC + $nT + $nA"
  return $nTot
}

function numAtomsInProtein {
  numAtomsInResidue "ALA" $1; nTot=$?
  echo $nTot
  numAtomsInResidue "CYS" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "ASP" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "GLU" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "PHE" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "GLY" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "HIS" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "ILE" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "LYS" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "LEU" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "MET" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "ASN" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "PRO" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "GLN" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "ARG" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "SER" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "THR" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "VAL" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "TRP" $1; let "nTot = $nTot + $?"
  echo $nTot
  numAtomsInResidue "TYR" $1; let "nTot = $nTot + $?"
  echo $nTot
  return $nTot
}

function minimStats {
  COMMAND=$1
  LOGNUM=$2
  tail -n7 _$COMMAND$LOGNUM.log | head -n4
}

function xvg2png {
  GPSTRING=""
    while test $# -gt 0; do
      case "$1" in
        -h|--help)
          echo -e "Usage for "$colFunc"xvg2png"$colClear":"

          echo -e "\n""Basic:"
          flagOut "-f|--filename" "<STRING>" "Plot <STRING>.xvg"
          flagOut "-o|--output" "<STRING>" "Produce <STRING>.png"
          flagOut "-xl|--xlabel" "<STRING>" "Set the x-label"
          flagOut "-yl|--ylabel" "<STRING>" "Set the y-label"
          flagOut "-xt|--xtics" "<FLOAT>" "Set the frequency of the x ticks"
          flagOut "-yt|--ytics" "<FLOAT>" "Set the frequency of the y ticks"
          flagOut "-xs|--xscientific" "" "Show the x-axis values in scientific format"
          flagOut "-ys|--yscientific" "" "Show the y-axis values in scientific format"
          flagOut "-xmin" "<FLOAT>" "Set the lower bound of the x-axis range"
          flagOut "-xmax" "<FLOAT>" "Set the upper bound of the x-axis range"
          flagOut "-ymin" "<FLOAT>" "Set the lower bound of the y-axis range"
          flagOut "-ymax" "<FLOAT>" "Set the upper bound of the y-axis range"
          flagOut "-l|--lognum" "<INTEGER>" "Set the logfile to '_gp<INTEGER>.log'"
          
          echo -e "\n""Two xvg's on the same axes:"
          flagOut "-dp|--double-plot" "<STRING>" "Produce <STRING>.png"
          flagOut "-f2|--filename2" "<STRING>" "Also plot <STRING>.xvg"
          flagOut "-t1|--title1" "<STRING>" "Title for first datafile"
          flagOut "-t2|--title2" "<STRING>" "Title for second datafile"
          
          echo -e "\n""Analysis:"
          flagOut "-ra|--running-average" "" "Running average of last five data points"
          flagOut "-cf|--constfit" "" "Fit y=c to the data"
          flagOut "-fmin" "<FLOAT>" "Set the lower bound of the fitting range"
          flagOut "-fmax" "<FLOAT>" "Set the upper bound of the fitting range"

          # finishUp 0
          return
          exit
          ;;
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
        -l|--lognum)
          shift
          LOGNUM=$1
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