
#!/bin/bash
source $MWSHPATH/colours.sh

LOOP=0
SHORT=0
HEADERS=1

if [[ $(hostname) == *scarf* ]] ; then
  USERCODE=$(grep -oP "(?<=user=).*(?=;)" $MWSHPATH/.suppressed_scarf)
else
  USERCODE=$(grep -oP "(?<=usercode=).*(?=;)" $MWSHPATH/.suppressed_gitlab)
fi

SHOW_PREV_NUM=5

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "Usage for "$colFunc"sq"$colClear":"
      echo -e $colArg"-l"$colClear" loop indefinitely"
      echo -e $colArg"-i"$colClear" cluster info (sinfo)"
      echo -e $colArg"-s"$colClear" short output"
      echo -e $colArg"-nh"$colClear" don't show headers"
      echo -e $colArg"-p <N>"$colClear" show previous N jobs, default is 5"
      echo -e $colArg"-u <USER>"$colClear" show USER's queue"
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
    -p)
      shift
      SHOW_PREV_NUM=$1
      shift
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
    echo -e $colSuccess"\nNo jobs running."$colClear
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
    echo -e $colError"\nNo jobs pending."$colClear
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
      # echo $START_TIME
      if [[ "$START_TIME" != *"N/A"* ]] ; then
        REMAINING=$(( $(date +%s -d "$START_TIME") - $( date +%s ) ))
        if [ $SHORT -eq 1 ] ; then
          echo -e $colBold$JOB$colClear "$NAME"" $colVarType$NODES nodes $colClear"$colResult$(show_time $REMAINING)$colClear
        else
          echo -e $colBold$JOB$colClear "$NAME"" $colVarType$NODES nodes $colClear"$colResult$(show_time $REMAINING)$colClear " ($colArg$PARTITION$colClear)"
        fi
      else
        if [ $SHORT -eq 1 ] ; then
          echo -e $colBold$JOB$colClear "$NAME"" $colVarType$NODES nodes $colClear"$colResult
        else
          echo -e $colBold$JOB$colClear "$NAME"" $colVarType$NODES nodes $colClear"$colResult$colClear"            ($colArg$PARTITION$colClear)"
        fi
      fi

    done
  fi

  # Previous jobs  
  if [ $SHOW_PREV_NUM -gt 0 ] ; then
    echo -e $colBold$colFile"\nPrevious $SHOW_PREV_NUM jobs:"$colClear
    
    LAST_WEEK_DATE=$(date --date="14 days ago" +"%Y-%m-%d")
    # sacct --starttime $LAST_WEEK_DATE --format=JobID,Jobname,partition,state,start,elapsed,time,nnodes,nodelist | grep "COMPLETED\|FAILED\|CANCELLED" | grep -v "batch" | tail -n $SHOW_PREV_NUM
    sacct --user=$USERCODE --starttime $LAST_WEEK_DATE --format=JobID,Jobname,partition,state,start,elapsed,time,nnodes,nodelist | grep "COMPLETED\|FAILED\|CANCELLED\|TIMEOUT" | grep -v "extern\|batch\|hydra\|\..*       " | tail -n $SHOW_PREV_NUM > __temp__

    if [ $SHORT -eq 0 ] ; then
      echo -e "\n"$colUnderline$colBold"Job ID$colClear '$colUnderline"$colVarName"Job Name$colClear' $colVarType$colUnderline# Nodes"$colClear $colResult$colUnderline"Job Start Time$colClear  ("$colArg$colUnderline"partition$colClear)"
    else
      echo -e "\n"$colUnderline$colBold"Job ID$colClear '$colUnderline"$colVarName"Job Name$colClear' $colVarType$colUnderline# Nodes"$colClear $colResult$colUnderline"Job Start Time$colClear"
    fi

    while read -r LINE; do
      JOB_ID=$(echo $LINE | awk '{print $1}')
      # if [[ $JOB_ID == *"."? ]] ; then
      #   continue
      # fi
      JOB_NAME=$(echo $LINE | awk '{print $2}')
      PARTITION=$(echo $LINE | awk '{print $3}')
      STATUS=$(echo $LINE | awk '{print $4}')
      if [[ $JOB_NAME == "bash" ]] ; then
        if [[ $STATUS != "CANCELLED+" ]] ; then
          STATUS="TERMINATED"
        fi
      fi
      if [[ $JOB_NAME == "*.sh" ]] ; then
        if [[ $STATUS != "CANCELLED+" ]] ; then
          STATUS="TERMINATED"
        fi
      fi
      if [[ $JOB_NAME == "sh" ]] ; then
        if [[ $STATUS != "CANCELLED+" ]] ; then
          STATUS="TERMINATED"
        fi
      fi
      START=$(echo $LINE | awk '{print $5}')
      ELAPSED=$(echo $LINE | awk '{print $6}')
      MAX_TIME=$(echo $LINE | awk '{print $7}')
      NUM_NODES=$(echo $LINE | awk '{print $8}')
      NODES=$(echo $LINE | awk '{print $9}')

      if [[ $STATUS == "COMPLETED" ]] ; then
        ELAPSED_COLOR=$colSuccess
      elif [[ $STATUS == "CANCELLED+" ]] ; then
        ELAPSED_COLOR=$colWarning
        STATUS="CANCELLED"
      elif [[ $STATUS == "CANCELLED" ]] ; then
        ELAPSED_COLOR=$colWarning
      elif [[ $STATUS == "FAILED" ]] ; then
        ELAPSED_COLOR=$colError
      elif [[ $STATUS == "TIMEOUT" ]] ; then
        ELAPSED_COLOR=$colError
      else
        ELAPSED_COLOR=$colResult
      fi

      START=$(date --date="$START" "+%b %-d`DaySuffix` %R")

      START_LINE="              "
      START=$START${START_LINE:${#START}}

      JOB_NAME="'"$colVarName$JOB_NAME$colClear"'""${NAME_LINE:${#JOB_NAME}}"
      ELAPSED=$(convert4showtime $ELAPSED)
      STATUS=$(echo $STATUS | tr [:upper:] [:lower:] | sed -E "s/[[:alnum:]_'-]+/\u&/g")

      if [ $SHORT -eq 0 ] ; then
        if [[ $ELAPSED == "" ]] ; then
          echo -e $colBold$JOB_ID$colClear" ""$JOB_NAME"" "$colVarType$NUM_NODES" nodes"$colClear $colResult"$START" $colClear" ("$colArg$PARTITION$colClear":"$colArg$NODES$colClear") "$ELAPSED_COLOR$STATUS" before allocation"$colClear
        else
          echo -e $colBold$JOB_ID$colClear" ""$JOB_NAME"" "$colVarType$NUM_NODES" nodes"$colClear $colResult"$START" $colClear" ("$colArg$PARTITION$colClear":"$colArg$NODES$colClear") "$ELAPSED_COLOR$STATUS" after "$ELAPSED_COLOR$ELAPSED$colClear
        fi
      else
        echo -e $colBold$JOB_ID$colClear" ""$JOB_NAME"" "$colVarType$NUM_NODES" nodes"$colClear $colResult"$START" $colClear
      fi
    done < __temp__
  fi

  rm __temp__* 2> /dev/null
}

# https://stackoverflow.com/questions/2495459/formatting-the-date-in-unix-to-include-suffix-on-day-st-nd-rd-and-th
DaySuffix() {
    if [ "x`date +%-d | cut -c2`x" = "xx" ]
    then
        DayNum=`date +%-d`
    else
        DayNum=`date +%-d | cut -c2`
    fi

    CheckSpecialCase=`date +%-d`
    case $DayNum in
    0 )
      echo "th" ;;
    1 )
      if [ "$CheckSpecialCase" = "11" ]
      then
        echo "th"
      else
        echo "st"
      fi ;;
    2 )
      if [ "$CheckSpecialCase" = "12" ]
      then
        echo "th"
      else
        echo "nd"
      fi ;;
    3 )
      if [ "$CheckSpecialCase" = "13" ]
      then
        echo "th"
      else
        echo "rd"
      fi ;;
    [4-9] )
      echo "th" ;;
    * )
      return 1 ;;
    esac
}

if [ $LOOP -eq 1 ] ; then
  while :
  do
    clear
    show_queue
    echo -e "\nPress [CTRL+C] to stop.."
    sleep 1.0
  done
else
  show_queue
fi
