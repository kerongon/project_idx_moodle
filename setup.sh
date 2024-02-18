#!/bin/bash

# Clone the Moodle repository
git clone --depth 1 -b MOODLE_403_STABLE https://github.com/moodle/moodle.git www

# Create the php_config directory
mkdir php_config

# Find and copy the php.ini file
cp $(find /nix/store -name 'php.ini' -path '*php-8.1.27/etc*' -print) php_config/php.ini

# Find and copy the extensions.ini file
cp $(find /nix/store -name 'php.ini' -path '*php-with-extensions-8.1.27/lib*' -print) php_config/extensions.ini

# Increase max_input_vars value for Moodle
sed -i 's/;max_input_vars = 1000/max_input_vars = 6000/' php_config/php.ini