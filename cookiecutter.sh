#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#########################################################################################
# Name: cookiecutter.sh                                                                 #
# Author: Ben Hattem (benghattem@gmail.com)                                             #
#                                                                                       #
# Versions:                                                                             #
#  1.0    2025-03-25  BHA  initial version                                              #
#  1.0.1  2025-03-25  BHA  minor refactoring                                            #
#                                                                                       #
# Purpose: use cookiecutter to create a project from a template                         #
#                                                                                       #
#########################################################################################
VERSION="1.0.1"
TEMPLATE_DIR="${HOME}/python_templates"
COOKIECUTTER="${HOME}/python-base/.venv/bin/cookiecutter"

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
    selection=$(whiptail --title "${title}" --menu "${prompt}" ${menu_height} ${width} ${items_height} "${whiptail_items[@]}" 3>&1 1>&2 2>&3)

    echo "${selection}"
}

function gather_templates() {
    local basedir="$1"
    local repo_name
    for dir in "${basedir}"/*/; do
        if [ -f "${dir}cookiecutter.json" ]; then
            repo_name=$(grep -oP '"repo_name":\s*"\K[^"]+' "${dir}cookiecutter.json")
            TEMPLATES["$repo_name"]="${dir%/}"
        fi
    done
}

#
# MAIN
#

# gather templates
declare -A TEMPLATES
gather_templates "${TEMPLATE_DIR}" # result is in TEMPLATES
repo_names=() && repo_names=("${!TEMPLATES[@]}")
if [ ${#repo_names[@]} -eq 0 ]; then
    echo "ERROR: no templates found in: '${TEMPLATE_DIR}'"
    exit 1
fi

# run menu
while true; do
    choice=$(menu "Cookiecutter (V${VERSION})" "Choose a template:" "${repo_names[@]}")
    if [ -z "$choice" ]; then
        clear
        break
    fi

    clear
    echo "Creating project for template: ${choice}"
    set +e
    "${COOKIECUTTER}" "${TEMPLATES[$choice]}"
    set -e

    echo
    read -r -p "Press Enter to continue..."
done
