#!/bin/bash
set -e

# Generate application/config/app-config.php from environment variables.
# This runs on every container start so secrets are never baked into the image.
cat > /var/www/html/application/config/app-config.php <<PHP
<?php

defined('BASEPATH') or exit('No direct script access allowed');

define('APP_BASE_URL',    '${APP_BASE_URL}');
define('APP_ENC_KEY',     '${APP_ENC_KEY}');

define('APP_DB_HOSTNAME', '${APP_DB_HOSTNAME}');
define('APP_DB_USERNAME', '${APP_DB_USERNAME}');
define('APP_DB_PASSWORD', '${APP_DB_PASSWORD}');
define('APP_DB_NAME',     '${APP_DB_NAME}');

define('APP_DB_CHARSET',   'utf8mb4');
define('APP_DB_COLLATION', 'utf8mb4_unicode_ci');

define('SESS_DRIVER',   'database');
define('SESS_SAVE_PATH', 'sessions');
define('APP_SESSION_COOKIE_SAME_SITE', 'Lax');

define('APP_CSRF_PROTECTION', true);
PHP

# Ensure the config file is readable by Apache
chown www-data:www-data /var/www/html/application/config/app-config.php
chmod 640 /var/www/html/application/config/app-config.php

exec apache2-foreground
