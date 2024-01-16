# Create SSL Let's Encrypt
certbot certonly --webroot --agree-tos -w /var/www/html -d `hostname -f`

# Fix SSL Let's Encrypt for iRedMail
chmod 0644 /etc/letsencrypt/{live,archive}
mv /etc/ssl/certs/iRedMail.crt{,.bak}   
mv /etc/ssl/private/iRedMail.key{,.bak}
ln -s /etc/letsencrypt/live/`hostname -f`/fullchain.pem /etc/ssl/certs/iRedMail.crt
ln -s /etc/letsencrypt/live/`hostname -f`/privkey.pem /etc/ssl/private/iRedMail.key
systemctl restart nginx
systemctl restart postfix
systemctl restart dovecot

# Crontab auto renew SSL Let's Encrypt
(crontab -l ; echo "") | crontab -
(crontab -l ; echo "# SSL Let's Encrypt auto renew") | crontab -
(crontab -l ; echo "1   3   *   *   *   certbot renew --post-hook '/usr/sbin/service postfix restart; /usr/sbin/service nginx restart; /usr/sbin/service dovecot restart'") | crontab -

# Fix SSL header
sed -i 's/smtpd_tls_security_level = may/smtpd_tls_security_level = encrypt/' /etc/postfix/main.cf
echo -e '\n#\n# fix SSL header\n#\nsmtp_tls_cert_file = /etc/ssl/certs/iRedMail.crt\nsmtp_tls_key_file = /etc/ssl/private/iRedMail.key' >> /etc/postfix/main.cf
systemctl restart postfix

read -p 'Do you want config Relay SMTP O365 (Y/n): ' configRelay
configRelay=${configRelay:-"y"}

if [ "$configRelay" == "y" ] ; then
  #SMTP Relay O365
  read -p 'Input Domain for Email: ' domainmail
  read -p 'Input Account: ' OAccount
  read -p 'Input Password: ' OPassword
  domainfix=${domainmail//./-}
  echo -e "\n#\n# Relay SMTP O365\n#\nrelayhost = [$domainfix.mail.protection.outlook.com]:25\nsmtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" >> /etc/postfix/main.cf
  echo -e "smtp_sasl_auth_enable = yes\nsmtp_sasl_mechanism_filter = login\nsmtp_sasl_security_options = noanonymous\nmailbox_size_limit = 26214400" >> /etc/postfix/main.cf
  touch /etc/postfix/sasl_passwd && echo "[$domainfix.mail.protection.outlook.com]:25 $OAccount:$OPassword" >> /etc/postfix/sasl_passwd
  postmap /etc/postfix/sasl_passwd
  systemctl restart postfix
fi
