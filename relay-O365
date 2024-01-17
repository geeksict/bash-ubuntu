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
