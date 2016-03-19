#!/bin/bash

LENGTH=10
NUMBER=5

usage() {
  cat <<-EOF

  $(basename $0) - simple password generator

  Usage: $0 [options]
  Options:
    -l, --length VALUE   length of password.  default value is 10
    -n, --number VALUE   number of passwords. default value is 5
    -h, --help           output help information

EOF
}

check_arg () {
  if [[ $1 =~ [^0-9] ]] || [[ -z $1 ]]
  then
    echo -e "Unknow argument $1"
    exit 1
  fi
}

while [[ $# -ne 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -l|--length)
      check_arg $2
      LENGTH=$2
      shift
      ;;
    -v|--version)
      version
      exit 0
      ;;
    -n|--number)
      check_arg $2
      NUMBER=$2
      shift
      ;;
    *)
      echo -e "$1 option is not found!\nSee help: $0 -h"
      exit 1
      ;;
  esac
  shift
done

for (( i=0; i<$NUMBER; i++ ))
  do
  < /dev/urandom tr -dc A-Z-a-z-0-9 | head -c$LENGTH
  echo
done

exit 0
