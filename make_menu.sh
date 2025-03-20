#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

function menu() {
    local title="$1"
    shift
    local prompt="$1"
    shift
    local -a items=("$@")

    # ensure there are items provided
    if [ ${#@} -eq 0 ]; then
        echo "No items provided for the menu."
        return 1
    fi

    # initialize whiptail tag and item combinations (item is empty)
    local -a items=("$@")
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
    local menu_height=$((menu_height > max_menu_height ? max_menu_height : menu_height))
    
    #  determine width based on prompt and longest item text
    local item
    local item_width
    local largest_width=$((${#prompt} + 4))
    for item in "${items[@]}"; do
        item_width=$((${#item} + 5))
        largest_width=$((item_width > largest_width ? item_width : largest_width))
    done
    local width=$((largest_width > max_width ? max_width : largest_width))
    width=$((width < min_width ? min_width : width))

    # show menu
    local selection
    selection=$(whiptail --title "${title}" --menu "${prompt}" ${menu_height} ${width} ${items_height} "${whiptail_items[@]}" 3>&1 1>&2 2>&3)
    echo "${selection}"
}

# main
mapfile -t make_targets < <(grep "^\.PHONY:" makefile | awk -F': ' '{print $2}')
while true; do
    choice=$(menu "Make menu" "Choose a 'make' target:" "${make_targets[@]}")
    if [ -z "$choice" ]; then
        break
    fi
    clear
    make "$choice"
    echo
    read -p "Press Enter to continue..."
done

