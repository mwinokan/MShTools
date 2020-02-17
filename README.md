# BAShTools

## Console IO:
- `colours.sh` contains ANSI escape strings to change console output colours in the `MTools` colour scheme. (Portable)
- `out.sh` functions to format output to console. (Portable)
- `results.sh` quickly see the results of a job queued with `submit.sh` (Portable)

## git automation
- `allgits.sh` display the status of all git repositories in your home directory. (Broken when git directories have spaces)
- `newgit.sh` easily initialise a new git directory with an automatically generated `README.md` file and push to GitHub or the University of Surrey's GitLab. (Portable)

## sbatch / EUREKA specific
- `submit.sh` submit a given script using `sbatch` on EUREKA's parallel scratch. (Currently private, awaiting update)
- `sq_loop.sh` auto-refreshing list of all active jobs for a given user. (Intended for EUREKA)
- `wd.sh` change to, list, and get paths to working directories that fit the pattern `~/WD_<NUMBER>_<TAGS>`. (Portable)

## Others
- `directory_exists.sh` provides functions to check if directories and files exist.
- `authname.sh` parses `.bib` files.

# Installation

  * To use these tools clone this repository and add the directory to your BASh `PATH` variable.
  * Additionally add `export MWSHPATH=/path/to/sh` to your `.bash_profile`. 
  * Many scripts require Surrey and gitlab credentials. Create the files using `configure.sh`, see comments in script for information.
  * `wd` needs to be sourced to run, add the following alias to your `.bash_profile`: `alias wd='source $MWSHPATH/wd.sh'`
  * You may prefer to define aliases for `newgit.sh`, `results.sh`, and `sq_loop.sh` - i.e. `alias newgit='bash $MWSHPATH/newgit.sh'`
  * Check individual scripts for dependencies.