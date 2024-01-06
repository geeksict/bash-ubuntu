#!/bin/bash
# Set Hostname
read -p 'Input hostname: ' namehost
hostnamectl set-hostname $namehost && timedatectl set-timezone Asia/Ho_Chi_Minh

# Remove UFW defautl Ubuntu
systemctl stop ufw
systemctl disable ufw
apt-get remove ufw
# Install Iptables
apt-get install iptables iptables-persistent netfilter-persistent -y
iptables -F INPUT
# Set rules for firewall
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 587 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 995 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -m limit --limit 3/minute --limit-burst 70 -j ACCEPT
iptables -A INPUT -p udp --sport ntp -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
iptables -A INPUT -j REJECT
# Save & Show rules
netfilter-persistent save
iptables -L