#!/bin/bash

source $MWSHPATH/out.sh

function scriptCheck {
  SHEBANG=$(head -n 1 $1)
  if [[ $1 != *".sh" ]] || [[ $SHEBANG != '#!/bin/'*'sh' ]] ; then
    errorOut "$colFile$1$colError is not a script!"
    exit 3
  fi
}

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      flagOut -h --help "Display this help screen."
      flagOut -sp --set-partition "<SCRIPT>" "<PARTITION>" "['debug'/'share']" "Set the partition and run_time."
      flagOut -sj --set-job-name "<SCRIPT>" "<NAME>" "Set the job name."
      exit 1      
      ;;
    -sp|--set-partition)
      shift
      SCRIPT=$1
      PARTITION=$2

      # check if valid script
      scriptCheck $SCRIPT

      # change SBATCH comments
      case "$PARTITION" in
        d|debug|debug_latest)
          sed -i.bak "/#SBATCH/ s/--partition=shared/--partition=debug_latest/" $SCRIPT
          sed -i.bak "/#SBATCH/ s/--time=01-00:00:00/--time=00-00:60:00/" $SCRIPT
          successOut "Changed partition to $colArg""debug_latest"$colClear
          ;;
        s|share|shared)
          sed -i.bak "/#SBATCH/ s/--partition=debug_latest/--partition=shared/" $SCRIPT
          sed -i.bak "/#SBATCH/ s/--time=00-00:60:00/--time=01-00:00:00/" $SCRIPT
          sed -i.bak "/#SBATCH/ s/--time=00-01:00:00/--time=01-00:00:00/" $SCRIPT
          sed -i.bak "/#SBATCH/ s/--time=01:00:00/--time=01-00:00:00/" $SCRIPT
          sed -i.bak "/#SBATCH/ s/--time=00:60:00/--time=01-00:00:00/" $SCRIPT
          sed -i.bak "/#SBATCH/ s/--time=60:00/--time=01-00:00:00/" $SCRIPT
          successOut "Changed partition to $colArg""shared"$colClear
          ;;
        *)
          echo -e $colError"Unknown partition "$colArg$PARTITION$colClear
          exit 4
          ;;
      esac

      if [ $(grep '#SBATCH --partition' $SCRIPT | wc -l) -ne 1 ] ; then
        warningOut "Multiple partition definitions!"
      fi 

      if [ $(grep '#SBATCH --time' $SCRIPT | wc -l) -ne 1 ] ; then
        warningOut "Multiple time limit definitions!"
      fi 

      exit 0

      ;;
    -sj|--set-job-name)
      shift
      SCRIPT=$1
      NAME=$2

      # check if valid script
      scriptCheck $SCRIPT

      sed -i.bak "s/#SBATCH --job-name=.*/#SBATCH --job-name=$NAME/" $SCRIPT

      successOut "Changed name to $colArg""$NAME"$colClear

      exit

      ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      exit 2
      ;;
  esac
done