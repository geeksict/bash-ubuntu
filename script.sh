#!/bin/bash
# Remove pass for user default
read -p 'Remove passwd User default (Y/n): ' choicermpasswd
choice=${choice:-yes}
if [$choicermpasswd=='Y'] || [$choicermpasswd=='y'] || [$choicermpasswd=='yes']; then
  read -p 'Input username default: ' unamedf
  passwd -d $unamedf
else
fi
# Update ubuntu
apt-get update -y && apt update -y && apt upgrade -y
apt install --only-upgrade `apt list --upgradeable 5>/dev/null | cut -d/ -f1 | grep -v Listing`
