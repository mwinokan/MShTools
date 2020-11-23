#!/bin/bash

export ENLIGHTEN=$HOME/enlighten
export AMBERHOME=/opt/pkg/apps/ambertools/v20-parallel

module purge
module load ambertools
source $AMBERHOME/amber.sh
