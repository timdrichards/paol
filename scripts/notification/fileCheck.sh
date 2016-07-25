#!/bin/bash

# Used to check if the machine is working and if it's not, send an email. - File Checker.

# Set the first argument as the code directory to check file
Dir=$1

# The fields to read from the check configuration file
rmt_runcheck=

# The location of the check configuration file
config=$Dir/paol-code/uploadConfig.txt

# Read each line in the config file, assuming they are of format "blah: blah", and set the fields
while read a b; do
	if [ "$a" = "rmt_runcheck:" ]; then
		rmt_runcheck=$b
	fi
done < $config

echo "File check folder: $rmt_runcheck"

# Exit if one of the parameters is not specified
if  [ -z "$rmt_runcheck" ]; then
	echo "Runnning/File check configuration file has the wrong format"
	exit 1
fi

# Set date and which not running machine is sending the email.
machine=
now="$(date +'%T-%m-%d-%Y')"

# Check file
for directory in $rmt_runcheck/*
do
    machine=$(basename $directory)
    for f2 in $directory/*
    do
	if [[ $f2 == *.txt ]]; then
	    echo "Checkpoint exists. Removing old Checkpoint."
	    rm -f $f2
	else
	    echo "Checkpoint missing. Sending email."
	    echo -e "Subject: "$machine" isn't running\r\n\r\nThis machine must be off\nDate:"$now"" | msmtp --from=default -t paolmailalert@gmail.com  
	fi
    done
done
