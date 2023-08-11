#!/usr/bin/env bash

source $MSHTOOLS/out.sh
source $MSHTOOLS/colours.sh

USERCODE=$(grep -oP "(?<=usercode=).*(?=;)" $MSHTOOLS/.suppressed_gitlab)

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "Usage for "$colFunc"rogue.sh"$colClear":"
      echo -e $colArg"-u <USER>"$colClear" show USER's queue"
      exit 1
      ;;
    -louie)
      shift
      USERCODE=ls00338
      ;;
    -u)
      shift
      USERCODE=$1
      shift
      ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      echo -e "See "$colFunc"sq"$colClear$colArg" -h "$colClear"for usage."
      exit 2
      ;;
  esac
done

headerOut "$USERCODE's rogue processes"

LAST_WEEK_DATE=$(date --date="14 days ago" +"%Y-%m-%d")

sacct --user=$USERCODE --starttime $LAST_WEEK_DATE --format=nodelist,state | grep "COMPLETED\|FAILED\|CANCELLED\|TIMEOUT" | grep -v "batch\|hydra\|None assigned" | awk '{print $1}' > __temp__
sacct --user=$USERCODE --starttime $LAST_WEEK_DATE --format=nodelist,state | grep "RUNNING" | grep -v "batch\|hydra\|None assigned\|COMPLETED" | awk '{print $1}' > __temp__2

interrupted_nodes=$(cat __temp__ | tail -n +2)
running_nodes=$(cat __temp__2 | tail -n +2)

interrupted_nodes=$(echo "$interrupted_nodes" | awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,FS)}{printf("\n")}')
running_nodes=$(echo "$running_nodes" | awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,FS)}{printf("\n")}')

nodelist=$interrupted_nodes

for node in $nodelist ; do
  if [[ $node == *"["*"-"*"]" ]] ; then

    # echo -e "expanding: "$colFile$node$colClear

    trimmed=$(echo $node | grep -oP "(?<=\[).*(?=\])")
    start=$(echo $node | grep -oP "(?<=\[).*(?=\-)")
    end=$(echo $node | grep -oP "(?<=\-).*(?=\])")
    node_start=$(echo $node | grep -oP ".*(?=\[)")

    num_seq=$(seq $start $end)

    for num in $num_seq; do

      nodelist2=$nodelist2" $node_start$num"

    done
    
  else
    nodelist2=$nodelist2" $node"
  fi
done

for node in $running_nodes; do
  if [[ $node == *"["*"-"*"]" ]] ; then

    # echo -e "expanding: "$colFile$node$colClear

    trimmed=$(echo $node | grep -oP "(?<=\[).*(?=\])")
    start=$(echo $node | grep -oP "(?<=\[).*(?=\-)")
    end=$(echo $node | grep -oP "(?<=\-).*(?=\])")
    node_start=$(echo $node | grep -oP ".*(?=\[)")

    num_seq=$(seq $start $end)

    for num in $num_seq; do

      # echo -e $colWarning$node_start$num$colClear

      nodelist2=$(echo "$nodelist2" | sed "s/$node_start$num//")

    done
    
  else
    nodelist2=$(echo "$nodelist2" | sed "s/$node//")
  fi
done

nodelist2=$(echo "$nodelist2" | awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,FS)}{printf("\n")}')

# nodelist2="node42 node41"

num_to_check=$(echo "$nodelist2" | wc -w)

headerOut "\nNodes where a job was run in the last fortnight: "$num_to_check$colClear
echo -e $colClear$nodelist2$colClear

echo -e "\n"$colUnderline$colBold"Node$colClear        $colUnderline"$colBold"#$colClear "$colBold$colUnderline"Processes"$colClear

NODE_LINE="           "

for node in $nodelist2; do
  
  echo -ne $colBold$node$colClear"${NODE_LINE:${#node}}"

  # echo "XXX"
  
  ssh -t $node "top -b -n1 -u $USERCODE" > __temp__ 2> /dev/null

  grep $USERCODE __temp__ | grep -v top | grep -v sshd > __temp__2

  num_procs=$(cat __temp__2 | wc -l)

  # cat __temp__2

  # proc_list=$(cat __temp__2 | awk '{print $12}')
  proc_list=$(cat __temp__2 | awk 'NF>1{print $NF}')
  proc_list=$(echo "$proc_list" | sed 's/\r//')
  proc_list=$(echo $proc_list | awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,FS)}{printf("\n")}')

  # echo $proc_list

  if [ $num_procs -eq 0 ] ; then
    echo -ne "$colSuccess"
    echo -e " "$num_procs$colClear
  else
    echo -ne "$colError"
    echo -e " "$num_procs$colClear $colVarName"$proc_list"$colClear
  fi

  rm __temp__*

done

echo -e $colBold"\nTo kill:"$colClear
echo -e "$colFunc""ssh$colClear $colArg\$node"$colClear
echo -e "$colFunc""killall$colClear $colArg-9 \$proc_name"$colClear
echo ""