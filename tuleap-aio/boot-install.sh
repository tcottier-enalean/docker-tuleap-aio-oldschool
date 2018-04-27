#!/bin/bash

set -ex

function generate_passwd {
   cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 15 | head -1
}

# Generate self signed certificate for Apache
export RANDFILE=$OPENSHIFT_DATA_DIR/.rnd
touch ${RANDFILE}
openssl req -new -nodes -keyout /etc/pki/tls/private/localhost.key \
         -subj "/C=FR/ST=SomeState/L=SomeCity/O=SomeOrganization/CN=${VIRTUAL_HOST}" 
         -x509 -sha256 -days 365 -set_serial $RANDOM -extensions v3_req \
         -out /etc/ssl/certs/localhost.crt 2>/dev/null

INSTALL_OPTIONS="
    --password-file=/root/.tuleap_passwd
    --disable-chkconfig
    --disable-domain-name-check
    --disable-unix-groups
    --sys-default-domain=$VIRTUAL_HOST
    --sys-org-name=Tuleap
    --sys-long-org-name=Tuleap"

if [ -n "$DB_HOST" ]; then
    INSTALL_OPTIONS="$INSTALL_OPTIONS
        --mysql-host=$DB_HOST
        --mysql-user-password=$MYSQL_ROOT_PASSWORD
        --mysql-httpd-host=%"
fi

# Install Tuleap
/usr/share/tuleap/tools/setup.sh $INSTALL_OPTIONS

# Setting root password
root_passwd=$(generate_passwd)
echo "root:$root_passwd" |chpasswd
echo "root: $root_passwd" >> /root/.tuleap_passwd

# Force the generation of the SSH host keys
service sshd start && service sshd stop

# (Re)Generate the Gitolite admin key for the codendiadm user
ssh-keygen -q -t rsa -N "" -C 'Tuleap / gitolite admin key' -f '/home/codendiadm/.ssh/id_rsa_gl-adm'
chown codendiadm:codendiadm /home/codendiadm/.ssh/id_rsa_gl-adm*
echo "command=\"/usr/share/gitolite3/gitolite-shell id_rsa_gl-adm\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $(cat /home/codendiadm/.ssh/id_rsa_gl-adm.pub)" > /var/lib/gitolite/.ssh/authorized_keys
chown gitolite:gitolite /var/lib/gitolite/.ssh/authorized_keys
chmod 600 /var/lib/gitolite/.ssh/authorized_keys

# Ensure system will be synchronized ASAP
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/src/utils/launch_system_check.php

if [ -z "$DB_HOST" ]; then
    service mysqld stop
fi
service httpd stop
service crond stop
service nginx stop
service rh-php56-php-fpm stop
