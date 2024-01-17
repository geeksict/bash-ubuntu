#!/bin/bash

# Disable IPv6 Ubuntu
#touch /etc/sysctl.d/60-custom.conf
#echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.d/60-custom.conf
#echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.d/60-custom.conf
#echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.d/60-custom.conf
#sysctl -p && systemctl restart procps

# Remove pass for user default
passwd -d ubuntu
# Update ubuntu
apt-get update -y && apt update -y && apt upgrade -y
apt install --only-upgrade `apt list --upgradeable 5>/dev/null | cut -d/ -f1 | grep -v Listing`

# Update hostname & timezone
read -p 'Input hostname: ' hostname1
hostnamectl set-hostname $hostname1 && timedatectl set-timezone Asia/Ho_Chi_Minh

# Set ip public for files hosts
echo `curl -4 ifconfig.me` `hostname -f` localhost >> /etc/hosts
echo `curl -6 ifconfig.me` `hostname -f` localhost >> /etc/hosts

apt install nano certbot iptables iptables-persistent -y

# Set rules v4 for firewall
iptables -F INPUT
iptables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8/0 -j ACCEPT
iptables -A INPUT -p udp --sport ntp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 25 -j ACCEPT
iptables -A INPUT -p tcp --dport 587 -j ACCEPT
iptables -A INPUT -p tcp --dport 143 -j ACCEPT
iptables -A INPUT -p tcp --dport 995 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -m limit --limit 3/minute --limit-burst 70 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m limit --limit 3/minute --limit-burst 70 -j ACCEPT
iptables -A INPUT -j REJECT

# Set rules v4 for firewall
ip6tables -F INPUT
ip6tables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
ip6tables -A INPUT -p icmpv6 -j ACCEPT
ip6tables -A INPUT -p udp --sport ntp -j ACCEPT
ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 443 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 25 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 587 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 143 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 995 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 80 -m limit --limit 3/minute --limit-burst 70 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 443 -m limit --limit 3/minute --limit-burst 70 -j ACCEPT
ip6tables -A INPUT -j REJECT
# Save
netfilter-persistent save


# Download & Install iRedMail Server v1.6.8
wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.6.8.tar.gz
tar zxvf 1.6.8.tar.gz && cd iRedMail* && bash iRedMail.sh
cd ..
rm -rf *.tar.gz
rm -rf iRedMail*

# Reboot after install finished
reboot
