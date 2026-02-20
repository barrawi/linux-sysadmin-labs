#!/bin/bash

# user_creation.sh
# Advanced Linux user creation tool
# by Wilberth Barrantes
# for CentOS / RHEL

logfile="/var/log/user_administration.log"

# Makes sure script is running with root privileges
check_root(){
	if [[ $EUID -ne 0 ]]; then
		echo "Error: Script must be run as root. Try: sudo $0"
		exit 1
	fi
}

# Saves each action to a logfile
log_action(){
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$logfile"
}

# Usage syntax
correct_usage(){
	echo "How to Use:"
	echo "$0 -u username [-g group] [-s shell] [-e expiration_date] [--sudo]"
	echo "$0 -f file_with_usernames" # For user bulk creation from txt file
	exit 1
}

# User name validation
validate_username(){
	[[ "$1" =~ ^[a-z_][a-z0-9_-]*$ ]]
}

# Shell existence validation
validate_shell(){
if [[ -x "$1" ]]; then
        return 0
    else
        echo "Error: Invalid Shell $1"
        return 1
    fi
}

# Setting up user creation and options
user_creation(){
	local username=$1
	local groupname=$2
	local shell=${3:-/bin/bash} # If no shell provided use default 
	local expdate=$4
	local sudo_access=$5
	
	if ! validate_username "$username"; then
		echo "Error: Invalid username format $username"
		return 1
	fi

	if id "$username" &>/dev/null; then
		return 1
	fi

	if ! validate_shell "$shell"; then
		return 1
	fi

	useradd -m -s "$shell" "$username" || return 1 # Succeed OR exit
	while true; do
		read -s -p "Enter a password for $username: " password
		echo ""
		read -s -p "Confirm the password: " password_conf # making sure the password matches
		if [ "$password" == "$password_conf" ] ; then
			echo "$username:$password" | chpasswd
			echo ""
			break
		else
			echo ""
			echo "Error: Password doesn't match..."
		fi
	done

	chage -d 0 "$username" # Force password change on next login
	
	if [ -n "$groupname" ]; then
		groupadd -f "$groupname"
		usermod -aG "$groupname" "$username"
	fi
	
	if [ "$sudo_access" = true ]; then
        	usermod -aG wheel "$username" # wheel group grants sudo access
        fi	

	if [ -n "$expdate" ]; then
		chage -E "$expdate" "$username" # set exp date YYYY-MM-DD
	fi

	log_action "User $username created."
	echo "User $username created."
}

check_root

sudo_con=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -u) username="$2"; shift 2 ;;
        -g) groupname="$2"; shift 2 ;;
        -s) shell="$2"; shift 2 ;;
        -e) expdate="$2"; shift 2 ;;
        --sudo) sudo_con=true; shift ;;
        -f) file="$2"; shift 2 ;;
        *) correct_usage ;;
    esac
done

if [ -n "$file" ]; then
	if [ ! -f "$file" ]; then
		echo "Error: File not found $file"
		exit 1
	fi
	while read -u 3 -r user; do # -u and 3 should separate from stdin
	    user_clean=$(echo "$user" | xargs) # Trims whitespaces on the txt
	if [[ -n "$user_clean" ]]; then
	    user_creation "$user_clean" "$groupname" "$shell" "$expdate" "$sudo_con"
	fi
    done 3< "$file"
elif [ -n "$username" ]; then
    user_creation "$username" "$groupname" "$shell" "$expdate" "$sudo_con"
else
    correct_usage
fi
