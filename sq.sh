
#!/bin/bash
source $MWSHPATH/colours.sh

LOOP=0
SHORT=0
HEADERS=1
USERCODE=$(grep -oP "(?<=usercode=).*(?=;)" $MWSHPATH/.suppressed_gitlab)

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "Usage for "$colFunc"sq"$colClear":"
      echo -e $colArg"-l"$colClear" loop indefinitely"
      echo -e $colArg"-i"$colClear" cluster info (sinfo)"
      echo -e $colArg"-s"$colClear" short output"
      echo -e $colArg"-s"$colClear" show headers"
      exit 1
      ;;
    -l)
      shift
      LOOP=1
      ;;
    -nh)
      shift
      HEADERS=0
      ;;
    -louie)
      shift
      USERCODE=ls00338
      ;;
    -s)
      shift
      SHORT=1
      ;;
    -u)
      shift
      USERCODE=$1
      shift
      ;;
    -i)
      shift
      sinfo
      exit
      ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      echo -e "See "$colFunc"sq"$colClear$colArg" -h "$colClear"for usage."
      exit 2
      ;;
  esac
done

function convert4showtime {
  TIME=$1
  IFS=- read DAYS TIME <<< "$TIME"
  # echo $DAYS > debug
  # echo $TIME >> debug
  if [[ "$TIME" == "" ]] ; then
    TIME=$DAYS
    IFS=: read HRS MIN SEC <<< "$TIME"
    if [[ "$SEC" == "" ]] ; then
      if [[ "$MIN" == "" ]] ; then
        SEC=$HRS
        secs=$SEC
      else
        SEC=$MIN
        MIN=$HRS
        secs=$((10#$SEC + 60*10#$MIN))
      fi
    else
      secs=$((10#$SEC + 60*10#$MIN + 3600*10#$HRS))
    fi
  else
    IFS=: read HRS MIN SEC <<< "$TIME"
    secs=$((10#$SEC + 60*10#$MIN + 3600*10#$HRS + 86400*10#$DAYS))
  fi
  TIME=$(show_time $secs)
  echo -e $TIME
}

# https://stackoverflow.com/questions/12199631/convert-seconds-to-hours-minutes-seconds
function show_time () {
  num=$1
  min=0
  hour=0
  day=0
  if((num>59));then
      ((sec=num%60))
      ((num=num/60))
      if((num>59));then
          ((min=num%60))
          ((num=num/60))
          if((num>23));then
              ((hour=num%24))
              ((day=num/24))
          else
              ((hour=num))
          fi
      else
          ((min=num))
      fi
  else
      ((sec=num))
  fi
  # echo "$day"d "$hour"h "$min"m "$sec"s

  TIME_STRING=""
  if [ $day -ne 0 ]; then TIME_STRING="$day""d "; fi
  if [ $hour -ne 0 ]; then TIME_STRING=$TIME_STRING"$hour""h "; fi
  if [ $min -ne 0 ]; then TIME_STRING=$TIME_STRING"$min""m "; fi
  if [ $sec -ne 0 ]; then TIME_STRING=$TIME_STRING"$sec""s "; fi
  echo -e "$TIME_STRING"
}

function show_queue {
  QUEUE=$(squeue -l -u $USERCODE)
  # echo "$QUEUE"
  nRUNNING=$(echo -e "$QUEUE" |  grep "RUNNING" | wc -l )
  nPENDING=$(echo -e "$QUEUE" |  grep "PENDING" | wc -l )

  # if [ $nRUNNING -eq 0 ] && [ $nPENDING -eq 0 ]; then 
  #   echo -e $colBold$USERCODE"'s queue is empty"$colClear
  #   exit
  # fi

  echo -e $colBold$USERCODE"'s queue"$colClear

  NAME_LINE='        '
  TIME_LINE='            '
  TIME_STRING_LINE="                     "

  # running job summary
  if [ $nRUNNING -eq 0 ] ; then
    echo -e $colSuccess"No jobs running."$colClear
  else
    echo -e $colSuccess"\nRunning: $nRUNNING"$colClear
    if [ $HEADERS -eq 1 ] ; then
      if [ $SHORT -eq 0 ] ; then
        echo -e "\n"$colUnderline$colBold"Job ID$colClear '$colUnderline"$colVarName"Job Name$colClear' $colVarType$colUnderline# Nodes"$colClear $colResult$colUnderline"Elapsed$colClear ("$colResult$colUnderline"Limit$colClear)       ("$colArg$colUnderline"partition$colClear:"$colArg$colUnderline"nodes$colClear)"
      else
        echo -e "\n"$colUnderline$colBold"Job ID$colClear '$colUnderline"$colVarName"Job Name$colClear' $colVarType$colUnderline# Nodes"$colClear $colResult$colUnderline"Elapsed$colClear"
      fi
    fi
    JOBIDS=$(echo -e "$QUEUE" |  grep "RUNNING" | awk '{print $1}')
    for JOB in $JOBIDS; do
      PARTITION=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $2}')
      NAME=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $3}')
      NAME="'"$colVarName$NAME$colClear"'""${NAME_LINE:${#NAME}}"
      
      TIME=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $6}')
      LIMIT=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $7}')

      TIME=$(convert4showtime $TIME)
      LIMIT=$(convert4showtime $LIMIT)


      # TIME=${TIME_LINE:${#TIME}}$TIME
      # LIMIT=${TIME_LINE:${#LIMIT}}$LIMIT
      TIME_STRING="$TIME ($LIMIT)"
      TIME_STRING="$colResult$TIME$colClear ($colResult$LIMIT$colClear)"${TIME_STRING_LINE:${#TIME_STRING}}
      NODES=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $8}')
      NODELIST=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $9}')
      if [ $SHORT -eq 1 ] ; then
        echo -e $colBold$JOB$colClear "$NAME"" $colVarType$NODES nodes $colClear"$colResult"$TIME"$colClear
      else
        echo -e $colBold$JOB$colClear "$NAME"" $colVarType$NODES nodes $colClear""$TIME_STRING"" ""($colArg$PARTITION$colClear:$colArg$NODELIST$colClear)"
      fi
    done
  fi

  #pending job summary
  if [ $nPENDING -eq 0 ] ; then
    echo -e $colError"No jobs pending."$colClear
  else
    echo -e $colError"\nPending: $nPENDING"$colClear
    if [ $HEADERS -eq 1 ] ; then
      if [ $SHORT -eq 0 ] ; then
        echo -e "\n"$colUnderline$colBold"Job ID$colClear '$colUnderline"$colVarName"Job Name$colClear' $colVarType$colUnderline# Nodes"$colClear $colResult$colUnderline"Approx. Start$colClear  ("$colArg$colUnderline"partition$colClear)"
      else
        echo -e "\n"$colUnderline$colBold"Job ID$colClear '$colUnderline"$colVarName"Job Name$colClear' $colVarType$colUnderline# Nodes"$colClear $colResult$colUnderline"Approx. Start$colClear"
      fi
    fi

    QUEUE=$(squeue --start -u $USERCODE)
    # echo $QUEUE
    JOBIDS=$(echo -e "$QUEUE" | grep "PD" | awk '{print $1}')
    for JOB in $JOBIDS; do
      PARTITION=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $2}')
      NAME=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $3}')
      NAME="'"$colVarName$NAME$colClear"'""${NAME_LINE:${#NAME}}"
      START_TIME=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $6}')
      NODES=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $7}')
      # NODELIST=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $9}')
      REMAINING=$(( $(date +%s -d "$START_TIME") - $( date +%s ) ))
      

      if [ $SHORT -eq 1 ] ; then
        echo -e $colBold$JOB$colClear "$NAME"" $colVarType$NODES nodes $colClear"$colResult$(show_time $REMAINING)$colClear
      else
        echo -e $colBold$JOB$colClear "$NAME"" $colVarType$NODES nodes $colClear"$colResult$(show_time $REMAINING)$colClear " ($colArg$PARTITION$colClear)"
      fi
    done
  fi
}

if [ $LOOP -eq 1 ] ; then
  while :
  do
    clear
    show_queue
    echo "Press [CTRL+C] to stop.."
    sleep 0.5
  done
else
  show_queue
fi
