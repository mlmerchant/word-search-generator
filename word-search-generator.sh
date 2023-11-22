#!/bin/bash

create_letter_grid() {
  # Usage: create_letter_grid 10 10

  local x=$1
  local y=$2
  local grid=()

  for ((i = 0; i < x * y; i++)); do
    grid+=("?")
  done

  # Create a global variable named "letter_grid" to store the grid
  declare -g letter_grid=("${grid[@]}")
}

place_character() {
  # Assumes a global letter_grid.
  # Example usage: place_character 3 4 10 10 "A"

  local x=$1
  local y=$2
  local x_size = $3
  local y_size = $4
  local character=$5

  # Calculate the index for the 1-dimensional array
  local index=$((x + y * x_size))

  # Check if the index is within bounds
  if ((index >= 0 && index < x_size * y_size)); then
    letter_grid[index]=$character
  else
    echo "Error: Invalid coordinates ($x, $y) for grid of size $x_size x $y_size."
  fi
}

get_letter_at_coordinates() {
  # Example usage: get_letter_at_coordinates 3 4 10 10

  local x=$1
  local y=$2
  local x_size=$3
  local y_size=$4

  # Calculate the index for the 1-dimensional array
  local index=$((x + y * x_size))

  # Check if the index is within bounds
  if ((index >= 0 && index < x_size * y_size)); then
    echo "${letter_grid[index]}"
  else
    echo "Error: Invalid coordinates ($x, $y) for grid of size $x_size x $y_size."
  fi
}

get_adjacent_coordinates() {

  # Example usage: get_adjacent_coordinates 3 4 "Up" 10 10

  local current_x=$1
  local current_y=$2
  local direction=$3
  local x_size=$4
  local y_size=$5
  local adjacent_x=-1
  local adjacent_y=-1

  case "$direction" in
    "Up")
      ((adjacent_y = current_y - 1))
      adjacent_x=$current_x
      ;;
    "RightUp")
      ((adjacent_y = current_y - 1))
      ((adjacent_x = current_x + 1))
      ;;
    "Right")
      adjacent_y=$current_y
      ((adjacent_x = current_x + 1))
      ;;
    "RightDown")
      ((adjacent_y = current_y + 1))
      ((adjacent_x = current_x + 1))
      ;;
    "LeftDown")
      ((adjacent_y = current_y + 1))
      ((adjacent_x = current_x - 1))
      ;;
    "Left")
      adjacent_y=$current_y
      ((adjacent_x = current_x - 1))
      ;;
    "LeftUp")
      ((adjacent_y = current_y - 1))
      ((adjacent_x = current_x - 1))
      ;;
    *)
      echo "Error: Invalid direction: $direction"
      return 1
      ;;
  esac

  # Check if the adjacent coordinates are within bounds
  if ((adjacent_x >= 0 && adjacent_x < x_size && adjacent_y >= 0 && adjacent_y < y_size)); then
    echo "$adjacent_x,$adjacent_y"
  else
    echo "-1,-1"
  fi
}

get_random_direction() {

  # Example usage: random_direction=$(get_random_direction)

  local directions=("Up" "RightUp" "Right" "RightDown" "LeftDown" "Left" "LeftUp")
  local random_index=$((RANDOM % ${#directions[@]}))
  echo "${directions[random_index]}"
}

get_random_coordinates() {
   
  # Example usage: random_coords=$(get_random_coordinates 10 10)
 
  local size_x=$1
  local size_y=$2
  local random_x=$((RANDOM % size_x))
  local random_y=$((RANDOM % size_y))
  echo "$random_x,$random_y"
}

print_grid() {

  # Example usage: print_grid 10 10

  local x_size=$1
  local y_size=$2

  for ((y = 0; y < y_size; y++)); do
    for ((x = 0; x < x_size; x++)); do
      local index=$((x + y * x_size))
      local cell_value="${letter_grid[index]}"
      echo -n "$cell_value "
    done
    echo # Move to the next line
  done
}


# Default values
param1=""
param2=""
param3=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      input_file="$2"
      shift 2
      ;;
    --x)
      x_size="$2"
      shift 2
      ;;
    --y)
      y_size="$2"
      shift 2
      ;;
    *)
      echo "Invalid argument: $1"
      exit 1
      ;;
  esac
done


create_letter_grid $x_size $y_size

print_grid $x_size $y_size

