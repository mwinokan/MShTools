#!/bin/bash -u

source $MWSHPATH/colours.sh

# FUNCTIONS
# directoryExists - Does the directory exist?
function directoryExists {
    if [ -d "$1" ] ; then
        echo -e "$colSuccess$1${NC}"
        return 1
    else
        echo -e "$colError$1${NC}"
        return 0
    fi
}

# FUNCTIONS
# directoryExists - Does the directory exist?
function directoryExistsQuiet {
    if [ -d "$1" ] ; then
        return 1
    else
        return 0
    fi
}

function fileExists {
    if [ -f "$1" ]; then
        echo -e "$colSuccess$1 exists $colClear"
        return 1
    else 
        echo -e "$colError$1 does not exist $colClear"
        return 0
    fi
}

function fileExistsQuiet {
    if [ -f "$1" ]; then
        return 1
    else 
        return 0
    fi
}

function fileExistsSemiQuiet {
    if [ -f "$1" ]; then
        return 1
    else 
        echo -e "$colError$1 does not exist $colClear"
        return 0
    fi
}

function fileExistsRetOut {
    if [ -f "$1" ]; then
        echo "1"
        return 1
    else 
        echo "0"
        return 0
    fi
}