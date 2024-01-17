# Create SSL Let's Encrypt
certbot certonly --webroot --agree-tos -w /var/www/html -d `hostname -f`

# Fix SSL Let's Encrypt for iRedMail
chmod 0644 /etc/letsencrypt/{live,archive}
mv /etc/ssl/certs/iRedMail.crt{,.bak}   
mv /etc/ssl/private/iRedMail.key{,.bak}
ln -s /etc/letsencrypt/live/`hostname -f`/fullchain.pem /etc/ssl/certs/iRedMail.crt
ln -s /etc/letsencrypt/live/`hostname -f`/privkey.pem /etc/ssl/private/iRedMail.key
echo "config finished SSL Let's Encrypt for iRedMail"

#fix SSL header
postconf -e smtpd_tls_security_level=encrypt
echo -e "\n#\n# fix SSL header\n#"
postconf -e smtp_tls_cert_file=/etc/ssl/certs/iRedMail.crt
postconf -e smtp_tls_key_file=/etc/ssl/private/iRedMail.key
echo "Fix finished SSL Let's Encrypt for header email"
systemctl restart nginx
systemctl restart postfix
systemctl restart dovecot
echo "Restarted nginx postfix dovecot"

# Crontab auto renew SSL Let's Encrypt
(crontab -l ; echo "") | crontab -
(crontab -l ; echo "# SSL Let's Encrypt auto renew") | crontab -
(crontab -l ; echo "1   3   *   *   *   certbot renew --post-hook '/usr/sbin/service postfix restart; /usr/sbin/service nginx restart; /usr/sbin/service dovecot restart'") | crontab -
echo "Config finished CronTab for auto renew SSL # SSL Let's Encrypt"
