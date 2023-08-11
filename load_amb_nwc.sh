#!/bin/bash

##########

# CLI

REPLACE_DFT=0
DFT_TEMPLATE="dft.nw"

NPROC_NWC=28
EXLINE=""
EXEXLINE=""
PRETASK=""

KILL=0

source $MSHTOOLS/colours.sh
source $MSHTOOLS/out.sh

while test $# -gt 0; do
	case "$1" in
		-h|-help|--help|-usage|--usage)
			echo -e $colBold"Methods for "$colFunc"load_amb_nwc.sh"$colClear":"
			echo 
			echo -e $colFunc"load_amb_nwc.sh"$colClear$colClear" "
			echo -e "Load AMBER & NWChem with all available threads (not recommended) "
			echo 
			echo -e $colFunc"load_amb_nwc.sh"$colClear$colArg" -np <N> "$colClear
			echo -e "Load AMBER & NWChem with N threads for NWChem "
			echo 
			echo -e $colFunc"load_amb_nwc.sh"$colClear$colArg" -dft "$colClear
			echo -e "Load AMBER & NWChem and take dft block from ./dft.nw "
			echo 
			echo -e $colFunc"load_amb_nwc.sh"$colClear$colArg" -dft --template <FILE>"$colClear
			echo -e "Load AMBER & NWChem and take dft block from <FILE> "
			echo 
			echo -e $colArg" -xnwi <COMMAND>"$colClear
			echo -e "Append command to nwchem input file"
			echo
			echo -e $colArg" -xnwe <COMMAND>"$colClear
			echo -e "Prepend command to nwchem executable wrapper"
			echo
			echo -e $colArg" -xptl <LINE>"$colClear
			echo -e "Add line to nwchem input file (before task)"
			exit 1
			;;
		-np)
			shift 
			NPROC_NWC=$1
			shift
			;;
		-dft)
			shift 
			REPLACE_DFT=1
			;;
		--template)
			shift 
			DFT_TEMPLATE=$1
			shift
			;;
		-xnwi|--extra-nwchem-input)
			shift 
			EXLINE="$EXLINE""$1\n"
			shift
			;;
		-xnwe|--extra-nwchem-executable)
			shift 
			EXEXLINE="$EXEXLINE""$1\n"
			shift
			;;
		-pt|--pre-task)
			shift
			PRETASK=$1
			shift
			;;
		*)
			warningOut "Unrecognised CLI flag: $colArg$1"
			KILL=1
			break
			;;
	esac
done

##########

varOut "Path" $(pwd)

if [[ "${BASH_SOURCE[0]}" == "${0}" ]] ; then
	echo "Please source this script. i.e. :"
	echo "source \$MSHTOOLS/load_amb_nwc.sh <N_NWCHEM_THREADS>"
	exit 1
fi

if [ $KILL -eq 1 ] ; then
	return 2
fi

if [ -z $NPROC_NWC ] ; then
	warningOut "No NWChem thread count supplied, will use all available."
	# NPROC_NWC=0
else
	varOut "NWChem num_threads" $NPROC_NWC
fi

# Program Locations
export AMBERHOME=/opt/pkg/apps/ambertools/v20-parallel
export NWCHEM_L64=/opt/pkg/apps/nwchem/7.0.2/nwchem-7.0.2-release/bin/LINUX64

# Reset Environment
module purge

# Set up AmberTools
module load ambertools
source $AMBERHOME/amber.sh
AMB_RET=$?
AMBER_LIBS=$LD_LIBRARY_PATH # Store library environment

if [ $AMB_RET -ne 0 ] ; then
	echo "AmberTools could not be set up."
	return 2
fi

# Get NWChem pre-requisites
module load intel/Intel_Parallel_Suite/xe_2017_3
NWCHEM_LIBS=$LD_LIBRARY_PATH # Store library environment

# Library environment should combine Amber & NWChem Pre-reqs.
export LD_LIBRARY_PATH="$AMBER_LIBS:$NWCHEM_LIBS"

# Add NWChem Binaries to path (except main one)
PATH=$NWCHEM_L64/bin/LINUX64:$PATH
PATH=$NWCHEM_L64/lib/LINUX64:$PATH
PATH=$(pwd):$PATH
export PATH

# Wrapper commands
SHEBANG="#!/bin/bash"
ENDLINE="\n"
NWC_EXEC="$NWCHEM_L64/nwchem"

# Use custom DFT block
PRERUN=""
if [ ! -z "$EXEXLINE" ] ; then
	PRERUN="$EXEXLINE"
fi
if [ $REPLACE_DFT -eq 1 ] ; then
	varOut "DFT_TEMPLATE" $DFT_TEMPLATE

	# replace the start of the DFT block with a string to match to
	PRERUN="$PRERUN""sed -i 's/dft$/SED_TARGET/' nwchem.nw$ENDLINE"

	# remove any end statements in dft.nw
	PRERUN="$PRERUN""sed -i 's/end$//' dft.nw$ENDLINE"

	# replace the contents of the dft block in the nwchem file
	SED_IN="'/SED_TARGET$/ {p; r $DFT_TEMPLATE'"
	PRERUN="$PRERUN""sed -i -ne $SED_IN -e ':a; n; /end$/ {p; b}; ba}; p' nwchem.nw$ENDLINE"
	
	# restore the start of the DFT block
	PRERUN="$PRERUN""sed -i 's/SED_TARGET/dft/' nwchem.nw$ENDLINE"
fi
if [[ "$PRETASK" != "" ]] ; then

	# remove the task line
	PRERUN="$PRERUN""sed -i 's/task dft gradient$//' nwchem.nw$ENDLINE"
	
	# append the lines from the template
	PRERUN="$PRERUN""cat $PRETASK >> nwchem.nw$ENDLINE"

	# reappend the task line
	PRERUN="$PRERUN""echo 'task dft gradient' >> nwchem.nw$ENDLINE"
fi

# Extra input commands
if [ ! -z "$EXLINE" ] ; then
	echo "$EXLINE" >> nwchem.nw
fi

# Limit processors (optional)
if [ -z $NPROC_NWC ] ; then
	RUNCMD="mpirun "
else
	RUNCMD="mpirun -np $NPROC_NWC "
fi

# Create wrapper binary that calls mpirun first
echo -e "$SHEBANG$ENDLINE$PRERUN$RUNCMD$NWC_EXEC "'$@'"$ENDLINE""exit "'$?'" $ENDLINE" > nwchem

# Make the binary executable
chmod 755 nwchem

# User output
echo -e "$colFunc""AmberTools/NWChem/MPI$colClear: $colSuccess""ready to use.$colClear"
return 0
