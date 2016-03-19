#!/bin/bash

stdin=$(</dev/stdin)

usage() {
  cat <<-EOF

  $(basename $0) - sed filter text app

  Usage: $0 [options]
  Options:
    -d, --unix2dos
    -u, --dos2unix
    -s, --spaces
    -m, --minus
    -h, --help           output help information

EOF
}

if [[ $# -eq 0 ]]
then
  usage
  exit 0
fi

while [[ $# -ne 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -d|--unix2dos)
      stdin=$(echo -n "$stdin" | sed 's/$/\r/' | sed '$ s/\r$//' | sed 's/\r\r/\r/')
      ;;
    -u|--dos2unix)
      stdin=$(echo "$stdin" | sed 's/\r//')
      ;;
    -s|--spaces)
      stdin=$(echo "$stdin" | sed 's/  */ /g')
      ;;
    -m|--minus)
      stdin=$(echo "$stdin" | sed 's/---*/--/g')
      ;;
    *)
      echo -e "$1 option is not found!\nsee help: $0 -h"
      exit 1
      ;;
  esac
  shift
done

echo -n "$stdin"
exit 0
