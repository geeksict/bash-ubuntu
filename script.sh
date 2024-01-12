#!/bin/bash
# Remove pass for user default
passwd -d ubuntu
# Update ubuntu
apt-get update -y && apt update -y && apt upgrade -y
apt install --only-upgrade `apt list --upgradeable 5>/dev/null | cut -d/ -f1 | grep -v Listing`

sudo -i
hostnamectl set-hostname mail.emaxnt.edu.vn && timedatectl set-timezone Asia/Ho_Chi_Minh
echo `curl -4 ifconfig.me` `hostname -f` localhost >> /etc/hosts
apt install nano certbot iptables iptables-persistent -y

iptables -I INPUT 4 -p tcp -m tcp --dport 80 -j ACCEPT
iptables -I INPUT 5 -p tcp -m tcp --dport 443 -j ACCEPT
iptables -I INPUT 6 -p tcp -m tcp --dport 25 -j ACCEPT
iptables -I INPUT 7 -p tcp -m tcp --dport 587 -j ACCEPT
iptables -I INPUT 8 -p tcp -m tcp --dport 143 -j ACCEPT
iptables -I INPUT 9 -p tcp -m tcp --dport 995 -j ACCEPT
iptables -I INPUT 10 -p tcp --dport 80 -m limit --limit 3/minute --limit-burst 70 -j ACCEPT
ip6tables -I INPUT 1 -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -I INPUT 2 -p icmp -j ACCEPT
ip6tables -I INPUT 3 -j ACCEPT
ip6tables -I INPUT 4 -p tcp -m tcp --dport 80 -j ACCEPT
ip6tables -I INPUT 5 -p tcp -m tcp --dport 443 -j ACCEPT
ip6tables -I INPUT 6 -p tcp -m tcp --dport 25 -j ACCEPT
ip6tables -I INPUT 7 -p tcp -m tcp --dport 587 -j ACCEPT
ip6tables -I INPUT 8 -p tcp -m tcp --dport 143 -j ACCEPT
ip6tables -I INPUT 9 -p tcp -m tcp --dport 995 -j ACCEPT
ip6tables -I INPUT 10 -p tcp --dport 80 -m limit --limit 3/minute --limit-burst 70 -j ACCEPT
ip6tables -A INPUT -p udp --sport ntp -j ACCEPT
ip6tables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
ip6tables -A INPUT -j REJECT
service iptables save && service iptables restart || netfilter-persistent save
reboot

sudo -i
wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.6.8.tar.gz
tar zxvf 1.6.8.tar.gz && cd iRedMail* && bash iRedMail.sh


Certificate is saved at: /etc/letsencrypt/live/webmail.emaxnt.edu.vn/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/webmail.emaxnt.edu.vn/privkey.pem
	
certbot certonly --webroot --dry-run --agree-tos -m phucpt2802@gmail.com -w /var/www/html -d `hostname -f`
	
chmod 0644 /etc/letsencrypt/{live,archive}
mv /etc/ssl/certs/iRedMail.crt{,.bak}   
mv /etc/ssl/private/iRedMail.key{,.bak}
ln -s /etc/letsencrypt/live/`hostname -f`/fullchain.pem /etc/ssl/certs/iRedMail.crt
ln -s /etc/letsencrypt/live/`hostname -f`/privkey.pem /etc/ssl/private/iRedMail.key

systemctl restart dovecot
systemctl restart postfix
systemctl restart nginx
	
crontab -e
	
1   3   *   *   *   certbot renew --post-hook '/usr/sbin/service postfix restart; /usr/sbin/service nginx restart; /usr/sbin/service dovecot restart'
reboot

#fix SSL header

sed -i 's/smtpd_tls_security_level = may/smtpd_tls_security_level = encrypt/' /etc/postfix/main.cf
echo -e '\n#\n# fix SSL header\n#\nsmtp_tls_cert_file = /etc/ssl/certs/iRedMail.crt\nsmtp_tls_key_file = /etc/ssl/private/iRedMail.key' >> /etc/postfix/main.cf
systemctl restart postfix

#SMTP Relay

echo -e '\n#\n# Relay SMTP O365\n#\relayhost = [emaxnt-edu-vn.mail.protection.outlook.cov m]:25\nsmtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd' >> /etc/postfix/main.cf
echo -e '\nsmtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd\nsmtp_sasl_auth_enable = yes\nsmtp_sasl_mechanism_filter = login' >> /etc/postfix/main.cf
echo -e '\nsmtp_sasl_security_options = noanonymous\nmailbox_size_limit = 26214400' >> /etc/postfix/main.cf
touch /etc/postfix/sasl_passwd && echo '[emaxnt-edu-vn.mail.protection.outlook.com]:25 smtp@geeksict.com:BucMinh@!123' >> /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd
systemctl restart postfix


#get dkim
amavisd-new showkeys

-> dkim._domainkey.mydomain.com.   3600 TXT (
  "v=DKIM1; p="
  "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYArsr2BKbdhv9efugByf7LhaK"
  "txFUt0ec5+1dWmcDv0WH0qZLFK711sibNN5LutvnaiuH+w3Kr8Ylbw8gq2j0UBok"
  "FcMycUvOBd7nsYn/TUrOua3Nns+qKSJBy88IWSh2zHaGbjRYujyWSTjlPELJ0H+5"
  "EV711qseo/omquskkwIDAQAB")
  
  Copy output of command above into one line like below, remove all quotes, but keep ;. we just need strings inside the () block, it's the value of DKIM DNS record.
v=DKIM1; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYArsr2BKbdhv9efugBy...

Record TXT Name: dkim._domainke
Content: v=DKIM1; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6zO/2ZRsCFZ192ZzoDU6QEqBpD9p98toe+1AUKH1sR3ULgEgZGt2oPIckv5cDzdFtBNeTCGDbqe8OO/mGiDVtkP7Nh.............


v=DKIM1; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxIVWxjbBaUvMnPhIsCDUmgq+4rR98cOUU0b4B5g/Gxcwg1ADzEWGgxHxmUgoRnx+85BFTii75HkniSyoQOWMiqXpZRHBgIp5+OUkv/avGYmp7QaW7ns/Q388QLuDjO5igNroXUSfCm6AVNTTQWOICHpju2iq76s14mg9+p83Qq71yTznqFYVwUl2zQmPx2BBLFe+1LQBRVAld9lYEV2S/vvDSWd2147a05OBo0xflKozRQ5+UARX2FUsBMSpezo7l+lhwW8lAdfONskkhajHgAU6GxGJFtwZFRNKg5FZh3ca4Gtf6YYnXzY4eAAkJlqrszUJ5aB1oankiinCVELftwIDAQAB


#fix POP3-IMAP - /etc/dovecot/dovecot.conf




# Setup auto discovery (outlook)
Setup DNS record for autodiscover
Please create a DNS SRV record for your customer's domain name customer.com:
Name: @
Service: _autodiscover
Protocol: _tcp
Port Number: 443
Priority: 1
Weight: 1
Host: webmail.emaxnt.edu.vn
Outlook will query DNS SRV record _autodiscover._tcp.emaxnt.edu.vn first, then fetch pre-defined server settings from URL https://webmail.emaxnt.edu.vn/autodiscover/autodiscover.xml.

After created, you may need to wait for 2 or more hours until your DNS vendor flush the DNS cache. Then try to query it with dig command like below:

# dig +short -t srv _autodiscover._tcp.emaxnt.edu.vn
1 1 443 mail.host.com.


