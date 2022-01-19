#!/bin/bash

source $MWSHPATH/colours.sh
source $MWSHPATH/out.sh

LOOP=0
SHORT=0
HEADERS=1
PENDING=0
RUNNING=0
IDLE=0
HISTORY=0

if [[ $(hostname) == *scarf* ]] ; then
  USERCODE=$(grep -oP "(?<=user=).*(?=;)" $MWSHPATH/.suppressed_extern)
elif [[ $(hostname) == uan01 ]] ; then
  USERCODE=$(grep -oP "(?<=user=).*(?=;)" $MWSHPATH/.suppressed_extern)
else
  USERCODE=$(grep -oP "(?<=usercode=).*(?=;)" $MWSHPATH/.suppressed_gitlab)
fi

SHOW_PREV_NUM=10

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "Usage for "$colFunc"sq"$colClear":"
      echo -e $colArg"-l"$colClear" loop indefinitely"
      echo -e $colArg"-si"$colClear" cluster info (sinfo)"
      echo -e $colArg"-s"$colClear" short output"
      echo -e $colArg"-nh"$colClear" don't show headers"
      echo -e $colArg"-p <N>"$colClear" show previous N jobs, default is 5"
      echo -e $colArg"-u <USER>"$colClear" show USER's queue"
      echo -e $colArg"-q "$colClear" Show pending jobs for all users"
      echo -e $colArg"-i "$colClear" Show idle nodes"
      echo -e $colArg"-a "$colClear" Show active jobs about to end for all users"
      echo -e $colArg"-hist [<TIME_STR>]"$colClear" Show a user's history"
      echo -e $colArg"-j <JOB_ID>"$colClear" Show job info"
      exit 1
      ;;
    -l)
      shift
      LOOP=1
      ;;
    -nh|--no-headers)
      shift
      HEADERS=0
      ;;
    -louie)
      shift
      USERCODE=ls00338
      ;;
    -cedric)
      shift
      USERCODE=cv00220
      ;;
    -max)
      shift
      USERCODE=mw00368
      ;;
    -roisin)
      shift
      USERCODE=rg00700
      ;;
    -george)
      shift
      USERCODE=gf00304
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
    -si)
      shift
      sinfo
      exit
      ;;
    -i|-idle|--idle)
      shift
      IDLE=1
      ;;
    -a|-r)
      shift
      RUNNING=1
      ;;
    -q)
      shift
      PENDING=1
      ;;
    --history|--hist)
      shift
      HISTORY=$1
      shift
      ;;
    -p)
      shift
      SHOW_PREV_NUM=$1
      shift
      ;;
    -j)
      shift
      JOB=$1
      shift
      ## show job info
      scontrol show job $JOB
      exit 0
      ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      echo -e "See "$colFunc"sq"$colClear$colArg" -h "$colClear"for usage."
      exit 2
      ;;
  esac
done

if [[ $(hostname) == *eslogin* ]] ; then
  if [ $LOOP -eq 1 ] ; then
    while :
    do
      clear
      qstat -u maxwin
      echo -e "\nPress [CTRL+C] to stop.."
      sleep 1.0
    done
  else
    qstat -u maxwin
  fi
  exit 0
fi

function convert4showtime {
  TIME=$1
  IFS=- read DAYS TIME <<< "$TIME"
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

  TIME_STRING=""
  if [ $day -ne 0 ]; then TIME_STRING="$day""d "; fi
  if [ $hour -ne 0 ]; then TIME_STRING=$TIME_STRING"$hour""h "; fi
  if [ $min -ne 0 ]; then TIME_STRING=$TIME_STRING"$min""m "; fi
  if [ $sec -ne 0 ]; then TIME_STRING=$TIME_STRING"$sec""s "; fi
  echo -e "$TIME_STRING"
}

function header_strings {
  # Header strings
  # HDR_JOBID_NAME_NODES=$colUnderline$colBold"Job ID$colClear '$colUnderline"$colVarName"Job Name$colClear' $colVarType$colUnderline# Nodes"$colClear" "
  HDR_JOBID_NAME_NODES=$colUnderline$colBold"Job ID$colClear '$colUnderline"$colVarName"Job Name$colClear'               $colVarType$colUnderline# Nodes"$colClear" "
  HDR_PART_NODES="("$colArg$colUnderline"partition$colClear:"$colArg$colUnderline"nodes$colClear)"
  HDR_ELAPSED=$colResult$colUnderline"Elapsed$colClear"
  HDR_PART="("$colArg$colUnderline"partition$colClear)"
  HDR_LIMIT=$colResult$colUnderline"(Limit)$colClear "
}

function show_queue {
  header_strings

  # get the queue and number of jobs
  # QUEUE=$(squeue -l -u $USERCODE)
  QUEUE=$(squeue -o "%.18i %.9P %.22j %.8u %.8T %.10M %.9l %.6D %R" -u $USERCODE)
  nRUNNING=$(echo -e "$QUEUE" |  grep "RUNNING" | wc -l )
  nPENDING=$(echo -e "$QUEUE" |  grep "PENDING" | wc -l )

  # output
  echo -e $colBold$USERCODE"'s queue"$colClear

  # blank lines for padding
  # NAME_LINE='        '
  NAME_LINE='                  '
  NAME_LINE='                      '
  TIME_LINE="              "
  LIMIT_LINE="     "

  # running job summary
  if [ $nRUNNING -eq 0 ] ; then
    echo -e $colSuccess"\nNo jobs running."$colClear
  else
    echo -e $colSuccess"\nRunning: $nRUNNING"$colClear
    if [ $HEADERS -eq 1 ] ; then
      if [ $SHORT -eq 0 ] ; then
        echo -e "\n""$HDR_JOBID_NAME_NODES""$HDR_ELAPSED""        ""$HDR_LIMIT""$HDR_PART_NODES"
      else
        echo -e "\n""$HDR_JOBID_NAME_NODES""$HDR_ELAPSED"
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

      TIME=$TIME${TIME_LINE:${#TIME}}

      LIMIT="("$LIMIT")"${LIMIT_LINE:${#LIMIT}}

      TIME_STRING="$colResult$TIME$colClear $colResult$LIMIT$colClear"

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
        echo -e "\n""$HDR_JOBID_NAME_NODES"$colResult$colUnderline"Approx. Start$colClear  ""$HDR_PART"
      else
        echo -e "\n""$HDR_JOBID_NAME_NODES"$colResult$colUnderline"Approx. Start$colClear"
      fi
    fi

    # QUEUE=$(squeue --start -u $USERCODE)
    QUEUE=$(squeue --start --format="%.18i %.9P %.22j %.8u %.2t %.19S %.6D %20Y %R" -u $USERCODE)
    # echo $QUEUE
    JOBIDS=$(echo -e "$QUEUE" | grep "PD" | awk '{print $1}')
    for JOB in $JOBIDS; do
      PARTITION=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $2}')
      NAME=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $3}')
      NAME="'"$colVarName$NAME$colClear"'""${NAME_LINE:${#NAME}}"
      START_TIME=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $6}')
      NODES=$(echo -e "$QUEUE" |  grep $JOB | awk '{print $7}')

      if [[ "$START_TIME" != *"N/A"* ]] ; then
        REMAINING=$(( $(date +%s -d "$START_TIME") - $( date +%s ) ))
        REMAINING=$(show_time $REMAINING)
        REMAINING=$REMAINING${TIME_LINE:${#REMAINING}}
      else
        REMAINING="N/A"${TIME_LINE:3}
      fi
      if [ $SHORT -eq 1 ] ; then
        echo -e $colBold$JOB$colClear "$NAME"" $colVarType$NODES nodes $colClear"$colResult"$REMAINING"$colClear
      else
        echo -e $colBold$JOB$colClear "$NAME"" $colVarType$NODES nodes $colClear"$colResult"$REMAINING"$colClear "($colArg$PARTITION$colClear)"
      fi

    done
  fi
}

function prev_queue {

  # Previous jobs  
  if [ $SHOW_PREV_NUM -gt 0 ] ; then
    echo -e $colBold$colFile"\nPrevious $SHOW_PREV_NUM jobs:"$colClear
    
    LAST_WEEK_DATE=$(date --date="14 days ago" +"%Y-%m-%d")
    # sacct --starttime $LAST_WEEK_DATE --format=JobID,Jobname,partition,state,start,elapsed,time,nnodes,nodelist | grep "COMPLETED\|FAILED\|CANCELLED" | grep -v "batch" | tail -n $SHOW_PREV_NUM
    sacct --user=$USERCODE --starttime $LAST_WEEK_DATE --format=JobID,Jobname%22,partition,state,start,elapsed,time,nnodes,nodelist | grep "COMPLETED\|FAILED\|CANCELLED\|TIMEOUT" | grep -v "extern\|batch\|hydra\|\..*       "| tail -n $SHOW_PREV_NUM > __temp__

    if [ $SHORT -eq 0 ] ; then
      echo -e "\n""$HDR_JOBID_NAME_NODES"$colResult$colUnderline"Job Start Time$colClear  ""$HDR_PART_NODES"
    else
      echo -e "\n""$HDR_JOBID_NAME_NODES"$colResult$colUnderline"Job Start Time$colClear"
    fi

    while read -r LINE; do
      JOB_ID=$(echo $LINE | awk '{print $1}')
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

      START=$(date --date="$START" "+%b %-d`DaySuffix $START` %R")

      START_LINE="              "
      START=$START${START_LINE:${#START}}

      JOB_NAME="'"$colVarName$JOB_NAME$colClear"'""${NAME_LINE:${#JOB_NAME}}"
      ELAPSED=$(convert4showtime $ELAPSED)
      STATUS=$(echo $STATUS | tr [:upper:] [:lower:] | sed -E "s/[[:alnum:]_'-]+/\u&/g")

      PARTITION_LINE="                                                            "
      PARTITION_STR="("$colArg$PARTITION$colClear":"$colArg$NODES$colClear")"
      PARTITION_STR=$PARTITION_STR${PARTITION_LINE:${#PARTITION_STR}}

      if [ $SHORT -eq 0 ] ; then
        if [[ $ELAPSED == "" ]] ; then
          echo -e $colBold$JOB_ID$colClear" ""$JOB_NAME"" "$colVarType$NUM_NODES" nodes"$colClear $colResult"$START" $colClear" "$PARTITION_STR" "$ELAPSED_COLOR$STATUS" pre-start"$colClear
        else
          echo -e $colBold$JOB_ID$colClear" ""$JOB_NAME"" "$colVarType$NUM_NODES" nodes"$colClear $colResult"$START" $colClear" "$PARTITION_STR" "$ELAPSED_COLOR$STATUS", "$ELAPSED_COLOR$ELAPSED$colClear
        fi
      else
        echo -e $colBold$JOB_ID$colClear" ""$JOB_NAME"" "$colVarType$NUM_NODES" nodes"$colClear $colResult"$START" $colClear
      fi
    done < __temp__
  fi

  rm __temp__* 2> /dev/null
}

function hist_queue {
  header_strings

  # Previous jobs  
  LAST_WEEK_DATE=$(date --date="$HISTORY ago" +"%Y-%m-%d")
  
  echo -e $colBold$colFile"\nJobs since $LAST_WEEK_DATE:"$colClear
  # sacct --starttime $LAST_WEEK_DATE --format=JobID,Jobname,partition,state,start,elapsed,time,nnodes,nodelist | grep "COMPLETED\|FAILED\|CANCELLED" | grep -v "batch" | tail -n $SHOW_PREV_NUM
  sacct --user=$USERCODE --starttime $LAST_WEEK_DATE --format=JobID,Jobname%22,partition,state,start,elapsed,time,nnodes,nodelist | grep "COMPLETED\|FAILED\|CANCELLED\|TIMEOUT" | grep -v "extern\|batch\|hydra\|\..*       " > __temp__

  if [ $SHORT -eq 0 ] ; then
    echo -e "\n""$HDR_JOBID_NAME_NODES"$colResult$colUnderline"Job Start Time$colClear  ""$HDR_PART_NODES"
  else
    echo -e "\n""$HDR_JOBID_NAME_NODES"$colResult$colUnderline"Job Start Time$colClear"
  fi

  while read -r LINE; do
    JOB_ID=$(echo $LINE | awk '{print $1}')
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

    START=$(date --date="$START" "+%b %-d`DaySuffix $START` %R")

    START_LINE="              "
    START=$START${START_LINE:${#START}}

    JOB_NAME="'"$colVarName$JOB_NAME$colClear"'""${NAME_LINE:${#JOB_NAME}}"
    ELAPSED=$(convert4showtime $ELAPSED)
    STATUS=$(echo $STATUS | tr [:upper:] [:lower:] | sed -E "s/[[:alnum:]_'-]+/\u&/g")

    PARTITION_LINE="                                                            "
    PARTITION_STR="("$colArg$PARTITION$colClear":"$colArg$NODES$colClear")"
    PARTITION_STR=$PARTITION_STR${PARTITION_LINE:${#PARTITION_STR}}

    if [ $SHORT -eq 0 ] ; then
      if [[ $ELAPSED == "" ]] ; then
        echo -e $colBold$JOB_ID$colClear" ""$JOB_NAME"" "$colVarType$NUM_NODES" nodes"$colClear $colResult"$START" $colClear" "$PARTITION_STR" "$ELAPSED_COLOR$STATUS" pre-start"$colClear
      else
        echo -e $colBold$JOB_ID$colClear" ""$JOB_NAME"" "$colVarType$NUM_NODES" nodes"$colClear $colResult"$START" $colClear" "$PARTITION_STR" "$ELAPSED_COLOR$STATUS", "$ELAPSED_COLOR$ELAPSED$colClear
      fi
    else
      echo -e $colBold$JOB_ID$colClear" ""$JOB_NAME"" "$colVarType$NUM_NODES" nodes"$colClear $colResult"$START" $colClear
    fi
  done < __temp__

  # rm __temp__* 2> /dev/null

}

function pend_queue {
  squeue -l | head -n2
  echo -ne $colBold
  MYPEND=$(squeue -l -u $USERCODE | grep PENDING)
  echo "$MYPEND"
  echo -ne $colClear
  OTHERPEND=$(squeue -l | grep PENDING | grep -v $USERCODE)
  echo "$OTHERPEND"
  varOut "$USERCODE's pending jobs" $(echo "$MYPEND" | grep $USERCODE | wc -l)
  varOut "Other pending jobs" $(echo "$OTHERPEND" | wc -l)
}

function idle_queue {
  HEADER=$(sinfo -N -o "%N %R %T %.6m %c %.30f" | head -n1)
  OP_IDLES=$(sinfo -N -o "%N %R %T %.6m %c %.30f" | grep idle | grep op | grep -v debug)
  DEBUG_IDLES=$(sinfo -N -o "%N %R %T %.6m %c %.30f" | grep idle | grep debug)
  V2_IDLES=$(sinfo -N -o "%N %R %T %.6m %c %.30f" | grep idle | grep ",v2")
  CHEM_IDLES=$(sinfo -N -o "%N %R %T %.6m %c %.30f" | grep reserved | grep "node43\|node44\|node55\|node56")
  OTHERIDLES=$(sinfo -N -o "%N %R %T %.6m %c %.30f" | grep idle | grep -v op | grep -v debug | grep -v ",v2" | grep -v "node43\|node44\|node55\|node56")

  echo -e "$(echo -e "$HEADER$cGREEN\n$OP_IDLES$cYELLOW\n$V2_IDLES$cCYAN\n$CHEM_IDLES$cRED\n$DEBUG_IDLES$colClear\n$OTHERIDLES$colClear" | column -t)"
}

function running_queue {
  SBOLD=$(printf '%s\n' "$colBold" | sed -e 's/[]\/$*.^[]/\\&/g')
  SCLEAR=$(printf '%s\n' "$colClear" | sed -e 's/[]\/$*.^[]/\\&/g')
  SFAINT=$(printf '%s\n' "$cFAINT" | sed -e 's/[]\/$*.^[]/\\&/g')

  SRED=$(printf '%s\n' "$cRED" | sed -e 's/[]\/$*.^[]/\\&/g')
  SGREEN=$(printf '%s\n' "$cGREEN" | sed -e 's/[]\/$*.^[]/\\&/g')
  SBLUE=$(printf '%s\n' "$cBLUE" | sed -e 's/[]\/$*.^[]/\\&/g')
  SCYAN=$(printf '%s\n' "$cCYAN" | sed -e 's/[]\/$*.^[]/\\&/g')
  SYELLOW=$(printf '%s\n' "$cYELLOW" | sed -e 's/[]\/$*.^[]/\\&/g')
  SMAGENTA=$(printf '%s\n' "$cMAGENTA" | sed -e 's/[]\/$*.^[]/\\&/g')
  SBBLUE=$(printf '%s\n' "$cBBLUE" | sed -e 's/[]\/$*.^[]/\\&/g')

  QUEUE=$(squeue -S "f,e" -o " %.9P %.1T %.6D %f %e %N %v %u" | grep " R \|END_TIME" | sed 's/ R / /' | sed 's/ S / /' | column -t)
  QUEUE=$(echo "$QUEUE" | sed "s/$USERCODE/$SBOLD""$USERCODE""$SCLEAR/" | sed "s/ls00338/$SYELLOW""ls00338""$SCLEAR/" | sed "s/rg00700/$SYELLOW""rg00700""$SCLEAR/" | sed "s/cv00220/$SYELLOW""cv00220""$SCLEAR/" | sed "s/chemistry_30/$SCYAN""chemistry_30""$SCLEAR/" | sed "s/op/$SGREEN""op""$SCLEAR/" | sed "s/(null)/      /; s/(null)/      /")

  echo -e "$QUEUE" | head -n50

  # echo -e "$(echo -e "$HEADER$cGREEN\n$OP_IDLES$cYELLOW\n$V2_IDLES$cCYAN\n$CHEM_IDLES$cRED\n$DEBUG_IDLES$colClear\n$OTHERIDLES$colClear" | column -t)"
}

# https://stackoverflow.com/questions/2495459/formatting-the-date-in-unix-to-include-suffix-on-day-st-nd-rd-and-th
DaySuffix() {
    START=$1
    DAYNUM=$(date --date="$START" +%-d)
    DAYNUM_CUT2=$(date --date="$START" +%-d | cut -c2)

    if [ "x""$DAYNUM_CUT2""x" = "xx" ]
    then
        DayNum="$DAYNUM"
    else
        DayNum="$DAYNUM_CUT2"
    fi

    CheckSpecialCase=$DAYNUM_CUT2
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

if [ "$HISTORY" != "0" ] ; then
  if [ "$HISTORY" == "" ] ; then
    HISTORY="6 months"
  fi

  # echo "UNSUPPORTED"
  hist_queue

elif [ $PENDING -eq 1 ] ; then

  if [ $LOOP -eq 1 ] ; then
    while :
    do
      clear
      pend_queue
      echo -e "\nPress [CTRL+C] to stop.."
      sleep 1.0
    done
  else
    pend_queue
  fi
  exit 0

elif [ $IDLE -eq 1 ] ; then

  if [ $LOOP -eq 1 ] ; then
    while :
    do
      clear
      idle_queue
      echo -e "\nPress [CTRL+C] to stop.."
      sleep 1.0
    done
  else
    idle_queue
  fi
  exit 0

elif [ $RUNNING -eq 1 ] ; then

  if [ $LOOP -eq 1 ] ; then
    while :
    do
      clear
      running_queue
      echo -e "\nPress [CTRL+C] to stop.."
      sleep 1.0
    done
  else
    running_queue
  fi
  exit 0

else

  if [ $LOOP -eq 1 ] ; then
    while :
    do
      clear
      show_queue
      prev_queue
      echo -e "\nPress [CTRL+C] to stop.."
      sleep 1.0
    done
  else
    show_queue
    prev_queue
  fi
  exit 0

fi

