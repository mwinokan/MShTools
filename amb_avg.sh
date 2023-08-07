#!/bin/bash

source $MSHTOOLS/load_amb.sh
source $MSHTOOLS/colours.sh
source $MSHTOOLS/out.sh


while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "Usage for "$colFunc"amb_avg.sh"$colClear":"
      echo -e $colArg"-p <FILE>"$colClear" prmtop"
      echo -e $colArg"-c <FILE>"$colClear" mdcrd"
      echo -e $colArg"-o <FILE>"$colClear" output PDB"
      echo -e $colArg"-m <FILE>"$colClear" averaging mask"
      exit 1
      ;;
    -p|--top|--parm)
      shift
      PRMTOP=$1
      shift
      ;;
    -c|--coords)
      shift
      MDCRD=$1
      shift
      ;;
    -o|--output)
      shift
      OUTPUT=$1
      shift
      ;;
    -m|--mask)
      shift
      MASK=$1
      shift
      ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      echo -e "See "$colFunc"amb_avg.sh"$colClear$colArg" -h "$colClear"for usage."
      exit 2
      ;;
  esac
done

if [[ -z "$PRMTOP" ]] ; then
  errorOut "No topology supplied."
  echo -e "See "$colFunc"amb_avg.sh"$colClear$colArg" -h "$colClear"for usage."
  exit 1
fi

if [[ -z "$MDCRD" ]] ; then
  errorOut "No trajectory supplied."
  echo -e "See "$colFunc"amb_avg.sh"$colClear$colArg" -h "$colClear"for usage."
  exit 1
fi

if [[ -z "$OUTPUT" ]] ; then
  errorOut "No output supplied."
  echo -e "See "$colFunc"amb_avg.sh"$colClear$colArg" -h "$colClear"for usage."
  exit 1
fi

if [[ ! -z "$MASK" ]] ; then
  warningOut "Using mask: $colArg$MASK"
fi

printf "parm $PRMTOP
loadcrd $MDCRD
crdaction $MDCRD average $OUTPUT $MASK
" > amb_avg.in

echo -e "Averaging frames in $colFile$MDCRD$colClear into $colFile$OUTPUT$colClear..."

$AMBERHOME/bin/cpptraj < amb_avg.in &> amb_avg.out

AMBOUT=$?

if [ $AMBOUT -ne 0 ] ; then
	headerOut "$colError""Error! See "$colFile"amb_avg.out""$colClear$colBold"
else
	# headerOut "$colSuccess""Done!""$colClear$colBold"
	exit 0
fi
