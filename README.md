# BAShTools

This repository contains several scripts to improve quality of life in terminal and HPC workflows. Most programs have a basic help screen which can be accessed with the flag -h or --help. While some of the scripts are ready to go out of the box, follow the installation instructions at the bottom of this page for all features to work.

***N.B. a separate branch exists for use at Diamond Light Source (DLS/SLURM), for which the following documentation may be out of date***

## Console IO:
- `colours.sh` contains ANSI escape strings to change console output colours in the `MTools` colour scheme. Source this script to access the variables. (Portable)
- `out.sh` functions to format output to console. Source this script to access the functions (Portable)

## SLURM specific
- `sq.sh` pretty list of all active jobs for a given user. (Intended only for SLURM HPC's)
- `sb.sh` pretty SLURM job submission.
- `wd.sh` change to, list, and get paths to working directories that fit the pattern `~/WD_<NUMBER>_<TAGS>`. (Portable)
- `send2access.sh` easily send files to a folder called 'fromEureka' on access.eps.surrey.ac.uk
- `mod_run.sh` change the SBATCH comments in a run file easily. (Intended only for EUREKA)
- `results.sh` quickly see the results of a job queued with `submit.sh` (Portable)

## EUREKA Specific
- `djvu2pdf.sh` converts djvu files to pdf (Intended only for EUREKA).
- `usage.sh` shows your disk usage for $HOME & $PSCRATCH. (Intended only for EUREKA).
- `rogue.sh` SSH into recently used nodes to try and identify headless/rogue processes. (Intended for EUREKA).
- `send2access.sh` SCP files to the access server. Barebones.

## Amber + AmberTools specific

- `load_amb.sh` Load Amber on EUREKA (Intended only for EUREKA)
- `load_amb_nwc.sh` Load Amber on EUREKA (Intended only for EUREKA)
- `amb_avg.sh` Produce a PDB with the average coordinates in an Amber MDCRD trajectory.
- `amb_stats.sh` Parse energy minimisation and other log files. Barebones.
- `run_wham.sh` Run WHAM to produce free energy barriers from umbrella sampling simulations.

## git automation
- `allgits.sh` display the status of all git repositories in your home directory. (Broken when git directories have spaces)
- `newgit.sh` easily initialise a new git directory with an automatically generated `README.md` file and push to GitHub or the University of Surrey's GitLab. Requires careful configuration of this package via the configure.sh script. (Portable)

## Others
- `directory_exists.sh` provides functions to check if directories and files exist.
- `authname.sh` parses `.bib` files for author lists
- `confucius.py` Office wisdom
- `loop_this.py <COMMAND>` Run any command in an infinite loop.
- `rename.sh` Batch renaming of using pattern matching.
- `table.sh` Perl version of the `column -t` command.

## MacOS
- `unmount.sh` Uses osascript to unmount external drives.

# Installation

  * To use these tools clone this repository and add the directory to your BASh `PATH` variable.

`git clone https://github.com/mwinokan/MShTools.git`

`cd MShTools`

`echo "export MSHTOOLS=$PWD" >> ~/.bash_profile`

`echo 'export PATH=$MSHTOOLS:$PATH' >> ~/.bash_profile`

  * Many scripts require Surrey and gitlab credentials. Create the files using `configure.sh`, see `configure.sh -h` and comments in script for information.
  * `wd` and other scripts need to be sourced to run, you may wish to add the following alias to your `.bash_profile`: `alias wd='source $MSHTOOLS/wd.sh'`
  * You may prefer to define aliases for `newgit.sh`, `results.sh`, and `sq.sh` - i.e. `alias newgit='bash $MSHTOOLS/newgit.sh'`
