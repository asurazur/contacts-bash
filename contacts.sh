#!/bin/bash
# contacts.sh - CRUD implementation of Contacts with CSV as database
#
# Copyright (C) <March 4, 2023> <Kristian Davidson O> Azur>
#
# scriptname [option] [argument] ...

# File name for the database
DB_FILE="contacts.csv"

# Function to add header to CSV file
function add_header() {
    echo "ID,Name,Email" > "$DB_FILE"
}

# Generate Unique ID
function create_unique_id() {
    if [[ ! -f "$DB_FILE" ]]; then
        add_header
        echo "1"
    else
        local largest=$(tail -1 "$DB_FILE" | cut -d, -f1)
        echo $((largest + 1))
    fi
}

# Create & Add Person to Database
function add_person() {
    echo "Add Contact"
    
    # Create Unique ID
    local id=$(create_unique_id)
    
    # Prompt for Credentials
    read -p "Please Enter Your Name: " -r name
    read -p "Hello $name, What's Your Email? " -r email
    
    # Create a new person entry
    new_person="$id,$name,$email"
    
    # Add the new person to the database
    echo "$new_person" >> "$DB_FILE"
    echo "New person added with ID: $id"
}

# Read Contact Function
function read_contact() {
    echo "Read Contact"
    read -p "Option (0-All Contacts, 1-Single Contact): " -n 1 option; echo
    if [[ $option == 0 ]]; then
        cat "$DB_FILE"
    elif [[ $option == 1 ]]; then
        read -p "Enter ID to read: " id;
        if ! grep -q "^$id," "$DB_FILE"; then
            echo "ID: $id not found"
            return
        fi
        echo "ID,Name,Email"
        sed -n "/^$id,/p" "$DB_FILE"
    else 
        echo "Invalid Argument"
        return
    fi
}

# Update Contact Function
function update_contact() {
    echo "Update Contact"
    read -p "Enter ID to update: " id
    if ! grep -q "^$id," "$DB_FILE"; then
        echo "ID: $id not found"
        return
    fi
    
    # Get the current data for the given ID
    current_data=$(sed -n "/^$id,/p" "$DB_FILE")
    if [[ -z "$current_data" ]]; then
        echo "ID: $id not found"
        return
    fi

    echo "ID,Name,Email"
    echo "$current_data"
    read -p "Update Name? (Y/N): " update_name
    read -p "Update Email? (Y/N): " update_email

    # Prompt for new values based on user input
    new_name=""
    new_email=""

    if [[ $update_name == "Y" || $update_name == "y" ]]; then
        read -p "Enter new name: " new_name
    else
        new_name=$(echo "$current_data" | cut -d',' -f2)
    fi

    if [[ $update_email == "Y" || $update_email == "y" ]]; then
        read -p "Enter new email: " new_email
    else
        new_email=$(echo "$current_data" | cut -d',' -f3)
    fi

    # Update the specific line with new name and email
    sed -i "/^$id,/s/^[^,]*,[^,]*,.*/$id,$new_name,$new_email/" "$DB_FILE"
    echo "ID: $id Updated successfully"
}

# Delete Contact Function
function delete_contact() {
    echo "Delete Contact"
    read -p "Enter ID to delete: " id
    if ! grep -q "^$id," "$DB_FILE"; then
        echo "ID: $id not found"
        return
    fi

    # Remove the line with the given ID
    echo "ID,Name,Email"
    echo "$(sed -n "/^$id,/p" "$DB_FILE")"
    read -p "Are you sure to delete this? (Y/N): " flag
    if [[ $flag == "Y" || $flag == "y" ]]; then
        sed -i "/^$id,/d" "$DB_FILE"
        echo "ID: $id Deleted successfully"
    else
        echo "Delete Aborted"
    fi

}

# Main Function
if [[ ! -f "$DB_FILE" ]]; then
    add_header
fi

echo Contact Management Program
people_size=$(($(wc -l < "$DB_FILE")-1))
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
    echo "Invalid Input"
fi
