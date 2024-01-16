certbot certonly --webroot --agree-tos -m phucpt2802@gmail.com -w /var/www/html -d `hostname -f`
chmod 0644 /etc/letsencrypt/{live,archive}
mv /etc/ssl/certs/iRedMail.crt{,.bak}   
mv /etc/ssl/private/iRedMail.key{,.bak}
ln -s /etc/letsencrypt/live/`hostname -f`/fullchain.pem /etc/ssl/certs/iRedMail.crt
ln -s /etc/letsencrypt/live/`hostname -f`/privkey.pem /etc/ssl/private/iRedMail.key
systemctl restart nginx
systemctl restart postfix
systemctl restart dovecot
(crontab -l ; echo "1   3   *   *   *   certbot renew --post-hook '/usr/sbin/service postfix restart; /usr/sbin/service nginx restart; /usr/sbin/service dovecot restart'") | crontab -
