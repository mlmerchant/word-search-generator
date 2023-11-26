#!/usr/bin/python3

from random import choice, randint
import copy
import argparse


def get_random_direction():
    return choice([(0,1), (1,0), (1,1), (-1,-1), (1,-1), (-1,1), (-1,0), (1,-1)])
    pass


def remove_non_alpha_and_whitespace(input_list):
    filtered_list = []
    for item in input_list:
        alpha_chars = ''
        for char in item:
            if char.isalpha():
                alpha_chars += char
        if alpha_chars:
            filtered_list.append(alpha_chars)
    return filtered_list


# Gather the arguments
parser = argparse.ArgumentParser(description='A simple CLI based word search generator.')
parser.add_argument('-x', type=int, help='An integer value for x board size.')
parser.add_argument('-y', type=int, help='An integer value for y board size.')
parser.add_argument('-f', type=str, help='Path to an input file with one word per line.')
parser.add_argument('--scramble', action='store_true', help='Word directions will be scrambled.')

args = parser.parse_args()
x_value = args.x
y_value = args.y
file_path = args.f

#Check for missing arguments
if x_value == None or y_value == None or file_path == None:
    print("Missing arguments.  Try running --help or -h")
    exit()

#Create the empty letter grid
global_grid = []
grid_row = []
for x in range(x_value):
    grid_row.append("?")
for y in range(y_value):
    global_grid.append(grid_row.copy())

#Load and validate the words
try:
     with open(file_path, 'r') as file:
         contents = file.read()
         words = contents.split("\n")
except:
    print("Bad file path.")
    exit()
words = remove_non_alpha_and_whitespace(words)
if not len(words):
    print("The input file didn't contain usable words.")
    exit()

# Place the Words
for word in words:
    placed = False
    while not placed:
        backup_grid = copy.deepcopy(global_grid)
        direction = get_random_direction()
        start_x = randint(0, x_value)
        start_y = randint(0, y_value)
        for i, letter in enumerate(word):
            letter = letter.upper()
            if args.scramble:
                direction = get_random_direction()
            try:
                preexisting_letter = global_grid[start_y][start_x]
            except IndexError:
                global_grid = copy.deepcopy(backup_grid)
                break
            if preexisting_letter == letter or preexisting_letter == "?":
                global_grid[start_y][start_x] = letter
                start_x += direction[0]
                start_y += direction[1]
                if start_x < 0 or start_y < 0:
                    global_grid = copy.deepcopy(backup_grid)
                    break
            else:
                global_grid = copy.deepcopy(backup_grid)
                break
            if i == len(word) - 1:
                placed = True

# Print the Board
uppercase_characters = [chr(i) for i in range(ord('A'), ord('Z') + 1)]
for x in range(x_value):
    for y in range(y_value):
        value = global_grid[y][x]
        if value == "?":
            value = choice(uppercase_characters)
        print(value, end="")
    print("")
