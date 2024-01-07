#!/bin/bash
# Set Hostname
read -p 'Input username defautl: ' unamedf
passwd -d $unamedf
# Update ubuntu
apt-get update -y
apt update -y
apt upgrade -y
apt update
