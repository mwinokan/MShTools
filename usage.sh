#!/bin/bash

source $MSHTOOLS/out.sh

SCRATCH_DU=$(du -hs $HOME/parallel_scratch/ | awk '{print $1}')
HOME_DU=$(du -hs $HOME | awk '{print $1}')

varOut $colFile'$HOME' $HOME_DU
varOut $colFile'$PSCRATCH' $SCRATCH_DU
