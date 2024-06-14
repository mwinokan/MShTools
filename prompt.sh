INVERSE="\[\033[7m\]"
BOLD="\[\033[1m\]"
BLUE="\[\033[34m\]"
RED="\[\033[31m\]"
OFF="\[\033[m\]"
YELLOW="\[\033[33m\]"
CYAN="\[\033[36m\]"
COLOR=$CYAN

PROMPT_COMMAND="__prompt_command${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
__prompt_command() {
    EXIT=$?
    if [ $EXIT != 0 ] ; then
        PS1="${INVERSE}${RED}${BOLD} \u ${OFF} ${RED}${BOLD}\W ${OFF}"
    else
        PS1="${INVERSE}${COLOR}${BOLD} \u ${OFF} ${COLOR}${BOLD}\W ${OFF}"
    fi
}
