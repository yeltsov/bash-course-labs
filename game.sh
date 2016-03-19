#!/bin/bash

declare -A fields
declare -A objects

rows=10
cols=10

difficult=2

#player
player_happy="\xF0\x9F\x98\x83"
player_wink="\xF0\x9F\x98\x89"
player_smile="\xF0\x9F\x98\x8A"
player_cool="\xF0\x9F\x98\x8E"
player_scream="\xF0\x9F\x98\xB1"

#arrow
arrow_up="\xE2\xAC\x86"
arrow_down="\xE2\xAC\x87"
arrow_left="\xE2\xAC\x85"
arrow_right="\xE2\x9E\xA1"

#objects
empty="\xE2\x9A\xAA"
wall="\xE2\xAC\x9B"
object="\xE2\x9A\xAB"
alarm="\xE2\x8F\xB0"
fire="\xF0\x9F\x94\xA5"

#ui
hand_set="\xE2\x9C\x8B"
hand_unset="\xE2\x9C\x8A"
close="\xE2\x9C\x96"
sand_clock="\xE2\x8F\xB3"
neighbor_sleep="\xF0\x9F\x98\xB4"
neighbor_angry="\xF0\x9F\x98\xA1"
heart="\xF0\x9F\x92\x99"

f=" %b"

usage() {
  cat <<-EOF

  saving sleeping neighbour zzZZ

  controls:
  W = up
  A = left
  S = down
  D = right
  J = put alarm clock
  K = take alarm clock
  Q = close

  options:
  -h, --help              output help information
  -r, --rows VALUE        rows of game field      10..32    default - 10
  -c, --cols VALUE        columns of game field   10..32    default - 10
  -d, --difficult VALUE   game difficult          1..3      default - 2

EOF
}

initial_state() {
  let current_row=$rows/2
  let current_col=$cols/2
  player_active=$player_happy
  let arrow_row=$current_row+1
  arrow_col=$current_col
  arrow_active=$arrow_down
  let time_level=180/$difficult
  let lifes=4/$difficult
  random_alarms=$((rows*cols*difficult*2/10))
  random_fires=$((random_alarms/10))

  for ((i=random_alarms+random_fires;i>0;i--)) do
    random_row=$((RANDOM%rows))
    random_col=$((RANDOM%cols))
    if !((objects[$random_row,$random_col])) && ((random_row!=current_row)) && ((random_col!=current_col)); then
      if ((i>random_fires)); then
        objects[$random_row,$random_col]=1
      else
        objects[$random_row,$random_col]=2
      fi
    else
      let i++
    fi
  done

  last_alarms=$random_alarms
  time_start=$(date +%s)
}

set_state() {
  for ((i=0;i<rows;i++)) do
    for ((j=0;j<cols;j++)) do
      if ((current_row==i)) && ((current_col==j)); then
        fields[$i,$j]=$player_active
      elif ((objects[$i,$j]==1)); then
        fields[$i,$j]=$alarm
      elif ((objects[$i,$j]==2)); then
        fields[$i,$j]=$fire
      elif ((arrow_row==i)) && ((arrow_col==j)); then
        fields[$i,$j]=$arrow_active
      else
        fields[$i,$j]=$empty
      fi
    done
  done
}

render() {

  echo -e "$(clear)${close} Q  ${arrow_up} W"
  echo -e "${arrow_left} A  ${arrow_down} S  ${arrow_right} D  ${hand_set} J  ${hand_unset} K\n"

  print_frame

  for ((i=0;i<rows;i++)) do
    printf "$f" $wall
    for ((j=0;j<cols;j++)) do
      printf "$f" ${fields[$i,$j]}
    done
    printf "$f" $wall
    echo
  done

  print_frame
  check_fire
  time_end=$(date +%s)
  time_result="$((time_level-((time_end-time_start))))"
  printf "$f" "$sand_clock $time_result" "$alarm $last_alarms" "$heart $lifes"
  if ((last_alarms<=0)); then
    let game_points=$time_result*$difficult*100
    printf "$f" "$neighbor_sleep"
    echo
    printf "$f" "PROFIT!" "$game_points points"
    exit 0
  fi
  if ((time_result<=0)) || ((lifes<=0)); then
    printf "$f" "$neighbor_angry"
    echo
    printf "$f" "WASTED!"
    exit 0
  else
    printf "$f" "$neighbor_sleep"
    echo
  fi
  reset_player_face
}

print_frame() {
  for ((j=0;j<cols+2;j++)) do
    printf "$f" $wall
  done
  echo
}

check_fire() {
  if ((objects[$current_row,$current_col]==2)); then
    let lifes--
  fi
}

set_object() {
  objects[$arrow_row,$arrow_col]=1
  player_active=$player_wink
  let last_alarms++
}

unset_object() {
  objects[$arrow_row,$arrow_col]=0
  player_active=$player_smile
  let last_alarms--
}

reset_player_face() {
  player_active=$player_happy
}

move_up(){
  let current_row--
  let arrow_row=$current_row-1
  arrow_col=$current_col
  arrow_active=$arrow_up
}

move_down() {
  let current_row++
  let arrow_row=$current_row+1
  arrow_col=$current_col
  arrow_active=$arrow_down
}

move_left() {
  let current_col--
  let arrow_col=$current_col-1
  arrow_active=$arrow_left
  arrow_row=$current_row
}

move_right() {
  let current_col++
  let arrow_col=$current_col+1
  arrow_active=$arrow_right
  arrow_row=$current_row
}

allowed_object?(){
  ((arrow_row<rows)) && ((arrow_row>-1)) && ((arrow_col<cols)) && ((arrow_col>-1))
}

check_grid_args(){
  if (($1<10)) || (($1>32)); then
    echo -e "grid $1 arg is not in the range 10..32"
    exit 1
  fi
}

check_difficult_args(){
  if (($1<1)) || (($1>3)) ; then
    echo -e "difficult $1 arg is not in the range 1..3"
    exit 1
  fi
}

if [[ $# -eq 0 ]]; then
  usage
  read -p "press S to start" -s -n 1 command
  case $command in
    s)  break ;;
    *)  echo -e "\nok :("; exit 1
  esac
fi

while [[ $# -ne 0 ]]; do
  case $1 in
    -h|--help)
    usage
    exit 0
    ;;
    -r|--rows)
    check_grid_args $2
    rows=$2
    shift
    ;;
    -c|--cols)
    check_grid_args $2
    cols=$2
    shift
    ;;
    -d|--difficult)
    check_difficult_args $2
    difficult=$2
    shift
    ;;
    *)
    echo -e "$1 option is not found!\nsee help: $0 -h"
    exit 1
    ;;
  esac
  shift
done

initial_state
while :;do
  set_state
  render
  read -t 1 -s -n 1 command
  case $command in
    a)  !((objects[$current_row,$((current_col-1))]==1)) && ((current_col)) && move_left ;;
    s)  !((objects[$((current_row+1)),$current_col]==1)) && ((current_row!=rows-1)) && move_down ;;
    w)  !((objects[$((current_row-1)),$current_col]==1)) && ((current_row)) && move_up ;;
    d)  !((objects[$current_row,$((current_col+1))]==1)) && ((current_col!=cols-1)) && move_right ;;
    j)  !((objects[$arrow_row,$arrow_col]==1)) && !((objects[$arrow_row,$arrow_col]==2)) && allowed_object? && set_object ;;
    k)  ((objects[$arrow_row,$arrow_col]==1)) && allowed_object? && unset_object ;;
    q)  exit 0
  esac
done
