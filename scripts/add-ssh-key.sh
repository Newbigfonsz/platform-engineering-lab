#!/bin/bash
IP=$1
sshpass -p "***REMOVED***" ssh -o StrictHostKeyChecking=no platformadmin@$IP "
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat >> ~/.ssh/authorized_keys << 'SSHKEY'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDqc6qu7uFeW3mWpF4r+ePOrn6FFO3rGDySJKdMR3oeQ ***REMOVED***
SSHKEY
chmod 600 ~/.ssh/authorized_keys
"
echo "SSH key added to $IP"
