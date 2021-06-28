#!/bin/bash

#SBATCH --partition=shared
#SBATCH --time=01-00:00:00
#SBATCH --job-name=sander
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH -o %j_%x.o
#SBATCH -e %j_%x.e
#SBATCH --mem=4000

#### Variables/Paths ####

# set this to the folder from which you submit the job:
WORK="$HOME/quick_test"

# name of the output folder
OUTKEY="sander_test"

# sander md control file
SANDER_IN="something.i"

# prmtop topology
PRMTOP="something.prmtop"

# inpcrd/rst starting coordinates
INPCRD="something.inpcrd"

#### Directories

# scratch directory
SCRATCH=$HOME/parallel_scratch/$OUTKEY

#### Setup Amber ####

export AMBERHOME=/opt/pkg/apps/ambertools/v20-parallel

module purge
module load ambertools

source $AMBERHOME/amber.sh

SANDER="$AMBERHOME/bin/sander"

#### User Output ####

echo "--------------------------------------"
echo "Molecular Dynamics with Amber's sander"
echo "--------------------------------------"

echo WORK $WORK
echo OUTKEY $OUTKEY
echo SANDER_IN $SANDER_IN
echo PRMTOP $PRMTOP
echo INPCRD $INPCRD
echo SCRATCH $SCRATCH

echo "--------------------------------------"

#### Prepare scratch directory ####

# make the scratch folder
mkdir -pv $SCRATCH

# copy the sander input file
cp -v $WORK/$SANDER_IN $SCRATCH/

# change into scratch directory
cd $SCRATCH

#### Run sander ####

echo "--------------------------------------"

echo "Running sander..."

# run and time sander
$SANDER -O -i $SANDER_IN -o $OUTKEY.log -p $WORK/$PRMTOP -c $WORK/$INPCRD -x $OUTKEY.mdcrd -r $OUTKEY.rst

# catch the output status
AMBOUT=$?

#### Check for warnings/errors ####

# count the warnings and errors
NUM_WARNINGS=$(grep WARNING $SCRATCH/$OUTKEY.log | wc -l)
NUM_ERRORS=$(grep ERROR $SCRATCH/$OUTKEY.log | wc -l)

if [ $NUM_WARNINGS -ne 0 ] ; then
	echo "$NUM_WARNINGS warnings given!"
fi

if [ $NUM_ERRORS -ne 0 ] ; then
	echo "$NUM_ERRORS errors encountered!"
fi

if [ $AMBOUT -ne 0 ] ; then
	echo "Something's wrong see:" $SCRATCH/$OUTKEY.log
fi

#### Finish up ####

echo "--------------------------------------"
echo "Finishing up..."

# change to work directory
cd $WORK

# make the output directory
mkdir -pv $WORK/$OUTKEY

# copy from scratch to work
rsync -a $SCRATCH/ $WORK/$OUTKEY/ 1>&2

echo "--------------------------------------"

# exit with sander's output code
exit $AMBOUT
