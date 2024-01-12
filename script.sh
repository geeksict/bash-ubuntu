#!/bin/bash
# Remove pass for user default
passwd -d ubuntu
# Update ubuntu
apt-get update -y && apt update -y && apt upgrade -y
apt install --only-upgrade `apt list --upgradeable 5>/dev/null | cut -d/ -f1 | grep -v Listing`
