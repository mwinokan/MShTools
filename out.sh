#!/bin/bash -u

source $MWSHPATH/colours.sh

# To-Do's

# fancyOut <HEADER>
ECHO_STR=" >>> "
function fancyOut {
  echo -e $colBold$ECHO_STR$1" [ "$(/usr/bin/date)" ] "$colClear
}

# headerOut <HEADER> [<ECHO_STR>]
function headerOut {
  echo -e $colBold$2$1$colClear
}

# varOut <NAME> <VALUE> <UNIT> [<VALUE_COL_STRING>]
function varOut {
  echo -e "$colVarName$1$colClear: $4$2 $colVarType$3 $colClear"
}

# returnOut <COMMENT> <RETURN_VALUE> [<COMMENT>]
function returnOut {
  if [ $2 -eq 0 ] ; then 
    COL=$colSuccess
  else 
    COL=$colError
  fi
  echo -e $1" $COL$2$colClear $3"
}

# errorOut <ERROR_MSG>
function errorOut {
  echo -e $colError"ERROR: "$1$colClear
}

# warningOut <ERROR_MSG>
function warningOut {
  echo -e $colWarning"WARNING: "$1$colClear
}

# successOut <ERROR_MSG>
function successOut {
  echo -e $colSuccess$1$colClear
}

# command line argument for usage:
# -h <STRING> 
function flagOut {
  FLAG=$1
  TYPE=$2
  shift
  shift
  echo -e $colVarName$FLAG" "$colVarType$TYPE$colClear" "$@
}