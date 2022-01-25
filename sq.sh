#!/bin/bash

# To-Do's
#  - Show node category in running queue
#  - Short output for running, show_queue
#  - Pretty output for pending queue

source $MWSHPATH/colours.sh
source $MWSHPATH/out.sh

LOOP=0
SHORT=0
HEADERS=1
PENDING=0
RUNNING=0
CLUSTER=0
IDLE=0
HISTORY=0
JOB=0

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
    -c)
      shift
      CLUSTER=1
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
    -hist|--history|--hist)
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
      # scontrol show job $JOB
      # exit 0
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
  QUEUE=$(squeue -o "%.18i %.9P %.22j %.8u %.8T %.10M %.9l %.6D %R %v" -u $USERCODE)
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

    echo -e $colSuccess"\nRunning: $nRUNNING"$colClear"\n"

    RAW_HEADER="$colUnderline$colBold""User$colClear|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colVarName"Job Name$colClear|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colResult"End Time$colClear|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colVarType"#N #C$colClear|"
    RAW_HEADER=$RAW_HEADER$colUnderline"("$colArg"Partition"$colClear$colUnderline":"$colArg"NodeList$colClear$colUnderline)"$colClear"|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colVarName"Features$colClear\n"

    RAW_QUEUE=$(squeue -S "f,e" -o "%F %j %M %D %C %P %N %f %v" -t R -u $USERCODE | tail -n+2)

    QUEUE=$(echo -e "$RAW_QUEUE")

    IFS=$'\n'
    read -ra QUEUE_ARR -d '' <<< "$QUEUE"

    QUEUE="$RAW_HEADER"

    for LINE in "${QUEUE_ARR[@]}"; do

      IFS=" "
      read -ra SPLIT_LINE <<< "$LINE"

      QUEUE=$QUEUE"$colBold${SPLIT_LINE[0]}$colClear|"
      QUEUE=$QUEUE"$colVarName${SPLIT_LINE[1]}$colClear|"
      
      REMAINING=$(convert4showtime ${SPLIT_LINE[2]})
      QUEUE=$QUEUE"$colResult$REMAINING$colClear|"
      
      QUEUE=$QUEUE"$colVarType${SPLIT_LINE[3]}$colClear "
      QUEUE=$QUEUE"$colVarType${SPLIT_LINE[4]}c$colClear|"

      QUEUE=$QUEUE"($colArg${SPLIT_LINE[5]}$colClear:"
      QUEUE=$QUEUE"$colArg${SPLIT_LINE[6]}$colClear)"

      if [[ "${SPLIT_LINE[7]}" != *"(null)"* ]] ; then
        QUEUE=$QUEUE"|$colVarName${SPLIT_LINE[7]}$colClear "
      else
        QUEUE=$QUEUE"|"
      fi

      if [[ "${SPLIT_LINE[8]}" != *"(null)"* ]] ; then
        QUEUE=$QUEUE"$colVarName${SPLIT_LINE[8]}$colClear"
      else
        QUEUE=$QUEUE""
      fi
      
      QUEUE=$QUEUE"\n"

    done

    echo -ne "$QUEUE" | table.sh -s "|"

  fi

  #pending job summary
  if [ $nPENDING -eq 0 ] ; then
    echo -e $colError"\nNo jobs pending."$colClear
  else

    echo -e $colError"\nPending: $nPENDING"$colClear"\n"

    RAW_HEADER="$colUnderline$colBold""User$colClear|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colVarName"Job Name$colClear|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colResult"Approx. Start$colClear|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colVarType"#N #C$colClear|"
    RAW_HEADER=$RAW_HEADER$colUnderline"("$colArg"Partition"$colClear"$colClear$colUnderline)"$colClear"|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colVarName"Features$colClear\n"

    RAW_QUEUE=$(squeue -S "f,e" -o "%F %j %S %D %C %P %f %v" -t PENDING -u $USERCODE | tail -n+2)

    QUEUE=$(echo -e "$RAW_QUEUE")

    IFS=$'\n'
    read -ra QUEUE_ARR -d '' <<< "$QUEUE"

    QUEUE="$RAW_HEADER"

    for LINE in "${QUEUE_ARR[@]}"; do

      IFS=" "
      read -ra SPLIT_LINE <<< "$LINE"

      QUEUE=$QUEUE"$colBold${SPLIT_LINE[0]}$colClear|"
      QUEUE=$QUEUE"$colVarName${SPLIT_LINE[1]}$colClear|"

      REMAINING=${SPLIT_LINE[2]}
      if [[ "$REMAINING" != *"N/A"* ]] ; then
        REMAINING=$(( $(date +%s -d "$REMAINING") - $( date +%s ) ))
        REMAINING=$(show_time $REMAINING | xargs)
      fi
      QUEUE=$QUEUE"$colResult$REMAINING$colClear|"
      
      QUEUE=$QUEUE"$colVarType${SPLIT_LINE[3]}$colClear "
      QUEUE=$QUEUE"$colVarType${SPLIT_LINE[4]}c$colClear|"

      QUEUE=$QUEUE"($colArg${SPLIT_LINE[5]}$colClear)"

      if [[ "${SPLIT_LINE[6]}" != *"(null)"* ]] ; then
        QUEUE=$QUEUE"|$colVarName${SPLIT_LINE[6]}$colClear "
      else
        QUEUE=$QUEUE"|"
      fi

      if [[ "${SPLIT_LINE[7]}" != *"(null)"* ]] ; then
        QUEUE=$QUEUE"$colVarName${SPLIT_LINE[7]}$colClear"
      else
        QUEUE=$QUEUE""
      fi
      
      QUEUE=$QUEUE"\n"

    done

    echo -ne "$QUEUE" | table.sh -s "|"

  fi
}

function prev_queue {

  # Previous jobs  
  if [ $SHOW_PREV_NUM -gt 0 ] ; then

    RAW_HEADER=$colUnderline$colBold"JobID$colClear|"
    RAW_HEADER=$RAW_HEADER"'"$colUnderline$colVarName"Job Name$colClear'|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colVarType"#N #C$colClear|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colResult"Start Time$colClear|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colResult"Run Time$colClear|"
    RAW_HEADER=$RAW_HEADER$colUnderline"("$colArg"Partition"$colClear$colUnderline":"$colArg"NodeList$colClear$colUnderline)"$colClear"|"
    RAW_HEADER=$RAW_HEADER$colUnderline$colBold"Status$colClear\n"

    if [[ $HISTORY != "0" ]] ; then
      LAST_WEEK_DATE=$(date --date="$HISTORY ago" +"%Y-%m-%d")
      echo -e $colBold$colFile"\nJobs since $LAST_WEEK_DATE ($HISTORY ago):"$colClear
      sacct --user=$USERCODE --starttime $LAST_WEEK_DATE --format=JobID,Jobname%30,partition,state,start,elapsed,time,nnodes,ncpus,nodelist%22 | grep "COMPLETED\|FAILED\|CANCELLED\|TIMEOUT" | grep -v "extern\|batch\|hydra\|\..*       " > __temp__
    else
      echo -e $colBold$colFile"\nPrevious $SHOW_PREV_NUM jobs (last fortnight):"$colClear
      LAST_WEEK_DATE=$(date --date="14 days ago" +"%Y-%m-%d")
      sacct --user=$USERCODE --starttime $LAST_WEEK_DATE --format=JobID,Jobname%30,partition,state,start,elapsed,time,nnodes,ncpus,nodelist%22 | grep "COMPLETED\|FAILED\|CANCELLED\|TIMEOUT" | grep -v "extern\|batch\|hydra\|\..*       "| tail -n $SHOW_PREV_NUM > __temp__
    fi

    QUEUE="\n$RAW_HEADER"

    while read -r LINE; do

      IFS=" "
      read -ra SPLIT_LINE <<< "$LINE"

      JOB_ID=${SPLIT_LINE[0]}
      JOB_NAME=${SPLIT_LINE[1]}
      PARTITION=${SPLIT_LINE[2]}
      STATUS=${SPLIT_LINE[3]}

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

      START=${SPLIT_LINE[4]}
      ELAPSED=${SPLIT_LINE[5]}
      MAX_TIME=${SPLIT_LINE[6]}
      NUM_NODES=${SPLIT_LINE[7]}
      NUM_CPUS=${SPLIT_LINE[8]}
      NODES=${SPLIT_LINE[9]}

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

      ELAPSED=$(convert4showtime $ELAPSED)
      STATUS=$(echo $STATUS | tr [:upper:] [:lower:] | sed -E "s/[[:alnum:]_'-]+/\u&/g")
      
      if [[ $ELAPSED == "" ]] ; then
          ELAPSED=""
      fi

      QUEUE=$QUEUE$colBold$JOB_ID$colClear"|"
      QUEUE=$QUEUE"'"$colVarName$JOB_NAME$colClear"'|"
      QUEUE=$QUEUE$colVarType$NUM_NODES" "
      QUEUE=$QUEUE$NUM_CPUS"c"$colClear"|"
      QUEUE=$QUEUE$colResult$START$colClear"|"
      QUEUE=$QUEUE$colResult$ELAPSED$colClear"|"

      if [[ $NODES == "None" ]] ; then
          QUEUE=$QUEUE"("$colArg$PARTITION$colClear
          NODES=""
      else
          QUEUE=$QUEUE"("$colArg$PARTITION$colClear":"
      fi

      QUEUE=$QUEUE$colArg$NODES$colClear")""|"
      QUEUE=$QUEUE$ELAPSED_COLOR$STATUS$colClear"|"
      QUEUE=$QUEUE"\n"

    done < __temp__

    echo -ne "$QUEUE" | table.sh -s "|"

  fi

  rm __temp__* 2> /dev/null
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

function replace_usercodes {

  USER=$1

  USER=$(echo $USER | sed 's/mw00368/max/')
  USER=$(echo $USER | sed 's/ls00338/louie/')
  USER=$(echo $USER | sed 's/cv00220/cedric/')
  USER=$(echo $USER | sed 's/rg00700/roisin/')
  USER=$(echo $USER | sed 's/gf00304/george/')
      
  echo $USER

}

function running_queue {

  RAW_HEADER="$colUnderline$colBold""User$colClear|$colBold$colUnderline"
  RAW_HEADER=$RAW_HEADER"JobID$colClear|"
  RAW_HEADER=$RAW_HEADER$colUnderline$colResult"End Time$colClear|"
  RAW_HEADER=$RAW_HEADER$colUnderline$colVarType"#Node$colClear|"
  RAW_HEADER=$RAW_HEADER$colUnderline$colVarType"#CPU$colClear|"
  RAW_HEADER=$RAW_HEADER$colUnderline"("$colArg"Partition"$colClear$colUnderline":"$colArg"NodeList$colClear$colUnderline)"$colClear"|"
  RAW_HEADER=$RAW_HEADER$colUnderline$colVarName"Features$colClear\n"

  RAW_QUEUE=$(squeue -S "f,e" -o "%u %F %e %D %C %P %N %f %v" -t R | tail -n+2)

  if [ $SHOW_PREV_NUM -eq 10 ] ; then
    SHOW_PREV_NUM=50
  fi

  QUEUE=$(echo -e "$RAW_QUEUE" | head -n$SHOW_PREV_NUM)

  IFS=$'\n'
  read -ra QUEUE_ARR -d '' <<< "$QUEUE"

  QUEUE="$RAW_HEADER"

  for LINE in "${QUEUE_ARR[@]}"; do

    IFS=" "
    read -ra SPLIT_LINE <<< "$LINE"

    QUEUE=$QUEUE"$colBold$(replace_usercodes ${SPLIT_LINE[0]})$colClear|"
    QUEUE=$QUEUE"$colBold${SPLIT_LINE[1]}$colClear|"
    
    REMAINING=$(( $(date +%s -d "${SPLIT_LINE[2]}") - $( date +%s ) ))
    REMAINING=$(show_time $REMAINING)

    QUEUE=$QUEUE"$colResult$REMAINING$colClear|"

    QUEUE=$QUEUE"$colVarType${SPLIT_LINE[3]}$colClear|"
    QUEUE=$QUEUE"$colVarType${SPLIT_LINE[4]}$colClear|"
    QUEUE=$QUEUE"($colArg${SPLIT_LINE[5]}$colClear:"
    QUEUE=$QUEUE"$colArg${SPLIT_LINE[6]}$colClear)|"

    if [[ "${SPLIT_LINE[7]}" != *"(null)"* ]] ; then
      QUEUE=$QUEUE"$colVarName${SPLIT_LINE[7]}$colClear|"
    else
      QUEUE=$QUEUE"|"
    fi

    if [[ "${SPLIT_LINE[8]}" != *"(null)"* ]] ; then
      QUEUE=$QUEUE"$colVarName${SPLIT_LINE[8]}$colClear|"
    else
      QUEUE=$QUEUE"|"
    fi
    
    QUEUE=$QUEUE"\n"

  done

  echo -ne "$QUEUE" | table.sh -s "|"

}

function cluster_info {

  sinfo -N

  # categories

  # debug

  # 

}

function job_info {

  JOB_BUFFER=$(scontrol show job $JOB 2>&1)

  NUM_LINES=$(echo "$JOB_BUFFER" | wc -l)

  if [ $NUM_LINES -eq 1 ] ; then

    # errorOut "Previous jobs unsupported"
    # sacct -X -j $JOB
    
    STR_BUFFER=$(sacct -X -j $JOB -o JobName,User,Account,State,Partition,NNodes,NodeList,NCPUS,Reservation,Timelimit,ExitCode,elapsed -p | tail -n 1)

    IFS="|"

    read -ra INFO_ARR <<< "$STR_BUFFER"

    # ${ARRAY_NAME[2]}

    # Dependency ???
    # Features ???
    # RunTime ???
    # StartTime ???
    # SubmitTime ???
    # WorkDir ???
    # Command ???

    JOB_STATE=${INFO_ARR[3]}
    JOB_NAME=${INFO_ARR[0]}

    if [ "$JOB_STATE" == "COMPLETED" ] ; then
      varOutEx "Completed Job" "$JOB_NAME" "$JOB" $colVarName $colBold
    elif [ "$JOB_STATE" == "FAILED" ] ; then
      varOutEx "   Failed Job" "$JOB_NAME" "$JOB" $colVarName $colBold
    elif [[ "$JOB_STATE" == "CANCELLED"* ]] ; then
      varOutEx "Cancelled Job" "$JOB_NAME" "$JOB" $colVarName $colBold
    else
      errorOut $JOB_STATE
    fi

    ACCOUNT=${INFO_ARR[2]}
    USERCODE=${INFO_ARR[1]}
    varOutEx "         User" "$USERCODE" "$ACCOUNT" $colBold $colArg

    PARTITION=${INFO_ARR[4]}
    varOut "    Partition" "$PARTITION" "" $colArg

    NUM_NODES=${INFO_ARR[5]}
    NODELIST=${INFO_ARR[6]}
    varOutEx "      # Nodes" "$NUM_NODES nodes" "$NODELIST" $colVarType $colArg

    NUM_CPUS=${INFO_ARR[7]}
    varOut "        #CPUs" "$NUM_CPUS" "" $colVarType

    RESERVATION=${INFO_ARR[8]}
    if [ "$RESERVATION" != "" ] ; then
      varOut "  Reservation" "$RESERVATION" "" $colArg
    fi

    TIME_LIMIT=${INFO_ARR[9]}
    TIME_LIMIT=$(convert4showtime $TIME_LIMIT | xargs)     

    if [[ "$JOB_STATE" == "CANCELLED"* ]] ; then
      varOut "        Limit" "$TIME_LIMIT" "" $colResult
    else
      ELAPSED=${INFO_ARR[11]}
      ELAPSED=$(convert4showtime $ELAPSED | xargs)
      varOutEx "     Run Time" "$ELAPSED" "$TIME_LIMIT" $colResult $colResult
    fi

    IFS=":"
    read -ra EXIT_ARR <<< "${INFO_ARR[10]}"
    EXIT_CODE=${EXIT_ARR[0]}
    if [ $EXIT_CODE -ne 0 ] ; then
      varOut "    Exit Code" "$EXIT_CODE" "" $colError
    else
      varOut "    Exit Code" "$EXIT_CODE" "" $colSuccess
    fi

    if [ "$JOB_STATE" == "COMPLETED" ] ; then
      varOut "       Status" "Completed " "" $colSuccess
    elif [ "$JOB_STATE" == "FAILED" ] ; then
      varOut "       Status" "Failed " "" $colError
    elif [[ "$JOB_STATE" == "CANCELLED by"* ]] ; then
      varOut "       Status" "Cancelled Pre-Start " "" $colWarning
    else
      errorOut $JOB_STATE
    fi
  
  else

    # echo "$JOB_BUFFER"

    JOB_NAME=$(echo "$JOB_BUFFER" | grep -oP "(?<=JobName=).*")
    JOB_STATE=$(echo "$JOB_BUFFER" | grep -oP "(?<=JobState=).*(?= Reason)")
    
    if [ "$JOB_STATE" == "PENDING" ] ; then
      varOutEx "Pending Job" "$JOB_NAME" "$JOB" $colVarName $colBold
    else
      varOutEx "Running Job" "$JOB_NAME" "$JOB" $colVarName $colBold
    fi

    USERCODE=$(echo "$JOB_BUFFER" | sed 's/(/|/' | grep -oP "(?<=UserId=).*(?=\|)")
    ACCOUNT=$(echo "$JOB_BUFFER" | grep -oP "(?<=Account=).*(?= QOS)")
    varOutEx "       User" "$USERCODE" "$ACCOUNT" $colBold $colArg

    PARTITION=$(echo "$JOB_BUFFER" | grep -oP "(?<=Partition=).*(?= AllocNode)")
    varOut "  Partition" "$PARTITION" "" $colArg

    if [ "$JOB_STATE" == "PENDING" ] ; then
      NODELIST=$(echo "$JOB_BUFFER" | grep -oP "(?<=SchedNodeList=).*")
      NUM_NODES=$(echo "$JOB_BUFFER" | grep -oP "(?<=NumNodes=).*(?=-)")
    else
      NODELIST=$(echo "$JOB_BUFFER" | grep -oP "(?<=   NodeList=).*")
      NUM_NODES=$(echo "$JOB_BUFFER" | grep -oP "(?<=NumNodes=).*(?= NumCPUs)")
    fi

    if [ "$NODELIST" == "" ] ; then
      varOut "    # Nodes" "$NUM_NODES nodes" "" $colVarType
    else
      varOutEx "    # Nodes" "$NUM_NODES nodes" "$NODELIST" $colVarType $colArg
    fi
    
    NUM_CPUS=$(echo "$JOB_BUFFER" | grep -oP "(?<=NumCPUs=).*(?= NumTasks)")
    varOut "      #CPUs" "$NUM_CPUS" "" $colVarType

    DEPENDENCY=$(echo "$JOB_BUFFER" | grep -oP "(?<=Dependency=).*")
    if [ "$DEPENDENCY" != "(null)" ] ; then
      varOut " Dependency" "$DEPENDENCY" "" $colArg
    fi

    FEATURES=$(echo "$JOB_BUFFER" | grep -oP "(?<=Features=).*(?= DelayBoot)")
    if [ "$FEATURES" != "(null)" ] ; then
      varOut "   Features" "$FEATURES"
    fi

    RESERVATION=$(echo "$JOB_BUFFER" | grep -oP "(?<=Reservation=).*")
    if [ "$RESERVATION" != "(null)" ] ; then
      varOut "Reservation" "$RESERVATION" "" $colArg
    fi

    ### Timings

    TIME_LIMIT=$(echo "$JOB_BUFFER" | grep -oP "(?<=TimeLimit=).*(?= TimeMin)")
    TIME_LIMIT=$(convert4showtime $TIME_LIMIT)

    if [ "$JOB_STATE" == "RUNNING" ] ; then
      ELAPSED=$(echo "$JOB_BUFFER" | grep -oP "(?<=RunTime=).*(?= TimeLimit)")
      ELAPSED=$(convert4showtime $ELAPSED)
      varOutEx "   Run Time" "$ELAPSED" "$TIME_LIMIT" $colResult $colResult
    else
      varOut "      Limit" "$TIME_LIMIT" "" $colResult
    
      REMAINING=$(echo "$JOB_BUFFER" | grep -oP "(?<=StartTime=).*(?= EndTime)")

      if [[ "$REMAINING" != *"N/A"* ]] ; then
        if [[ "$REMAINING" != *"Unknown"* ]] ; then
          REMAINING=$(( $(date +%s -d "$REMAINING") - $( date +%s ) ))
          REMAINING=$(show_time $REMAINING)
        fi
      else
        REMAINING="N/A"
      fi
      varOut "Approx Wait" "$REMAINING" "" $colResult

      QUEUE=$(echo "$JOB_BUFFER" | grep -oP "(?<=SubmitTime=).*(?= Eligible)")

      if [[ "$QUEUE" != *"N/A"* ]] ; then
        QUEUE=$(( $( date +%s ) - $(date +%s -d "$QUEUE")))
        QUEUE=$(show_time $QUEUE)
      else
        QUEUE="N/A"
      fi
      varOut " Queue Time" "$QUEUE" "" $colResult

    fi

    WORKDIR=$(echo "$JOB_BUFFER" | grep -oP "(?<=WorkDir=).*")
    varOut "  Directory" "$WORKDIR" "" $colFile

    COMMAND=$(echo "$JOB_BUFFER" | grep -oP "(?<=Command=).*")
    varOut "     Script" "$COMMAND" "" $colFile

    if [ "$DEPENDENCY" != "(null)" ] ; then
      IFS=":"
      read -ra DEP_ARR <<< "$DEPENDENCY"
      DEPENDENCY=${DEP_ARR[1]}
      headerOut "\nDependency $DEPENDENCY:"
      JOB=$DEPENDENCY
      job_info
    fi

  fi

  # Extra Fields
  # Endtime?
  # Exclusive?
  # mem
  # Priority?
  # StdErr
  # StdOut
  
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

if [ $CLUSTER -ne 0 ] ; then

  cluster_info

elif [ $JOB -ne 0 ] ; then

  job_info

elif [ "$HISTORY" != "0" ] ; then
  if [ "$HISTORY" == "" ] ; then
    HISTORY="6 months"
  fi

  # hist_queue
  prev_queue

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

