#!/bin/bash

set -ex

# On start, ensure db is consistent with data (useful for version bump)
/usr/lib/forgeupgrade/bin/forgeupgrade --config=/etc/codendi/forgeupgrade/config.ini update

# Ensure system will be synchronized ASAP (once system starts)
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/src/utils/launch_system_check.php

# Switch to php 5.6 + nginx
if [ ! -f "/etc/nginx/conf.d/tuleap.conf" ]; then
    /usr/share/tuleap/tools/utils/php56/run.php
fi
