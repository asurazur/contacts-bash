#!/bin/bash
# contacts.sh - CRUD implementation of Contacts with JSON as database
#
# Copyright (C) <March 4, 2023> <Kristian Davidson O> Azur>
#
# scriptname [option] [argument] ...

json=$(cat db.json)
people_size=$(echo $json | jq -r '.people | length')
echo $json | jq -r '.people[]'
read -p "1:Create, 2:Read, 3:Update, 4:Delete: " -n 1 action; clear
echo $json | jq -r '.people[]';clear

# Function to get the index of a person by id
function map() {
    local id=$1
    local index=0
    local found=false

    # Read the JSON file and extract the ids
    ids=$(jq '.people[].id' db.json)

    # Iterate over the extracted ids
    for current_id in $ids; do
        # Check if the current id matches the input id
        if [ "$current_id" -eq "$id" ]; then
            # Set found to true and break the loop
            found=true
            break
        fi
        # Increment the index counter
        ((index++))
    done

    # If the id is found, return its index, otherwise return -1
    if [ "$found" = true ]; then
        return "$index"
    else
        return -1
    fi
}

if [[ $action == 1 ]]; then
    echo "Create"
    #CHECK LATEST ID
    #Prompt for Credentials
    #Write to JSON FILE
elif [[ $action == 2 ]]; then
    echo "Read"
    read -p "Enter ID to read: " id
    map "$id"
    echo $json | jq -r ".people[$?]"
elif [[ $action == 3 ]]; then
    echo "Update"
    #PROMPT ID
    #UPDATE DATA
    #CONFIRMATION
elif [[ $action == 4 ]]; then
    echo "Delete"
    #PROMPT ID
    #DELETE the element
    #Write to JSON FILE
    #CONFIRMATION
else
    "Invalid Input"
fi