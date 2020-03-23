#!/bin/bash

module purge              # Unload all currently loaded modules to reduce chance of conflicts. 
module load gromacs/2018  # Load the GROMACS module and its dependencies.

source /opt/proprietary-apps/gromacs/2018/bin/GMXRC.bash # Set up the GROMACS environment variables.

export GMXLIB=$HOME"/gmx_ff"
