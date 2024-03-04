#!/bin/bash
# contacts.sh - CRUD implementation of Contacts with JSON as database
#
# Copyright (C) <March 4, 2023> <Kristian Davidson O> Azur>
#
# scriptname [option] [argument] ...

# Function to get the index of a person by id
map_id_to_index() {
    local id="$1"
    local ids=($(jq -r '.people[].id' "db.json"))
    local index=0
    for i in "${ids[@]}"; do
        # ID found
        if [[ $i == $id ]]; then
            echo "$index"
            return
        fi
        index=$((index + 1))
    done
    # If the id is not found
    echo "-1"
    {
      "id": "3",
      "name": "test",
      "gender": "test",
      "birthday": "test",
      "location": "M",
      "email": "2002-09-09",
      "number": "Naga",
      "motto": "City,"
    },
    {
      "id": "4",
      "name": "KD",
      "gender": "test",
      "birthday": "s",
      "location": "d",
      "email": "d",
      "number": "d",
      "motto": "d"
    }
}

function create_unique_id() {
    local ids=($(jq -r '.people[].id' "db.json"))
    local largest=-1
    for i in "${ids[@]}"; do
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

function get_attribute() {
    if [[ $# != 1 ]]; then
        echo invalid number of arguments
    else
        if [[ $1 == 1 ]];then 
            echo name
        elif [[ $1 == 2 ]];then 
            echo email
        elif [[ $1 == 3 ]];then 
            echo number
        elif [[ $1 == 4 ]];then 
            echo birthday
        elif [[ $1 == 5 ]];then 
            echo gender
        elif [[ $1 == 6 ]];then 
            echo location
        elif [[ $1 == 7 ]];then 
            echo motto
        else
            echo invalid argument
        fi
    fi
}
#Main Function

#Initialization
json=$(cat db.json)
people_size=$(echo $json | jq -r '.people | length')
echo Contact Management Program
read -p "1:Create, 2:Read, 3:Update, 4:Delete: " -n 1 action; clear


#Create/Add Contact
if [[ $action == 1 ]]; then
    echo "Add Contact"
    #Create Unique ID
    id=$(create_unique_id)
    #Prompt for Credentials
    read -p "Please Enter Your Name: " -r  name
    read -p "Hello $name, What's Your Gender Identity? " -r gender
    read -p "When's Your Birthday (YYYY-MM-DD)? " -r birthday
    read -p "Where are you from? " -r location
    read -p "What's your email? " -r email
    read -p "How about your phone number: " -r number
    read -p "Phewwww, Lastly, What's your Motto? " -r motto
    echo Thank You For Your Cooperation
    #Write to JSON FILE
    add_person_to_json $id $name $gender $birthday $location $email $number $motto

#Read Contact
elif [[ $action == 2 ]]; then
    echo "Read Contact"
    read -p "Option (0-All Contacts, 1-Single Contact): " -n 1 option; echo
    if [[ $option == 0 ]]; then
        echo $json | jq -r '.people[]';
    elif [[ $option == 1 ]]; then
        read -p "Enter ID to read: " id;
        #Map ID to Index
        actual_index=$(map_id_to_index "$id")
        #Check if ID exists
        if [[ $actual_index == "-1" ]]; then
            echo "$id not found"
        else 
            echo $json | jq -r ".people[$actual_index]"
        fi
    else 
        echo "Invalid Argument"
    fi

#Update Contact    
elif [[ $action == 3 ]]; then
    echo "Update"
    #Map ID to Index
    read -p "Enter ID to update: " id
    actual_index=$(map_id_to_index "$id")
    #Check if ID exists
    if [[ $actual_index == -1 ]]; then
        echo $id not found
    else
        #UPDATE DATA
        echo $json | jq -r ".people[$actual_index]"
        echo "Updating Instruction: (1: Name, 2: Email, 3: Number, 4: Birthday, 5: Gender, 6: Location, 7: Motto"
        read -p "Choose Which to Update: " -n 1 option; echo
        attribute=$(get_attribute "$option")
        read -p "Enter the New $attribute: " new_attribute
        old_attribute=$(echo $json | jq ".people[$actual_index].$attribute")
        #CONFIRMATION
        read -p "Are you sure to replace $old_attribute with $new_attribute (Y/y to confirm)" flag
        if [ "$flag" == "y" ] || [ "$flag" == "Y" ]; then
            echo $json | jq ".people[$actual_index].$attribute=\"$new_attribute\"" > tmp.json
            mv tmp.json db.json
            echo "$id.$attribute: $old_attribute -> $new_attribute"
        else
            echo "Update Abort"
        fi
    fi

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
        read -p "Are you sure to delete this (Y/y to confirm): " flag 
        if [ "$flag" == "y" ] || [ "$flag" == "Y" ]; then
            echo $json | jq ".people |= map(select(.id != $id))" > tmp.json 
            # mv tmp.json db.json
            echo "ID: $id Deleted successfully"
        else
            echo "Deletion aborted"
        fi
    fi
else
    "Invalid Input"
fi