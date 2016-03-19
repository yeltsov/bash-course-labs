#!/bin/bash

show_name=0
show_memory=0
show_state=0

usage() {
  cat <<-EOF

  $(basename $0) - show processes status

  options:
  -n, --name           show name of process
  -s, --state          show name of state
  -m, --memory         show name of memory
  -h, --help           output help information

  yeltsov ilya, 418
  dmitrin yuri, 418

EOF
}

start(){
  for i in /proc/[1-9]*
  do
    printf "%s" "$(basename $i)"
    if ((show_name)); then
      name="$(cat $i/status | grep "Name" | cut -f2)"
      printf " %s" "$name"
    fi
    if ((show_memory)); then
      memory="$(cat $i/status | grep "VmSize" | cut -f2)"
      if [[ -z $memory ]]; then
        memory="--- kB"
      fi
      printf " %s" "$memory"
    fi
    if ((show_state)); then
      state="$(cat $i/status | grep "State" | cut -f2)"
      printf " %s" "$state"
    fi
    echo
  done | sort -n | column -t
}

if [[ $# -eq 0 ]]
  then
  show_name=1
  show_memory=1
  show_state=1
  start
  exit 0
fi

while [[ $# -ne 0 ]]; do
  case $1 in
    -h|--help)
    usage
    exit 0
    ;;
    -n|--name)
    show_name=1
    ;;
    -m|--memory)
    show_memory=1
    ;;
    -s|--state)
    show_state=1
    ;;
    *)
    echo -e "$1 option is not found!\nsee help: $0 -h"
    exit 1
    ;;
  esac
  shift
done

start
exit 0
