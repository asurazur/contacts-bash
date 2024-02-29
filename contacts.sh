#!/bin/bash

json=$(cat db.json)
people_size=$(echo $json | jq -r '.people | length')
echo $json | jq -r '.people[]'
read -p "1:Create, 2:Read, 3:Update, 4:Delete: " -n 1 action; clear
echo $json | jq -r '.people[]';clear

if [[ $action == 1 ]]; then
    echo "Create"
    #CHECK LATEST ID
    #Prompt for Credentials
    #Write to JSON FILE
elif [[ $action == 2 ]]; then
    echo "Read"
    #PROMPT ID
    #MAP id with index
    #PRINT element with index -> id
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