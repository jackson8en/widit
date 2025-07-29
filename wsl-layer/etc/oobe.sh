#!/bin/bash

set -ue

DEFAULT_GROUPS='adm,cdrom,sudo,dip,plugdev'
DEFAULT_UID='1000'

echo 'Welcome to WIDIT - WSL is Docker is Tarballs!'

# Create a new user
if getent passwd "$DEFAULT_UID" > /dev/null ; then
    echo 'User with UID '"$DEFAULT_UID"' already exists. Skipping user creation.'
    exit 0
fi

while true; do
    # Prompt for username
    read -p "Enter username for the new UNIX user: " username
    
    # Create
    if /usr/sbin/useradd --uid "$DEFAULT_UID" --quiet --gecos '' "$username"; then
        if /usr/sbin/usermod "$username" -aG "$DEFAULT_GROUPS"; then
            echo "User '$username' created with UID $DEFAULT_UID and added to groups: $DEFAULT_GROUPS"
            break
        else
            /usr/sbin/userdel "$username"
        fi
    fi
done