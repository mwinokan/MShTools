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
- `djvu2pdf.sh` converts djvu files to pdf (Intended for EUREKA).
- `usage.sh` shows your disk usage for $HOME & $PSCRATCH.

## Others
- `directory_exists.sh` provides functions to check if directories and files exist.
- `authname.sh` parses `.bib` files.

## MacOS
- `unmount.sh` Uses osascript to unmount external drives.

## Gromacs on EUREKA

- `gmx_funcs.sh` includes several functions for calling Gromacs on EUREKA that you might find useful.
    + `gmx_funcs.sh/xvg2png` Calls [MGnuPlots/xvg2png.gp](#http://www.github.com/mwinokan/MGnuPlots) to plot data in an XVG file. See `xvg2png -h` for usage.
- `load_gmx.sh` loads the necessary modules for Gromacs on EUREKA.

# Installation

  * To use these tools clone this repository and add the directory to your BASh `PATH` variable.
  * Additionally add `export MWSHPATH=/path/to/sh` to your `.bash_profile`. 
  * Many scripts require Surrey and gitlab credentials. Create the files using `configure.sh`, see comments in script for information.
  * `wd` needs to be sourced to run, add the following alias to your `.bash_profile`: `alias wd='source $MWSHPATH/wd.sh'`
  * You may prefer to define aliases for `newgit.sh`, `results.sh`, and `sq_loop.sh` - i.e. `alias newgit='bash $MWSHPATH/newgit.sh'`
  * Check individual scripts for dependencies.