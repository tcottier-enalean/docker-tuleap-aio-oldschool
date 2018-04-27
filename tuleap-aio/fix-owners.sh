#!/bin/bash
set -ex 

echo -n "Update data ownership to current image..."

chown -R gitolite:gitolite \
    /data/lib/tuleap/gitolite/repositories \
    /data/lib/tuleap/gitolite/grokmirror \
    /data/lib/gitolite

chown -R codendiadm:codendiadm \
    /data/etc/tuleap \
    /data/home/codendiadm \
    /data/lib/tuleap/docman \
    /data/lib/tuleap/images \
    /data/lib/tuleap/mediawiki \
    /data/lib/tuleap/tracker \
    /data/lib/tuleap/user \
    /data/lib/tuleap/wiki \
    /data/lib/tuleap/gitolite/admin \
    /var/lib/tuleap/svn_plugin

chown codendiadm:codendiadm \
    /data/home/groups \
    /data/home/users \
    /data/lib/tuleap \
    /data/lib/tuleap/backup \
    /data/lib/tuleap/cvsroot \
    /data/lib/tuleap/gitolite \
    /data/lib/tuleap/gitroot \
    /data/lib/tuleap/svnroot

chown codendiadm \
    /data/lib/tuleap/ftp/tuleap/*

chown dummy:dummy \
    /data/lib/tuleap/dumps

chown root:ftp \
     /data/lib/tuleap/ftp

chown ftpadmin:ftpadmin \
    /data/lib/tuleap/ftp/incoming \
    /data/lib/tuleap/ftp/pub

echo "DONE !"
