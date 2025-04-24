#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#########################################################################################
# Name: make_menu.sh                                                                    #
# Author: Ben Hattem (benghattem@gmail.com)                                             #
#                                                                                       #
# Versions:                                                                             #
#  1.0    2025-03-20  BHA  initial version                                              #
#  1.0.1  2025-03-25  BHA  use width of title in menu width as well                     #
#  1.0.2  2025-03-25  BHA  minor refactoring                                            #
#  1.0.3  2025-04-23  BHA  adapt colors                                                 #
#  1.0.4  2025-04-24  BHA  be explicit: add '--noitem' option to whiptail call          #
#                                                                                       #
# Purpose: menu for a makefile (every .PHONY target becomes an entry)                   #
#                                                                                       #
#########################################################################################
VERSION="1.0.4"

#
# FUNCTIONS
#

# create a whiptail menu with an acceptable size for a list opf entries
function menu() {
    local title="$1"
    shift
    local prompt="$1"
    shift
    local -a items=("$@")

    # ensure there are items provided
    if [ ${#items[@]} -eq 0 ]; then
        echo "ERROR: no items provided for the menu."
        return 1
    fi

    # initialize whiptail tag and item combinations (item is empty)
    local -a whiptail_items=()
    for item in "${items[@]}"; do
        whiptail_items+=("$item")
        whiptail_items+=("")
    done

    # maximum height and width constraints
    local max_menu_height=24
    local max_items_height=16
    local min_width=21
    local max_width=80

    # calculate heights
    local num_items=${#items[@]}
    local items_height=$((num_items > max_items_height ? max_items_height : num_items))
    local menu_height=$((items_height + max_menu_height - max_items_height))
    menu_height=$((menu_height > max_menu_height ? max_menu_height : menu_height))

    #  determine width based on prompt and longest item text
    local largest_width=$((${#prompt} + 4))
    local title_width=$((${#title} + 6))
    largest_width=$((title_width > largest_width ? title_width : largest_width))
    for item in "${items[@]}"; do
        local item_width=$((${#item} + 5))
        largest_width=$((item_width > largest_width ? item_width : largest_width))
    done
    local width=$((largest_width > max_width ? max_width : largest_width))
    width=$((width < min_width ? min_width : width))

    # show menu
    local selection
    selection=$(whiptail --noitem --title "${title}" --menu "${prompt}" ${menu_height} ${width} ${items_height} "${whiptail_items[@]}" 3>&1 1>&2 2>&3)

    echo "${selection}"
}

#
# MAIN
#

# colors for whiptail (e.g. override '/etc/newt/palette')
export NEWT_COLORS='
    root=,blue
    checkbox=,blue
    entry=,blue
    label=blue,
    actlistbox=,blue
    helpline=,blue
    roottext=,blue
    emptyscale=blue
    disabledentry=blue,
'

# get makefile targets (all .PHONY entries)
mapfile -t make_targets < <(grep "^\.PHONY:" makefile | awk -F': ' '{print $2}')
if [ ${#make_targets[@]} -eq 0 ]; then
    echo "ERROR: no make targets found"
    exit 1
fi

# run menu
while true; do
    choice=$(menu "Make menu (V${VERSION})" "Choose a 'make' target:" "${make_targets[@]}")
    if [ -z "$choice" ]; then
        clear
        break
    fi

    clear
    set +e
    make "$choice"
    set -e

    echo
    read -r -p "Press Enter to continue..."
done
