#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]] ; then
	echo "Please source this script. i.e. :"
	echo "source \$MWSHPATH/load_amb_nwc.sh <N_NWCHEM_THREADS>"
	exit 1
fi

source $MWSHPATH/colours.sh
source $MWSHPATH/out.sh

if [ -z $1 ] ; then
	warningOut "No NWChem thread count supplied, will use all available."
	NPROC_NWC=0
else
	varOut "NWChem num_threads" $1
	NPROC_NWC=$1
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

# Create wrapper binary that calls mpirun first
if [ $NPROC_NWC -eq 0 ] ; then
	echo -e "#!/bin/bash\nmpirun $NWCHEM_L64/nwchem \$@\n" > nwchem
else
	echo -e "#!/bin/bash\nmpirun -np $NPROC_NWC $NWCHEM_L64/nwchem "'$@'"\n" > nwchem
fi

chmod 755 nwchem

echo -e "$colFunc""AmberTools/NWChem/MPI$colClear: $colSuccess""ready to use.$colClear"
return 0
