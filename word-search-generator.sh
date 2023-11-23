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
  local x_size=$3
  local y_size=$4
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
    exit 1
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

convert_letter_grid_to_lowercase() {
  # Example usage: convert_letter_grid_to_lowercase
  for ((i = 0; i < ${#letter_grid[@]}; i++)); do
    letter_grid[i]="${letter_grid[i],,}"
  done
}

convert_letter_grid_to_uppercase() {
  # Example usage: convert_letter_grid_to_uppercase
  for ((i = 0; i < ${#letter_grid[@]}; i++)); do
    letter_grid[i]="${letter_grid[i]^^}"
  done
}

replace_question_with_random_lowercase() {
  # Example usage: replace_question_with_random_lowercase
  for ((i = 0; i < ${#letter_grid[@]}; i++)); do
    if [[ "${letter_grid[i]}" == "?" ]]; then
      random_lowercase_letter=$(tr -dc 'a-z' < /dev/urandom | head -c 1)
      letter_grid[i]="$random_lowercase_letter"
    fi
  done
}

put_word_in_grid() {
  local word=$1
  local x_size=$2
  local y_size=$3

  local finished=0

    while [ "$finished" -eq 0 ]; do
      local backup_grid=("${letter_grid[@]}")
      local random_coordinates=$(get_random_coordinates $x_size $y_size)
      local x=$(echo "$random_coordinates" | sed 's/,.*//')
      local y=$(echo "$random_coordinates" | sed 's/[^,]*,//')
      local direction=$(get_random_direction)
      for ((i = 0; i < ${#word}; i++)); do
        # Extract the character at the current position
        local character="${word:i:1}"
        local char_at_location=$(get_letter_at_coordinates $x $y $x_size $y_size)
        
        if [ "$character" == "$char_at_location" ] || [ "?" == "$char_at_location" ]; then
            
            place_character $x $y $x_size $y_size $character
            new_coordinates=$(get_adjacent_coordinates $x $y $direction $x_size $y_size)
            if [ "$new_coordinates=" == "-1,-1" ]; then
              letter_grid=("${backup_grid[@]}")
              break
            fi
            x=$(echo "$new_coordinates" | sed 's/,.*//')
            y=$(echo "$new_coordinates" | sed 's/[^,]*,//')
        else

            # The cell is taken with another letter.
            # Restore the grid and try again.
            letter_grid=("${backup_grid[@]}")
            break
        fi

       finished=1
    done  
  done
}


# Default values
param1=""
param2=""
param3=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      file_path="$2"
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
     --help)
      echo "Usage: ./word-search-generator --file ./example.txt --x 20 --y 30"
      echo "This produces a word search from the words in the word list, one word per line, of the size 20 by 30."
      exit 0
      ;;     
    *)
      echo "Invalid argument: $1"
      echo "Try --help"
      exit 1
      ;;
  esac
done


create_letter_grid $x_size $y_size


# Check if the file exists
if [ -e "$file_path" ]; then
  while IFS= read -r line; do
    put_word_in_grid $line $x_size $y_size
  done < "$file_path"
else
  echo "File not found: $file_path"
fi

replace_question_with_random_lowercase
convert_letter_grid_to_uppercase

print_grid $x_size $y_size



create_letter_grid $x_size $y_size

print_grid $x_size $y_size

