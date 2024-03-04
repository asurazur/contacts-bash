#!/bin/bash
# contacts.sh - CRUD implementation of Contacts with JSON as database
#
# Copyright (C) <March 4, 2023> <Kristian Davidson O> Azur>
#
# scriptname [option] [argument] ...

# Function to get the index of a person by id
function map_id_to_index() {
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
        echo $index
    else
        echo -1
    fi
}

function create_unique_id() {
    ids=$(jq '.people[].id' db.json)
    local largest=-1
    for i in $ids; do
        if [[ $largest -lt $i ]]; then
            largest=$i
        fi
    done
    echo $((largest + 1))
}

function add_person_to_json() {
    local id=$1
    local name=$2
    local gender=$3
    local birthday=$4
    local location=$5
    local email=$6
    local number=$7
    local motto=$8

    # Create a new person object
    new_person="{
      \"id\": \"$id\",
      \"name\": \"$name\",
      \"gender\": \"$gender\",
      \"birthday\": \"$birthday\",
      \"location\": \"$location\",
      \"email\": \"$email\",
      \"number\": \"$number\",
      \"motto\": \"$motto\"
    }"
    # Add the new person to the "people" array in the JSON file
    echo | jq --argjson new_person "$new_person" '.people += [$new_person]' db.json > tmp.json

    # Replace the original file with the updated JSON
    mv tmp.json db.json
    echo "New person added with ID: $id"
}

#Main Function

#Initialization
json=$(cat db.json)
people_size=$(echo $json | jq -r '.people | length')
echo $json | jq -r '.people[]'
read -p "1:Create, 2:Read, 3:Update, 4:Delete: " -n 1 action; clear
echo $json | jq -r '.people[]';clear

#Create/Add Contact
if [[ $action == 1 ]]; then
    echo "Create"
    #Create Unique ID
    id=$(create_unique_id)
    #Prompt for Credentials
    read -p "Please Enter Your Name: " name
    read -p "Hello $name, What's Your Gender Identity? " gender
    read -p "When's Your Birthday (YYYY-MM-DD)? " birthday
    read -p "Where are you from? " location
    read -p "What's your email? " email
    read -p "How about your phone number: " number
    read -p "Phewwww, Lastly, What's your Motto? " motto
    echo Thank You For Your Cooperation
    #Write to JSON FILE
    add_person_to_json $id $name $gender $birthday $location $email $number $motto

#Read Contact
elif [[ $action == 2 ]]; then
    echo "Read"
    read -p "Enter ID to read: " id
    #Map ID to Index
    actual_index=$(map_id_to_index "$id")]
    #Check if ID exists
    if [[ $actual_index == "-1" ]]; then
        echo "$id not found"
    else 
        echo $json | jq -r ".people[$actual_index]"
    fi

#Update Contact    
elif [[ $action == 3 ]]; then
    echo "Update"
    #PROMPT ID
    #UPDATE DATA
    #CONFIRMATION

#Delete Contact
elif [[ $action == 4 ]]; then
    echo "Delete"
    read -p "Enter ID to delete: " id
    #Map ID to Index
    actual_index=$(map_id_to_index "$id")
    #Check if ID exists
    if [[ $actual_index == "-1" ]]; then
        echo "$id not found"
    else 
        #Delete Confirmation
        echo $json | jq -r ".people[$actual_index]"
        read -p "Are you sure to delete this (Y:Yes/ N:No): " flag 
        if [ "$flag" == "y" ] || [ "$flag" == "Y" ]; then
            echo $(jq ".people |= map(select(.id != $id))" db.json) > tmp.json 
            mv tmp.json db.json
            echo "ID: $id Deleted successfully"
        else
            echo "Deletion aborted"
        fi
    fi
else
    "Invalid Input"
fi