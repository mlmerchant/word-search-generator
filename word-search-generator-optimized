#!/bin/bash

# Generate a word search grid
create_grid() {
  for ((i=0; i<$1*$2; i++)); do grid[$i]="?"; done
}

# Place a character in the grid
place_char() {
  local idx=$(($1 + $2 * x_size))
  [ $idx -lt $(($x_size * $y_size)) ] && grid[$idx]=$3 || echo "Invalid position"
}

# Main function to insert words into the grid
insert_words() {
  while IFS= read -r word; do
    for ((attempt=0; attempt<100; attempt++)); do
      local x=$((RANDOM % x_size))
      local y=$((RANDOM % y_size))
      local dir_x=$((RANDOM % 3 - 1))
      local dir_y=$((RANDOM % 3 - 1))
      local fit=1

      for ((i=0; i<${#word}; i++)); do
        local new_x=$((x + i * dir_x))
        local new_y=$((y + i * dir_y))
        local idx=$((new_x + new_y * x_size))

        if [[ $new_x -lt 0 || $new_x -ge $x_size || $new_y -lt 0 || $new_y -ge $y_size ]] || { [ "${grid[$idx]}" != "?" ] && [ "${grid[$idx]}" != "${word:i:1}" ]; }; then
          fit=0
          break
        fi
      done

      if ((fit)); then
        for ((i=0; i<${#word}; i++)); do
          place_char $((x + i * dir_x)) $((y + i * dir_y)) "${word:i:1}"
        done
        break
      fi
    done
  done < "$1"
}

# Print the grid
print_grid() {
  for ((y=0; y<$y_size; y++)); do
    for ((x=0; x<$x_size; x++)); do
      idx=$((x + y * x_size))
      char=${grid[$idx]}
      if [ $char = '?' ]; then
              letters=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
              char=${letters[$RANDOM % 26]}
      fi
      char=${char^}
      printf '%s ' $char
    done
    echo
  done
}

# Script starts here
x_size=$1
y_size=$2
file_path=$3

create_grid $x_size $y_size
insert_words "$file_path"
print_grid

