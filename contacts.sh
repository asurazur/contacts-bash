#!/bin/bash
# contacts.sh - CRUD implementation of Contacts with JSON as database
#
# Copyright (C) <March 4, 2023> <Kristian Davidson O> Azur>
#
# scriptname [option] [argument] ...

# Function to get the index of a person by id
function map_id_to_index() {
    local index=$(jq -r --arg id "$id" '.people | map(.id) | index($id | tonumber)' "db.json")
    if [[ "$index" == "null" ]]; then
        echo -1
    else
        echo $index
    fi
}

#Generate Unique ID
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

#Return the mapped attribute
function get_attribute() {
    if [[ $# != 1 ]]; then
        echo invalid number of arguments
        return
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
            return
        fi
    fi
}

#Create & Add Person to Database
function add_person() {
	echo "Add Contact"
    
    #Create Unique ID
    local id=$(create_unique_id)
    
    #Prompt for Credentials
    read -p "Please Enter Your Name: " -r name
    read -p "Hello $name, What's Your Gender Identity? " -r gender
    read -p "When's Your Birthday (YYYY-MM-DD)? " -r birthday
    read -p "Where are you from? " -r location
    read -p "What's your email? " -r email
    read -p "How about your phone number: " -r number
    read -p "Phewwww, Lastly, What's your Motto? " -r motto
	
    # Create a new person object
    new_person="{
      \"id\": $id,
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
    mv tmp.json db.json
    echo "New person added with ID: $id"
}

#Read Contact Function
function read_contact() {
  	echo "Read Contact"
	read -p "Option (0-All Contacts, 1-Single Contact): " -n 1 option; echo
    if [[ $option == 0 ]]; then
        echo | jq -r '.people[]' db.json;
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
        return
    fi
}

#Update Contact Function
function update_contact() {
    echo "Update"
    #Map ID to Index
    read -p "Enter ID to update: " id
    actual_index=$(map_id_to_index "$id")
    #Check if ID exists
    if [[ $actual_index == -1 ]]; then
        echo $id not found
        return
    else
        #UPDATE DATA
        echo $json | jq -r ".people[$actual_index]"
        echo "Updating Instruction: (1: Name, 2: Email, 3: Number, 4: Birthday, 5: Gender, 6: Location, 7: Motto"
        #Guard Clause
        read -p "Choose Which to Update: " -n 1 option; echo
        if (( option < 1 || option > 7 )); then
            echo "$option is invalid argument"
            return
        fi
        attribute=$(get_attribute "$option")
        read -p "Enter the New $attribute: " new_attribute
        old_attribute=$(echo $json | jq ".people[$actual_index].$attribute")
        #CONFIRMATION
        read -p "Are you sure to replace $old_attribute with $new_attribute (Y/y to confirm): " flag
        if [ "$flag" == "y" ] || [ "$flag" == "Y" ]; then
            echo $json | jq ".people[$actual_index].$attribute=\"$new_attribute\"" > tmp.json
            mv tmp.json db.json
            echo "$id.$attribute: $old_attribute -> $new_attribute"
        else
            echo "Update Abort"
            return
        fi
    fi

}

#Delete Contact Function
function delete_contact() {
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
            mv tmp.json db.json
            echo "ID: $id Deleted successfully"
        else
            echo "Deletion aborted"
        fi
    fi
}

#Main Function
json=$(cat db.json)
people_size=$(echo $json | jq -r '.people | length')
echo Contact Management Program
echo "Number of Contacts: $people_size"
read -p "1:Create, 2:Read, 3:Update, 4:Delete: " -n 1 action; clear
if [[ $action == 1 ]]; then
    add_person
elif [[ $action == 2 ]]; then
    read_contact   
elif [[ $action == 3 ]]; then
	update_contact
elif [[ $action == 4 ]]; then
	delete_contact
else
    "Invalid Input"
fi