#!/bin/bash

START=$(date +%s%N)

usage() {
  cat <<-EOF

  $(basename $0) - simple app speed test (ms)

  Usage: $0 [options]
  Options:
    -h, --help           output help information

EOF
}

result() {
  END=$(date +%s%N)
  ms=$(((END-START)/1000000))
  echo
  if ((ms<1000)); then
    echo -e "$ms ms"
  else
    echo -e "$((ms/1000)) s $((ms%1000)) ms"
  fi
  exit 0
}

fail() {
  echo -e "\nUnknow command $1"
  exit 1
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

while [[ $# -ne 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -v|--version)
      version
      exit 0
      ;;
    *)
      echo
      $@ && result || fail $@
      ;;
  esac
done

exit 0
